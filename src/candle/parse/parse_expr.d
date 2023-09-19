module candle.parse.parse_expr;

import candle.all;

void parseExpr(Node parent, Tokens t) {
    logParse("parse expr %s", t.debugValue());
    parseExprLhs(parent, t);
    parseExprRhs(parent, t);
}
void parseExprLhs(Node parent, Tokens t) {
    logParse("lhs %s", t.debugValue());
    switch(t.kind()) with(EToken) {
        case NUMBER: parseNumber(parent, t); return;
        case CHAR: parseChar(parent, t); return;
        case STRING: parseString(parent, t); return;
        case EXCLAIM: parseUnary(parent, t); return;
        case TILDE:
        case MINUS: 
            parseUnary(parent, t); 
            return;
        case LBRACKET: parseParens(parent, t); return;
        case AT: parseBuiltinFunc(parent, t); return;
        case ID:
            switch(t.value()) {
                case "true":
                case "false": parseNumber(parent, t); return;
                case "null": parseNull(parent, t); return;
                default: break;
            }

            if(t.kind(1) == EToken.LBRACKET) {
                parseCall(parent, t);
                return;
            }

            parseId(parent, t);
            break;
        default:
            syntaxError(t, "expression lhs");
            break;
    }
}
void parseExprRhs(Node parent, Tokens t) {
    logParse("rhs %s", t.debugValue());
    while(!t.eof()) {
        switch(t.kind()) with(EToken) {
            case NONE:
            case SEMICOLON:
            case RCURLY:
            case RBRACKET:
            case RSQUARE:
            case COMMA:
            case ID:        // ID, ID could be a Var or Func with an unknown Type
                return;
            case PLUS:
            case MINUS:
            case STAR:
            case SLASH:
            case PERCENT:
            case AMP:
            case PIPE:
            case HAT:
            case LT_LT:
            case GT_GT:

            case PLUS_EQ:
            case MINUS_EQ:
            case STAR_EQ:
            case SLASH_EQ:
            case PERCENT_EQ:
            case AMP_EQ:
            case PIPE_EQ:
            case HAT_EQ:
            case LT_LT_EQ:
            case GT_GT_EQ:
            case AMP_AMP:
            case PIPE_PIPE:

            case LT:
            case GT:
            case LT_EQ:
            case GT_EQ:
            case EQ_EQ:
            case EXCLAIM_EQ: {
                auto b = makeNode!Binary(t.coord());
                b.op = toBinaryOperator(t.kind());
                t.next();
                parent = attachAndRead(parent, b, t, true);
                break;
            }
            case DOT: {
                Dot dot = makeNode!Dot(t.coord());
                t.skip(EToken.DOT);
                parent = attachAndRead(parent, dot, t, true);
                break;
            }
            default:
                syntaxError(t, "expression rhs %s".format(t.debugValue()));
                break;
        }
    }
}
Expr attachAndRead(Node parent, Expr newExpr, Tokens t, bool andRead) {

    Node prev = parent;

    //
    // Swap expressions according to operator precedence
    //
    bool doPrecedenceCheck = prev.isA!Expr;
    if(doPrecedenceCheck) {

        // Adjust to account for operator precedence
        Expr prevExpr = prev.as!Expr;
        while(prevExpr.parent && newExpr.precedence() < prevExpr.precedence()) {

            if(!prevExpr.parent.isA!Expr) {
                prev = prevExpr.parent;
                break;
            }

            prevExpr = prevExpr.parent.as!Expr;
            prev     = prevExpr;
        }
    }

    newExpr.add(prev.last());

    prev.add(newExpr);

    if(andRead) {
        parseExprLhs(newExpr, t);
    }

    return newExpr;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

void parseNumber(Node parent, Tokens t) {
    Number num = makeNode!Number(t.coord());
    parent.add(num);
    num.parse(t);
}
void parseNull(Node parent, Tokens t) {
    Null n = makeNode!Null(t.coord());
    parent.add(n);
    n.parse(t);
}
void parseChar(Node parent, Tokens t) {
    Char ch = makeNode!Char(t.coord());
    parent.add(ch);
    ch.parse(t);
}
void parseString(Node parent, Tokens t) {
    String str = makeNode!String(t.coord());
    parent.add(str);
    str.parse(t);
}
void parseUnary(Node parent, Tokens t) {
    Unary u = makeNode!Unary(t.coord());
    parent.add(u);
    u.parse(t);
}
void parseId(Node parent, Tokens t) {
    Node id;
    if(parent.getProject().isProjectName(t.value())) {
        id = makeNode!ProjectId(t.coord());
    } else {
        id = makeNode!Id(t.coord());
    }
    parent.add(id);
    id.parse(t);
}
void parseCall(Node parent, Tokens t) {
    Call call = makeNode!Call(t.coord());
    parent.add(call);
    call.parse(t);
}
void parseParens(Node parent, Tokens t) {
    Parens p = makeNode!Parens(t.coord());
    parent.add(p);
    p.parse(t);
}
void parseBuiltinFunc(Node parent, Tokens t) {
    BuiltinFunc f = makeNode!BuiltinFunc(t.coord());
    parent.add(f);
    f.parse(t);
}
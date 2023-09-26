module candle.parse.parse_expr;

import candle.all;

void parseExpr(Node parent, Tokens t) {
    logParse("parse expr %s", t.debugValue());
    parseExprLhs(parent, t);
    parseExprRhs(parent, t);

    if(parent.isA!Scope || parent.isA!Unit) {
        if(t.isKind(EToken.SEMICOLON)) {
            t.next();
            assert(parent.last().isA!Expr);
            parent.last().as!Expr.isStmt = true;
        }
    }
}
void parseExprLhs(Node parent, Tokens t) {
    logParse("lhs %s", t.debugValue());
    Project project = t.unit.project;
    if(isType(project, t)) {
        parseType(parent, t);
        return;
    }
    switch(t.kind()) with(EToken) {
        case NUMBER: parseNumber(parent, t); return;
        case CHAR: parseChar(parent, t); return;
        case STRING: parseString(parent, t); return;
        case TILDE:
        case MINUS: 
            parseUnary(parent, t); 
            return;
        case LBRACKET: parseParens(parent, t); return;
        case LCURLY: {
            auto ls = makeNode!LiteralStruct(t.coord());
            parent.add(ls);
            ls.parse(t); 
            return;
        }
        case AT: parseBuiltinFunc(parent, t); return;
        case ID:
            switch(t.value()) {
                case "true":
                case "false": parseNumber(parent, t); return;
                case "null": parseNull(parent, t); return;
                case "not": parseUnary(parent, t); return;
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
        //logParse("t = %s", t.debugValue());
        sw:switch(t.kind()) with(EToken) {
            case ID:  
                switch(t.value()) {
                    case "as":
                        As as = parseAndReturnAs(t);
                        parent = attachAndRead(parent, as, t, true);
                        break sw;
                    case "is":
                        Is is_ = parseAndReturnIs(t);
                        parent = attachAndRead(parent, is_, t, true);
                        break sw;
                    case "and":
                    case "or": {
                        auto b = parseAndReturnBinary(t);
                        parent = attachAndRead(parent, b, t, true);
                        break sw;
                    }
                    default: 
                        return;   
                }   
            case NONE:
            case SEMICOLON:
            case RCURLY:
            case RBRACKET:
            case RSQUARE:
            case COMMA:
                return;
            case EQ:
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

            case LT:
            case GT:
            case LT_EQ:
            case GT_EQ:
            case EQ_EQ:
            case EXCLAIM_EQ: {
                auto b = parseAndReturnBinary(t);
                parent = attachAndRead(parent, b, t, true);
                break;
            }
            case DOT: {
                Dot dot = parseAndReturnDot(t);
                parent = attachAndRead(parent, dot, t, true);
                break;
            }
            default:
                syntaxError(t, "expression rhs %s".format(t.debugValue()));
                return;
        }
    }
}
Expr attachAndRead(Node parent, Expr newExpr, Tokens t, bool andRead) {

    Node prev = parent;

    //
    // Swap expressions according to operator precedence
    //
    if(Expr prevExpr = prev.as!Expr) {

        // Adjust to account for operator precedence
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

Binary parseAndReturnBinary(Tokens t) {
    auto b = makeNode!Binary(t.coord());
    if(t.isValue("and")) {
        b.op = Operator.BOOL_AND;
    } else if(t.isValue("or")) {
        b.op = Operator.BOOL_OR;
    } else {
        b.op = toBinaryOperator(t.kind());
    }
    t.next();
    return b;
}
Dot parseAndReturnDot(Tokens t) {
    Dot dot = makeNode!Dot(t.coord());
    t.skip(EToken.DOT);
    return dot;
}
As parseAndReturnAs(Tokens t) {
    As as = makeNode!As(t.coord());
    t.next();
    return as;
}
Is parseAndReturnIs(Tokens t) {
    Is is_ = makeNode!Is(t.coord());
    t.next();
    if(t.isValue("not")) {
        t.next();
        is_.negate = true;
    }
    return is_;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
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
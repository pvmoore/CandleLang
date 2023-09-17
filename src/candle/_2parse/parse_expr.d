module candle._2parse.parse_expr;

import candle.all;


void parseExpr(Node parent, Tokens t) {
    logParse("parse expr %s", t.debugValue());
    lhs(parent, t);
    rhs(parent, t);
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

void lhs(Node parent, Tokens t) {
    switch(t.kind()) with(EToken) {
        case NUMBER: parseNumber(parent, t); return;
        case CHAR: parseChar(parent, t); return;
        case STRING: parseString(parent, t); return;
        case EXCLAIM: parseUnary(parent, t); return;
        case TILDE: parseUnary(parent, t); return;
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

void rhs(Node parent, Tokens t) {
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
                syntaxError(t, "expression rhs");
                break;
        }
    }
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
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
        lhs(newExpr, t);
    }

    return newExpr;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
void parseNumber(Node parent, Tokens t) {
    Number num = makeNode!Number(t.coord());
    parent.add(num);

    num.stringValue = t.value(); t.next();
    num.value = Value(num.stringValue);
}
void parseNull(Node parent, Tokens t) {
    Null n = makeNode!Null(t.coord());
    parent.add(n);

    t.next();
}
void parseChar(Node parent, Tokens t) {
    Char ch = makeNode!Char(t.coord());
    parent.add(ch);

    ch.stringValue = t.value(); t.next();
    ch.value = Value(ch.stringValue);
}
void parseString(Node parent, Tokens t) {
    String str = makeNode!String(t.coord());
    parent.add(str);

    // Gather all sequential strings into one
    while(t.isKind(EToken.STRING)) {
        str.stringValue ~= t.value()[1..$-1]; t.next();
    }
}
void parseUnary(Node parent, Tokens t) {
    Unary u = makeNode!Unary(t.coord());
    parent.add(u);

    u.op = toUnaryOperator(t.kind());
    t.next();

    lhs(u, t);
}
void parseId(Node parent, Tokens t) {
    string name = t.value(); t.next();
    auto project = parent.getProject();

    if(project.isProjectName(name)) {
        ProjectId id = makeNode!ProjectId(t.coord());
        id.name = name;
        id.project = project.getDependency(name);
        parent.add(id);
    } else {
        Id id = makeNode!Id(t.coord());
        id.name = name;
        parent.add(id);
    }
}
void parseCall(Node parent, Tokens t) {

    Call call = makeNode!Call(t.coord());
    parent.add(call);

    call.name = t.value(); t.next();

    t.skip(EToken.LBRACKET);

    bool hasArgs = !t.isKind(EToken.RBRACKET);

    if(hasArgs) {

        Parens p = makeNode!Parens(t.coord());
        call.add(p);

        while(!t.isKind(EToken.RBRACKET)) {
            parseExpr(p, t);

            if(t.isKind(EToken.COMMA)) {
                t.next();
            }
        }

        p.detach();
        while(p.hasChildren()) {
            call.add(p.first());
        }
    }
    t.skip(EToken.RBRACKET);

    if(t.isKind(EToken.SEMICOLON)) {
        call.isStmt = true;
    }
}
void parseParens(Node parent, Tokens t) {

    Parens p = makeNode!Parens(t.coord());
    parent.add(p);

    t.skip(EToken.LBRACKET);

    parseExpr(p, t);

    t.skip(EToken.RBRACKET);
}
/** 
 * BUILTIN_FUNC ::= '@' name '(' { Expr } ')'
 */
void parseBuiltinFunc(Node parent, Tokens t) {
    BuiltinFunc f = makeNode!BuiltinFunc(t.coord());
    parent.add(f);

    t.skip(EToken.AT);

    f.name = t.value(); t.next();

    t.skip(EToken.LBRACKET);
    while(!t.isKind(EToken.RBRACKET)) {
        parseExpr(f, t);
        t.skipOptional(EToken.COMMA);
    }
    t.skip(EToken.RBRACKET);

    if(t.isKind(EToken.SEMICOLON)) {
        f.isStmt = true;
    }
}
module candle.parseandresolve.parse_stmt;

import candle.all;

void parseStmt(Node parent, Tokens t) {
    logParse("parse stmt %s", t.debugValue());

    Project project = parent.getProject();
    bool isProjectScope = parent.isA!Unit;

    // Some Stmts can only appear at Project scope for example:
    // - Func
    // - Struct
    // - Union
    // - Enum
    // - Typedef
    if(isProjectScope) {

        // pub extern
        t.consumeModifiers();

        switch(t.kind()) with(EToken) {
            case ID:
                switch(t.value()) {
                    case "struct": parseStruct(parent, t); return;
                    case "alias": parseAlias(parent, t); return;
                    default: break;
                }
                break;
            default: break;
        }


    } else {
        // These can only occur at Func scope:
        // - Expr
        // - Return


    }

    switch(t.kind()) with(EToken) {
        case ID:
            switch(t.value()) {
                case "return": parseReturn(parent, t); return;
                default: break;
            }
            if(isType(project, t)) {
                logParse("  isType %s", t.debugValue());
                int afterType = typeLength(t);
                logParse("afterType = %s .. %s", afterType, t.debugValue(afterType));

                // Type Id (
                if(t.kind(afterType)==EToken.ID && t.kind(afterType+1)==EToken.LBRACKET) {
                    parseFunc(parent, t);
                    return;
                }

                // Assume it is a var
                parseVar(parent, t);
                return;
            } else {
                logParse("  not a type %s", t.debugValue());
            }

            break;
        case LBRACKET:
            // function ptr
            if(isType(project, t)) {
                parseVar(parent, t);
                return;
            }
            break;    
        case SEMICOLON:
            t.next();
            return;
        default:
            break;
    }

    parseExpr(parent, t);
}
void parseVar(Node parent, Tokens t) {
    logParse("parseVar %s", t.debugValue());
    Var v = makeNode!Var(t.coord());
    parent.add(v);
    v.parse(t);
}
void parseFunc(Node parent, Tokens t) {
    logParse("parseFunc %s", t.debugValue());
    Func f = makeNode!Func(t.coord());
    parent.add(f);
    f.parse(t);
}
void parseReturn(Node parent, Tokens t) {
    Return ret = makeNode!Return(t.coord());
    parent.add(ret);
    ret.parse(t);
}
void parseStruct(Node parent, Tokens t) {
    Struct s = makeNode!Struct(t.coord());
    parent.add(s);
    s.parse(t);
}
void parseAlias(Node parent, Tokens t) {
    Alias a = makeNode!Alias(t.coord());
    parent.add(a);
    a.parse(t);
}
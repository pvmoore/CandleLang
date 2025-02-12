module candle.parse.parse_stmt;

import candle.all;

void parseStmt(Node parent, Tokens t) {
    logParse("parse stmt %s", t.debugValue());

    Module module_ = parent.getModule();
    bool isModuleScope = parent.isA!Unit;

    // Some Stmts can only appear at Module scope:
    // - Alias
    // - Enum
    // - Func
    // - Struct
    // - Union
    if(isModuleScope) {

        // pub extern
        t.consumeModifiers();

        switch(t.kind()) with(EToken) {
            case ID:
                switch(t.value()) {
                    case "alias": parseAlias(parent, t); return;
                    case "enum": parseEnum(parent, t); return;
                    case "func": parseFunc(parent, t); return;
                    case "struct": parseStruct(parent, t); return;
                    case "union": parseUnion(parent, t); return;
                    default: break;
                }
                break;
            default: break;
        }


    } else {
        // These can only occur at Func scope:
        // - Return
        // - Expr


    }

    // These can appear at Module or Func scope:
    // - Var

    switch(t.kind()) with(EToken) {
        case ID:
            switch(t.value()) {
                case "return": parseReturn(parent, t); return;
                default: break;
            }

            // Type name [ = Expr ]
            if(isType(module_, t, false)) {
                parseVar(parent, t);
                return;
            }

            // It might still be a UDT
            // if(t.matches(EToken.ID, EToken.ID)) {
            //     // Assume this is a var
            //     parseVar(parent, t);
            //     return;
            // }

            // if(isType(module_, t)) {
            //     logParse("  isType %s", t.debugValue());
            //     int afterType = typeLength(t);
            //     logParse("afterType = %s .. %s", afterType, t.debugValue(afterType));

            //     // Type Id (
            //     if(t.kind(afterType)==EToken.ID && t.kind(afterType+1)==EToken.LBRACKET) {
            //         parseFunc(parent, t);
            //         return;
            //     }

            //     // Assume it is a var
            //     parseVar(parent, t);
            //     return;
            // } else {
            //     logParse("  not a type %s", t.debugValue());
            // }

            break;
        // case LBRACKET:
        //     // function ptr
        //     if(isType(module_, t)) {
        //         parseVar(parent, t);
        //         return;
        //     }
        //     break;    
        case SEMICOLON:
            t.next();
            return;
        default:
            break;
    }

    // Everything else must be an Expr

    parseExpr(parent, t);
}
void parseVar(Node parent, Tokens t) {
    logParse("parseVar %s", t.debugValue());
    Var v = makeNode!Var(t.coord());
    parent.add(v);
    v.parse(t);
}
void parseParam(Node parent, Tokens t) {
    logParse("parseParam %s", t.debugValue());
    Var v = makeNode!Var(t.coord());
    parent.add(v);
    v.parseParam(t);
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
void parseUnion(Node parent, Tokens t) {
    todo("unions");
}
void parseEnum(Node parent, Tokens t) {
    todo("enums");
}
void parseAlias(Node parent, Tokens t) {
    Alias a = makeNode!Alias(t.coord());
    parent.add(a);
    a.parse(t);
}

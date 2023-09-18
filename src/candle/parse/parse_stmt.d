module candle.parse.parse_stmt;

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

            // ID ID -> Type ID
            if(isType(project, t) || t.kind(1)==EToken.ID) {
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
        case SEMICOLON:
            t.next();
            return;
        default:
            break;
    }

    parseExpr(parent, t);
}

/**
 * VAR ::= Type [ Id [ '=' Expr ] ]
 */
void parseVar(Node parent, Tokens t) {
    logParse("parseVar %s", t.debugValue());

    Var v = makeNode!Var(t.coord());
    parent.add(v);

    // Type
    parseType(v, t);

    // Name (optional)
    if(t.isKind(EToken.ID)) {
        v.name = t.value(); t.next();

        // Expression
        if(t.isKind(EToken.EQ)) {
            t.next();

            parseExpr(v, t);
        }
    }

    if(t.isKind(EToken.SEMICOLON)) {
        t.next();
    }

    // Move this var above any Funcs
    if(Unit unit = parent.as!Unit) {
        Func f = unit.findFirstChildOf!Func;
        int index = f ? f.index() : int.max;
        if(index != int.max) {
            int vIndex = unit.indexOf(v);
            if(vIndex > index) {
                unit.moveToIndex(index, v);
            }
        }
    }
}

/**
 * FUNC      ::= MODIFIERS Type Id '(' PARAMS ')'  [ BODY ] ';'
 * MODIFIERS ::= [pub] [extern]
 * PARAMS    ::= [ Type Id ] { ',' Type Id }
 * BODY      ::= '{' {Stmt} '}'
 */
void parseFunc(Node parent, Tokens t) {
    logParse("parseFunc %s", t.debugValue());

    Func f = makeNode!Func(t.coord());
    parent.add(f);

    // Modifiers
    f.isPublic = t.getAndResetPubModifier();
    f.isExtern = t.getAndResetExternModifier();

    // Return type
    parseType(f, t);

    // Name
    f.name = t.value(); t.next();

    // Parameters
    t.skip(EToken.LBRACKET);
    while(!t.isKind(EToken.RBRACKET)) {
        f.numParams++;
        parseVar(f, t);

        t.skipOptional(EToken.COMMA);
    }
    t.skip(EToken.RBRACKET);

    // Body
    if(t.isKind(EToken.LCURLY)) {
        Scope scope_ = makeNode!Scope(t.coord());
        f.add(scope_);

        t.skip(EToken.LCURLY);

        while(!t.isKind(EToken.RCURLY)) {
            if(t.eof()) syntaxError(t, "}");

            parseStmt(scope_, t);
        }

        t.skip(EToken.RCURLY);
    } else {
        // Must be an extern function
        t.skip(EToken.SEMICOLON);
    }
}

/**
 *  RETURN ::= 'return' [ Expr ] ';'
 */
void parseReturn(Node parent, Tokens t) {

    Return ret = makeNode!Return(t.coord());
    parent.add(ret);

    t.skip("return");

    if(t.isKind(EToken.SEMICOLON)) {
        t.next();
    } else {
        parseExpr(ret, t);

        t.skip(EToken.SEMICOLON);
    }
}

/**
 *  STRUCT ::= 'struct' Id ( BODY | ';')
 *  BODY   ::= '{' { Var } '}'
 */
void parseStruct(Node parent, Tokens t) {
    Struct s = makeNode!Struct(t.coord());
    parent.add(s);

    s.isPublic = t.getAndResetPubModifier();

    t.skip("struct");

    s.name = t.value(); t.next();

    if(t.isKind(EToken.LCURLY)) {
        t.next();

        while(!t.isKind(EToken.RCURLY)) {
            parseVar(s, t);
        }
        t.skip(EToken.RCURLY);

        // Move this above any Vars or Funcs
        if(Unit unit = parent.as!Unit) {
            Var v = unit.findFirstChildOf!Var;
            Func f = unit.findFirstChildOf!Func;
            int index = minOf(v ? v.index() : int.max, f ? f.index() : int.max);
            if(index != int.max) {
                int sIndex = unit.indexOf(s);
                if(sIndex > index) {
                    unit.moveToIndex(index, s);
                }
            }
        }
    } else {
        t.skip(EToken.SEMICOLON);
    }
}
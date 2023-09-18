module candle.ast.type.Func;

import candle.all;

/**
 *  Func
 *      Type        return type
 *      { Var }     parameters
 *      [ Scope ]   body            may not be present if this is a Func pointer or is extern
 */
final class Func : Node, Type {
public:
    int numParams;
    string name;
    bool isPublic;
    bool isExtern;
    bool isProgramEntry; // true if this is "main" or "WinMain"

    Type returnType() { return first.as!Type; }
    Var[] params() { return children[1..numParams+1].as!(Var[]); }
    Type[] paramTypes() { return params().map!(it=>it.type()).array(); }
    Scope body_() { return children[$-1].as!Scope; }

    override ENode enode() { return ENode.FUNC; }
    override EType etype() { return EType.FUNC; }
    override bool isResolved() { return returnType().isResolved() && params().areResolved(); }
    override Type type() { return this; }
    override bool exactlyMatches(Type otherType) {
        // This only checks the parameter types
        assert(isResolved() && otherType.isResolved());
        Func other = otherType.as!Func;
        if(!other) return false;
        //if(name!=other.name) return false;
        //if(!returnType.exactlyMatches(other.returnType())) return false;
        return exactlyMatch(paramTypes(), other.paramTypes());
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        Func other = otherType.as!Func;
        if(other is null || other.numParams != numParams) return false;

        // TODO - other parameters must all be the same Type
        return false;
    }
    override string toString() {
        string pub = isPublic ? ", pub" : "";
        string extrn = isExtern ? ", extern" : "";
        return "Func %s, %s params%s%s".format(name, numParams, pub, extrn);
    }
    /**
     * FUNC      ::= MODIFIERS Type Id '(' PARAMS ')'  [ BODY ] ';'
     * MODIFIERS ::= [pub] [extern]
     * PARAMS    ::= [ Type Id ] { ',' Type Id }
     * BODY      ::= '{' {Stmt} '}'
     */
    override void parse(Tokens t) {
        // Modifiers
        this.isPublic = t.getAndResetPubModifier();
        this.isExtern = t.getAndResetExternModifier();

        // Return type
        parseType(this, t);

        // Name
        this.name = t.value(); t.next();
        this.isProgramEntry = name=="main" || name.toLower()=="winmain";

        // Parameters
        t.skip(EToken.LBRACKET);
        while(!t.isKind(EToken.RBRACKET)) {
            this.numParams++;
            parseVar(this, t);

            t.skipOptional(EToken.COMMA);
        }
        t.skip(EToken.RBRACKET);

        // Body
        if(t.isKind(EToken.LCURLY)) {
            Scope scope_ = makeNode!Scope(t.coord());
            this.add(scope_);

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
private:
}
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
    string name;        // null if isFuncPtr == true
    int numParams;
    bool isPublic;
    bool isExtern;
    bool isProgramEntry; // true if this is "main" or "WinMain"
    bool isFuncPtr; 

    Type returnType() { return first().as!Type; }
    Var[] params() { return children[1..numParams+1].as!(Var[]); }
    Type[] paramTypes() { return params().map!(it=>it.type()).array(); }
    Scope body_() { assert(!isExtern); return last().as!Scope; }

    override ENode enode() { return ENode.FUNC; }
    override EType etype() { return EType.FUNC; }
    override bool isResolved() { return returnType().isResolved() && params().areResolved(); }
    override Type type() { return this; }

    /** 
     * This only checks the parameter types.
     * The return type and the name are not included.  
     */
    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Func other = otherType.as!Func;
        if(!other) return false;
        return exactlyMatch(paramTypes(), other.paramTypes());
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Func other = otherType.as!Func;
        if(other is null || other.numParams != numParams) return false;

        // TODO - other parameters must all be the same Type
        return false;
    }
    override string toString() {
        return "Func";
    }
    override string toVerboseString() {
        if(isFuncPtr) {
            string s;
            foreach(i, t; paramTypes()) {
                if(i>0) s ~= ",";
                s ~= "%s".format(t);
            } 
            return "Func (%s->%s)".format(s, returnType());
        }
        string l = ", line %s".format(coord.line+1);
        string pub = isPublic ? ", pub" : "";
        string extrn = isExtern ? ", extern" : "";
        return "Func %s, %s params%s%s%s".format(name, numParams, pub, extrn, l);
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
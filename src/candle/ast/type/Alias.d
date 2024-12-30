module candle.ast.type.Alias;

import candle.all;

/**
 *  Alias
 *      Type
 */
final class Alias : Stmt, Type {
public:
    string name;
    bool isPublic;

    Type toType() { return first().as!Type; }

    override ENode enode() { return ENode.ALIAS; }
    override EType etype() { return EType.ALIAS; }
    override bool isResolved() { return toType().isResolved(); }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return toType().exactlyMatches(otherType);
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return toType().canImplicitlyConvertTo(otherType);
    }
    override Type type() { return this; }

    override string toString() {
        return "Alias %s".format(name);
    }
    override string getASTSummary() {
        string l = ", line %s".format(coord.line+1);
        string pub = isPublic ? ", pub" : "";
        return "Alias %s%s%s".format(name, pub, l);
    }
    /**
     * ALIAS ::= 'alias' name '=' Type ';' 
     */
    override void parse(Tokens t) {
        this.isPublic = t.getAndResetPubModifier();
        t.skip("alias");
        this.name = t.value(); t.next();
        t.skip(EToken.EQ);
        parseType(this, t);
        t.skip(EToken.SEMICOLON);

        getModule().localUDTNames[name] = isPublic;
    }
    override void resolve() {
        
    }
    override void check() {
        Type t = toType();

        bool isUDT = t.isA!Alias || t.isA!TypeRef || t.as!Struct || t.isA!Union || t.isA!Enum;

        if(isPublic && isUDT && !t.isPublic) {
            getCandle().addError(new SemanticError(EError.PANPUDT, this, "Public alias to non-public user defined type %s".format(t)));
        }
    }
private:
}

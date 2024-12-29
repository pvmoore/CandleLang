module candle.ast.type.Enum;

import candle.all;

/**
 *  Enum
 *      { Id Expr }     values
 */
final class Enum : Stmt, Type {
public:
    string name;
    bool isPublic;
    bool isExtern;

    override ENode enode() { return ENode.ENUM; }
    override EType etype() { return EType.ENUM; }
    override bool isResolved() { return true; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return false;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return false;
    }
    override Type type() { return this; }

    override string toString() {
        return "Enum %s".format(name);
    }
    override string getASTSummary() {
        string l = ", line %s".format(coord.line+1);
        string pub = isPublic ? ", pub" : "";
        string e = isExtern ? ", extern" : "";
        return "Enum %s%s%s%s".format(name, pub, e, l);
    }
    override void parse(Tokens t) {
        todo();

        //getModule().localUDTNames[name] = isPublic;
    }
private:
}

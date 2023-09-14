module candle.ast.type.Struct;

import candle.all;

/**
 *  Struct
 *      { Var }
 */
final class Struct : Node, Type {
public:
    string name;
    bool isPublic;

    Var getVar(string name) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(v=>v.name==name)
                       .frontOrElse!Var(null);
    }
    Func[] getFuncs(string name) {
        return children.filter!(it=>it.isA!Func)
                       .map!(it=>it.as!Func)
                       .filter!(v=>v.name==name)
                       .array();
    }
    Var[] getVars() {
        return children.filter!(it=>it.isA!Var).map!(it=>it.as!Var).array;
    }
    Func[] getFuncs() {
        return children.filter!(it=>it.isA!Func).map!(it=>it.as!Func).array;
    }

    override ENode nkind() { return ENode.STRUCT; }
    override EType tkind() { return EType.STRUCT; }
    override bool isResolved() { return true; }
    override Type type() { return this; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Struct other = otherType.as!Struct;
        if(!other) return false;
        return false;
    }
    override bool canImplicitlyConvertTo(Type other) {
        return false;
    }

    override string toString() {
        string pub = isPublic ? ", pub" : "";
        return "Struct %s%s".format(name, pub);
    }
private:
}
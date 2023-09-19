module candle.ast.type.Union;

import candle.all;

/**
 *  Union
 *      { Var }
 *      { Func }
 */
final class Union : Node, Type {
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

    override ENode enode() { return ENode.UNION; }
    override EType etype() { return EType.UNION; }
    override bool isResolved() { return true; }
    override Type type() { return this; }
    
    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Union other = otherType.as!Union;
        if(!other) return false;
        // TODO
        return false;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        // TODO
        return false;
    }

    override string toString() {
        return "Struct %s".format(name);
    }
private:
}
module candle.ast.type.Union;

import candle.all;

/**
 *  Union
 *      { Var }
 *      { Func }
 */
final class Union : Stmt, Type {
public:
    string name;
    bool isPublic;
    bool isExtern;

    Var getVar(string name) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(v=>v.name==name)
                       .frontOrElse!Var(null);
    }
    Var[] getVars() {
        return children.filter!(it=>it.isA!Var).map!(it=>it.as!Var).array;
    }
    Type[] getVarTypes() {
        return getVars().map!(it=>it.type()).array;
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
        return "%s".format(name);
    }
    override string getASTSummary() {
        return "Union %s".format(name);
    }
    override void parse(Tokens t) {
        todo();
    }
private:
}

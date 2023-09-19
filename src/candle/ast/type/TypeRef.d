module candle.ast.type.TypeRef;

import candle.all;

/**
 *  TypeRef
 */
final class TypeRef : Node, Type {
public:
    string name;        // this is set if the type name is known
    Type decorated;     // this can be null until the Type has been resolved
    Project project;    // the Project of the decorated Type (if isExternal == true)
    bool isExternal;    // true if decorated Type is not in the current Project

    this(string name, Type decorated, Project project) {
        this.name = name;
        this.decorated = decorated;
        this.project = project;
    }

    override ENode enode() { return ENode.TYPE_REF; }
    override EType etype() { return decorated ? decorated.etype() : EType.UNKNOWN; }
    override bool isResolved() { return decorated && decorated.isResolved(); }
    override Type type() { return decorated ? decorated : TYPE_UNKNOWN; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return decorated.exactlyMatches(otherType);
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return decorated.canImplicitlyConvertTo(otherType);
    }
    override string toString() {
        string p = isExternal ? ", Project %s".format(project.name) : "";
        string s = decorated ? "%s".format(decorated)
                             : "'%s'".format(name);
        string unresolved = isResolved() ? "" : ", unresolved";
        return "TypeRef -> %s%s%s".format(s, p, unresolved);
    }
    override void resolve() {
        if(!decorated) {
            decorated = findType(project, name);
        }
    }
private:
}
module candle.ast.expr.Null;

import candle.all;

/**
 *  Null
 */
final class Null : Expr {
public:

    void setType(Type t) {
        this._type = t;
    }

    override ENode enode() { return ENode.NULL; }
    override Type type() { return _type ? _type : TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return _type && _type.isResolved(); }
    override string toString() {
        return "Null (%s)".format(type());
    }
    override void resolve() {
        setType(ResolveProject.resolveTypeFromParent(this));
    }
private:
    Type _type;
}
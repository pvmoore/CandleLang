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

    override ENode nkind() { return ENode.NULL; }
    override Type type() { return _type ? _type : TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return _type && _type.isResolved(); }
    override string toString() {
        return "Null (%s)".format(type());
    }
private:
    Type _type;
}
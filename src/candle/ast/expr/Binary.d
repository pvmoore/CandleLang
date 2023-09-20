module candle.ast.expr.Binary;

import candle.all;

/**
 *  Binary
 *      Expr
 *      Expr
 */
final class Binary : Expr {
public:
    Operator op;

    Expr left() { return first().as!Expr; }
    Expr right() { return last().as!Expr; }

    override ENode enode() { return ENode.BINARY; }
    override Type type() { return _type ? _type : TYPE_UNKNOWN; }
    override int precedence() { return precedenceOf(op); }
    override bool isResolved() { return _type !is null && _type != TYPE_UNKNOWN; }
    override string toString() {
        string t = _type ? "%s".format(_type) : "unknown";
        string s = isStmt ? ", isStmt=true" : "";
        return "Binary %s (%s)%s".format(stringOf(op), t, s);
    }
    override void resolve() {
        if(isResolved()) return;
        if(!left().isResolved() || !right.isResolved()) return;

        // Determine the Type
        _type = getBestType(left().type(), right().type());

        // Binary operations with byte or short are promoted to int
        if(Primitive p = _type.as!Primitive) {
            switch(p.etype()) with(EType) {
                case BYTE: case SHORT:
                    _type = TYPE_INT;
                    break;
                case UBYTE: case USHORT:
                    _type = TYPE_UINT;
                    break;
                default: break;
            }
        }
    }
private:
    Type _type;
}
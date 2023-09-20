module candle.ast.expr.As;

import candle.all;

/**
 *  As
 *      Expr
 *      Type
 */
final class As : Expr {
public:

    Expr expr() { return first().as!Expr; }

    override ENode enode() { return ENode.AS; }
    override Type type() { return last().as!Type; }
    override int precedence() { return 180; }
    override bool isResolved() { return type().isResolved(); }
    override string toString() {
        return "As (%s)".format(type());
    }
private:
}
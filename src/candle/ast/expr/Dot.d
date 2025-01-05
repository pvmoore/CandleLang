module candle.ast.expr.Dot;

import candle.all;

/**
 *  Dot
 *      Expr
 *      Expr
 */
final class Dot : Expr {
public:
    bool dblColon;  // true if this is a '::' otherwise it is '.'

    Expr left() { return first().as!Expr; }
    Expr right() { return last().as!Expr; }

    override ENode enode() { return ENode.DOT; }
    override Type type() { return right().type(); }
    override int precedence() { return 200; }
    override bool isResolved() { return right().isResolved(); }
    override string toString() {
        return "Dot %s".format(dblColon ? "::" : ".");
    }
private:
}

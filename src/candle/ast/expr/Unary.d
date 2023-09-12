module candle.ast.expr.Unary;

import candle.all;

/**
 *  Unary
 *      Expr
 */
final class Unary : Expr {
public:
    Operator op;

    Expr expr() { return first().as!Expr; }

    override NKind nkind() { return NKind.UNARY; }
    override Type type() { return expr().type(); }
    override int precedence() { return precedenceOf(op); }
    override bool isResolved() { return true; }
    override string toString() {
        return "Unary %s".format(stringOf(op));
    }
private:
}
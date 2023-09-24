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

    override ENode enode() { return ENode.UNARY; }
    override Type type() { return expr().type(); }
    override int precedence() { return precedenceOf(op); }
    override bool isResolved() { return true; }
    override string toString() {
        return "Unary %s".format(stringOf(op));
    }
    override void parse(Tokens t) {
        if(t.isValue("not")) {
            this.op = Operator.BOOL_NOT;
        } else {
            this.op = toUnaryOperator(t.kind());
        }
        t.next();

        parseExpr(this, t);
    }
private:
}
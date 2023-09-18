module candle.ast.expr.Parens;

import candle.all;

/**
 *  Parens
 *      Expr
 */
final class Parens : Expr {
public:

    Expr expr() { return first().as!Expr; }

    override ENode enode() { return ENode.PARENS; }
    override Type type() { return expr.type(); }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "Parens";
    }
    override void parse(Tokens t) {
        t.skip(EToken.LBRACKET);
        parseExpr(this, t);
        t.skip(EToken.RBRACKET);
    }
private:
}
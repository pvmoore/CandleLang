module candle.ast.expr.Scope;

import candle.all;

/**
 *  Scope
 *      { Stmt }
 */
final class Scope : Expr {
public:

    override NKind nkind() { return NKind.SCOPE;}
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "Scope ";
    }
private:
}
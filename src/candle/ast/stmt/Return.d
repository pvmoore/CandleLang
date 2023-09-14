module candle.ast.stmt.Return;

import candle.all;

/**
 *  Return
 *      [ Expr ]
 */
final class Return : Stmt {
public:

    Expr expr() { return hasChildren() ? first().as!Expr : null; }

    override ENode nkind() { return ENode.RETURN; }
    override Type type() { return TYPE_VOID; }
    override string toString() {
        return "Return";
    }
private:
}
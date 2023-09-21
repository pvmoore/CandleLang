module candle.ast.stmt.Return;

import candle.all;

/**
 *  Return
 *      [ Expr ]
 */
final class Return : Stmt {
public:

    Expr expr() { return hasChildren() ? first().as!Expr : null; }

    override ENode enode() { return ENode.RETURN; }
    override Type type() { return TYPE_VOID; }
    override string toString() {
        return "Return";
    }
    /**
     *  RETURN ::= 'return' [ Expr ] ';'
     */
    override void parse(Tokens t) {
        t.skip("return");

        if(!t.isKind(EToken.SEMICOLON)) {
            parseExpr(this, t);
        }
        t.skip(EToken.SEMICOLON);
    }
private:
}
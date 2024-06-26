module candle.ast.expr.Expr;

import candle.all;

abstract class Expr : Stmt {
public:
    bool isStmt;    // true if this Expr is standalone ie. followed by a ';'

    abstract int precedence();

    /**
     * Return true if this Expr is the start of a chain of expressions
     */
    final bool isStartOfChain() {
        if(!parent.isA!Dot) return true;
        if(parent.indexOf(this) != 0) return false;

        return parent.as!Dot.isStartOfChain();
    }
    /**
     * Return the previous link of the chain (if one exists)
     */
    final Expr prevLink() {
        if(!parent.isA!Dot) return null;
        if(isStartOfChain()) return null;

        if(auto prev = prevSibling()) {
            return prev.as!Expr;
        }
        assert(parent.parent.isA!Dot);
        return parent.parent.as!Dot.left();
    }
}

module candle.ast.expr.Expr;

import candle.all;

abstract class Expr : Stmt {
public:
    bool isStmt;    // true if this Expr is followed by a ';'

    abstract int precedence();

    final bool isStartOfChain() {
        if(!parent.isA!Dot) return true;
        if(parent.indexOf(this) != 0) return false;

        return parent.as!Dot.isStartOfChain();
    }
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
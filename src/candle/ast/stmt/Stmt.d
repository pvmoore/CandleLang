module candle.ast.stmt.Stmt;

import candle.all;

abstract class Stmt : Node {
public:
    void resolve() {
        // By default do nothing
    }
    void check() {
        // By default do nothing
    }
    override bool isResolved() { return true; }
}
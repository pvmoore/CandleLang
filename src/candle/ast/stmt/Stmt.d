module candle.ast.stmt.Stmt;

import candle.all;

abstract class Stmt : Node {
public:
    override bool isResolved() { return true; }
}
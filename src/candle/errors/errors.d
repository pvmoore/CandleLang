module candle.errors.errors;

import candle.all;

final class AbortCompilation : Exception {
    this() { super("Abort"); }
}

void syntaxError(Tokens t, string expected) {
    Candle candle = t.unit.getCandle();
    candle.addError(new SyntaxError(t, expected));
    throw new AbortCompilation();
}

void warn(Node n, string msg) {
    log("WARN: [%s '%s.can' line %s] %s", n.getProject().name, n.getUnit().name, n.coord.line+1, msg);
}

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

module candle.errors.errors;

import candle.all;

final class AbortCompilation : Error {
    this() { super("Abort"); }
}

void syntaxError(Tokens t, string expected) {
    Candle candle = t.unit.getCandle();
    candle.errors ~= new SyntaxError(t, expected);
    throw new AbortCompilation();
}

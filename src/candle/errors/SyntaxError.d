module candle.errors.SyntaxError;

import candle.all;

final class SyntaxError : CandleError {
public:
    this(Tokens t, string expected) {
        this.unit = t.unit;
        this.coord = t.coord();
        this.expected = expected;
    }
    string formatted() {
        string msg = "Syntax error. Expected %s".format(expected);
        return formattedError(unit, coord, msg);
    }
private:
    Unit unit;
    FileCoord coord;
    string expected;
}
module candle.errors.SyntaxError;

import candle.all;

final class SyntaxError : CandleError {
public:
    this(Tokens t, string expected) {
        this.unit = t.unit;
        this.coord = t.coord();
        this.message = "Expected " ~ expected;
    }
    this(Unit unit, FileCoord coord, string message) {
        this.unit = unit;
        this.coord = coord;
        this.message = message;
    }
    override string brief() {
        string msg = "Syntax error. %s".format(message);
        return formatBrief(unit, coord, msg);
    }
    override string verbose() {
        string msg = "Syntax error. %s".format(message);
        return formatVerboseMultiline(unit, coord, msg);
    }
    override bool isDuplicateOf(CandleError e) {
        auto other = e.as!SyntaxError;
        if(!other) return false;
        if(unit.id != other.unit.id) return false;
        if(coord != other.coord) return false;
        return true;
    }
private:
    Unit unit;
    FileCoord coord;
    string message;
}
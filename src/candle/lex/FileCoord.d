module candle.lex.FileCoord;

import candle.all;

struct FileCoord {
    uint pos;
    uint line;
    uint column;
    uint length;

    string toString() {
        return "{pos:%s, line:%s, col:%s, len:%s}".format(pos, line, column, length);
    }
}

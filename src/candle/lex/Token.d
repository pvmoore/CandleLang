module candle.lex.Token;

import candle.all;


__gshared Token NO_TOKEN = Token(EToken.NONE);

struct Token {
    EToken kind;
    FileCoord coord;

    string value(string src) {
        return src[coord.pos..coord.pos+coord.length];
    }

    string toString(string src) {
        if(lengthOf(kind)==0) {
            string value = value(src);
            return "Token(%s '%s', pos:%s len:%s line:%s col:%s)".format(stringOf(kind), value, coord.pos, value.length, coord.line, coord.column);
        }
        return toString();
    }
    string toString() {
        return "Token(%s, pos:%s line:%s col:%s)".format(kind, coord.pos, coord.line, coord.column);
    }
}

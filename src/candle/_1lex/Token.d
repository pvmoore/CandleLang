module candle._1lex.Token;

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
            return "Token(%s '%s', pos:%s len:%s line:%s)".format(stringOf(kind), value, coord.pos, value.length, coord.line);
        }
        return toString();
    }
    string toString() {
        return "Token(%s, pos:%s len:%s line:%s)".format(kind, coord.pos, coord.length, coord.line);
    }
}

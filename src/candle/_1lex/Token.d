module candle._1lex.Token;

import candle.all;


__gshared Token NO_TOKEN = Token(EToken.NONE);

struct Token {
    EToken kind;
    uint pos;
    uint length;
    uint line;
    uint column;

    string value(string src) {
        return src[pos..pos+length];
    }

    string toString(string src) {
        if(lengthOf(kind)==0) {
            string value = value(src);
            return "Token(%s '%s', pos:%s len:%s line:%s)".format(stringOf(kind), value, pos, value.length, line);
        }
        return toString();
    }
    string toString() {
        return "Token(%s, pos:%s len:%s line:%s)".format(kind, pos, length, line);
    }
}

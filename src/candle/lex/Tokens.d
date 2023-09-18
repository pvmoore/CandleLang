module candle.lex.Tokens;

import candle.all;

final class Tokens {
public:
    int pos;
    Unit unit;

    this(Unit unit) {
        this.unit = unit;
        this.src = unit.src;
        this.tokens = unit.tokens;
    }
    Token get(int offset = 0) {
        if(pos+offset >= tokens.length) return NO_TOKEN;
        return tokens[pos+offset];
    }
    FileCoord coord() {
        return get().coord;
    }
    string debugValue(int offset = 0) {
        return get(offset).toString(src);
    }
    EToken kind(int offset = 0) {
        return get(offset).kind;
    }
    string value(int offset = 0) {
        Token t = get(offset);
        if(lengthOf(t.kind)>0) return "";
        return t.value(src);
    }
    int length() {
        return tokens.length.as!int;
    }
    bool isKind(EToken k) {
        return kind() == k;
    }
    bool isOneOf(EToken[] kinds...) {
        EToken k = kind();
        foreach(tk; kinds) { if(tk == k) return true; }
        return false;
    }
    bool eof() {
        return pos >= tokens.length;
    }
    void next(int count = 1) {
        pos += count;
    }
    void skip(EToken k) {
        if(kind() != k) syntaxError(this, "'%s'".format(stringOf(k)));
        next();
    }
    void skip(string val) {
        if(value() != val) syntaxError(this, val);
        next();
    }
    void skipOptional(EToken k) {
        if(kind() == k) next();
    }
    bool matches(EToken[] kinds...) {
        foreach(i, k; kinds) {
            if(kind(i.as!int) != k) return false;
        }
        return true;
    }
    /**
     * Return the offset of the end of the scope.
     * Assumes we are at the start of a scope - one of (, [ or {
     */
    int findEndOfScope(int offset = 0) {
        EToken open = kind(offset);
        EToken close = open == EToken.LBRACKET ? EToken.RBRACKET :
                      open == EToken.LSQUARE ? EToken.RSQUARE :
                      open == EToken.LCURLY ? EToken.RCURLY : EToken.NONE;
        assert(close != EToken.NONE);

        int sc = 0, br = 0, sq = 0, cl = 0;
        int i = offset;
        while(pos+i < tokens.length) {
            EToken k = kind(i);
            switch(k) with(EToken) {
                case LBRACKET: br++; break;
                case RBRACKET: br--; break;
                case LSQUARE: sq++; break;
                case RSQUARE: sq--; break;
                case LCURLY: cl++; break;
                case RCURLY: cl--; break;
                default: break;
            }
            if(k==open) {
                sc++;
            } else if(k==close) {
                sc--;
                if(sc==0 && br==0 && sq==0 && cl==0) return i;
            }
            i++;
        }
        return i;
    }
    /**
     * pub
     * extern
     */
    void consumeModifiers() {
        this.isPublic = "pub" == value();
        if(this.isPublic) next();
        this.isExtern = "extern" == value();
        if(this.isExtern) next();
    }
    bool getAndResetPubModifier() {
        bool p = isPublic;
        isPublic = false;
        return p;
    }
    bool getAndResetExternModifier() {
        bool p = isExtern;
        isExtern = false;
        return p;
    }
    override string toString() {
        string buf = "Tokens{\n";
        foreach(i, t; tokens) {
            buf ~= "  %s\n".format(t.toString(src));
        }
        return buf ~ "}";
    }
private:
    string src;
    Token[] tokens;

    // Modifiers - reset after each Stmt
    bool isPublic;
    bool isExtern;
}
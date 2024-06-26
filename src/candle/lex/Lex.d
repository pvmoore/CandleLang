module candle.lex.Lex;

import candle.all;

final class Lex {
public:
    this(string src) {
        this.src = src;
    }
    Token[] lex() {
        while(pos<src.length) {
            char ch = peek(0);
            if(ch<33) {
                addToken();
                skipWhitespace();
            } else switch(ch) {
                case '/':
                    if(peek(1)=='/') {
                        addToken();
                        skipLineComment();
                    } else if(peek(1)=='*') {
                        addToken();
                        skipMultiLineComment();
                    } else if(peek(1)=='=') {
                        addToken(EToken.SLASH_EQ);
                    } else {
                        addToken(EToken.SLASH);
                    }
                    break;
                case '<':
                    if(peek(1)=='<' && peek(2)=='=') {
                        addToken(EToken.LT_LT_EQ);
                    } else if(peek(1)=='<') {
                        addToken(EToken.LT_LT);
                    } else if(peek(1)=='=') {
                        addToken(EToken.LT_EQ);
                    } else {
                        addToken(EToken.LT);
                    }
                    break;
                case '>':
                    if(peek(1)=='>' && peek(2)=='=') {
                        addToken(EToken.GT_GT_EQ);
                    } else if(peek(1)=='>') {
                        addToken(EToken.GT_GT);
                    } else if(peek(1)=='=') {
                        addToken(EToken.GT_EQ);
                    } else {
                        addToken(EToken.GT);
                    }
                    break;
                case '!':
                    if(peek(1)=='=') {
                        addToken(EToken.EXCLAIM_EQ);
                    } else {
                        addToken(EToken.EXCLAIM);
                    }
                    break;
                case '=':
                    if(peek(1)=='=') {
                        addToken(EToken.EQ_EQ);
                    } else {
                        addToken(EToken.EQ);
                    }
                    break;
                case '*':
                    if(peek(1)=='=') {
                        addToken(EToken.STAR_EQ);
                    } else {
                        addToken(EToken.STAR);
                    }
                    break;
                case '+':
                    if(peek(1)=='=') {
                        addToken(EToken.PLUS_EQ);
                    } else {
                        addToken(EToken.PLUS);
                    }
                    break;
                case '-':
                    if(peek(1)=='>') {
                        addToken(EToken.RT_ARROW);
                    } else if(peek(1)=='=') {
                        addToken(EToken.MINUS_EQ);
                    } else if(pos==tokenStart && peek(1).isDigit()) {
                        // this is a negative number
                        pos++;
                    } else {
                        addToken(EToken.MINUS);
                    }
                    break;
                case '%':
                    if(peek(1)=='=') {
                        addToken(EToken.PERCENT_EQ);
                    } else {
                        addToken(EToken.PERCENT);
                    }
                    break;
                case '&':
                    if(peek(1)=='=') {
                        addToken(EToken.AMP_EQ);
                    } else {
                        addToken(EToken.AMP);
                    }
                    break;
                case '|':
                    if(peek(1)=='=') {
                        addToken(EToken.PIPE_EQ);
                    } else {
                        addToken(EToken.PIPE);
                    }
                    break;
                case '^':
                    if(peek(1)=='=') {
                        addToken(EToken.HAT_EQ);
                    } else {
                        addToken(EToken.HAT);
                    }
                    break;
                case '\'':
                    addToken();
                    squote();
                    break;
                case '"':
                    addToken();
                    dquote();
                    break;
                case '.':
                    if(peek(1)=='.' && peek(2)=='.') {
                        addToken(EToken.ELIPSIS);
                    } else if(determineKind(src[tokenStart..pos])==EToken.NUMBER) {
                        // float literal
                        pos++;
                    } else {
                        addToken(EToken.DOT);
                    }
                    break;
                case '@': addToken(EToken.AT); break;
                case '~': addToken(EToken.TILDE); break;
                case '?': addToken(EToken.QMARK); break;
                case ',': addToken(EToken.COMMA); break;
                case ';': addToken(EToken.SEMICOLON); break;
                case ':': addToken(EToken.COLON); break;
                case '(': addToken(EToken.LBRACKET); break;
                case ')': addToken(EToken.RBRACKET); break;
                case '{': addToken(EToken.LCURLY); break;
                case '}': addToken(EToken.RCURLY); break;
                case '[': addToken(EToken.LSQUARE); break;
                case ']': addToken(EToken.RSQUARE); break;
                default:
                    // raw string?
                    if(ch=='r' && peek(1)=='"') {
                        addToken();
                        dquote();
                    } else {
                        pos++;
                    }
                    break;
            }
        }
        return tokens;
    }
private:
    string src;
    int pos;
    int line;
    int lineStart;
    int tokenStart;
    Token[] tokens;

    char peek(int offset) {
        return pos+offset >= src.length ? '\0' : src[pos+offset];
    }
    bool isEol() {
        return peek(0).isOneOf(10, 13);
    }
    void eol() {
        // can be 13,10 or just 10
        if(peek(0)==13) pos++;
        if(peek(0)==10) pos++;
        line++;
        lineStart = pos;
    }
    void skipWhitespace() {
        while(pos<src.length) {
            if(isEol()) {
                eol();
            } else if(peek(0) < 33) {
                pos++;
            } else {
                break;
            }
        }
        tokenStart = pos;
    }
    void skipLineComment() {
        while(pos<src.length) {
            if(isEol()) {
                eol();
                break;
            }
            pos++;
        }
        tokenStart = pos;
    }
    void skipMultiLineComment() {
        while(pos<src.length) {
            if(isEol()) {
                eol();
            } else if(peek(0)=='*' && peek(1)=='/') {
                pos+=2;
                break;
            } else {
                pos++;
            }
        }
        tokenStart = pos;
    }
    void squote() {
        // 'c'
        pos++;
        while(pos<src.length) {
            if(peek(0)=='\\' && peek(1)=='\\') {
                pos+=2;
            } else if(peek(0)=='\\' && peek(1)=='\'') {
                pos+=2;
            } else if(peek(0)=='\'') {
                pos++;
                addToken();
                break;
            } else {
                pos++;
            }
        }
    }
    void dquote() {
        // "string"
        // r"string"
        bool isRaw = peek(0) == 'r';
        if(isRaw) {
            pos++;
            // todo - Handle raw. We don't want to escape anything for raw strings 
        }
        pos++;
        while(pos<src.length) {
            if(peek(0)=='\\' && peek(1)=='\\') {
                pos+=2;
            } else if(peek(0)=='\\' && peek(1)=='"') {
                pos+=2;
            } else if(peek(0)=='"') {
                pos++;
                addToken();
                break;
            } else {
                pos++;
            }
        }
    }
    EToken determineKind(string s) {
        if(s.length==0) return EToken.ID;
        if(s[0]=='\'') return EToken.CHAR;
        if(s[0]=='"' || s.startsWith("r\"")) return EToken.STRING;
        if(isDigit(s[0])) return EToken.NUMBER;
        if(s.length>1 && s[0]=='-' && isDigit(s[1])) return EToken.NUMBER;
        if(s.length>1 && s[0]=='.' && isDigit(s[1])) return EToken.NUMBER;
        return EToken.ID;
    }
    void addToken(EToken k = EToken.NONE) {
        if(tokenStart < pos) {
            string value = src[tokenStart..pos];
            EToken tk2 = determineKind(value);
            int column = tokenStart-lineStart;
            tokens ~= Token(tk2, FileCoord(tokenStart, line, column, pos-tokenStart));
        }
        if(k != EToken.NONE) {
            int column = pos-lineStart;
            int len = lengthOf(k);
            tokens ~= Token(k, FileCoord(pos, line, column, len));
            pos += len;
        }
        tokenStart = pos;
    }
}

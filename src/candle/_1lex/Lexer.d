module candle._1lex.Lexer;

import candle.all;

final class Lexer {
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
                        addToken(TKind.SLASH_EQ);
                    } else {
                        addToken(TKind.SLASH);
                    }
                    break;
                case '<':
                    if(peek(1)=='<' && peek(2)=='=') {
                        addToken(TKind.LT_LT_EQ);
                    } else if(peek(1)=='<') {
                        addToken(TKind.LT_LT);
                    } else if(peek(1)=='=') {
                        addToken(TKind.LT_EQ);
                    } else {
                        addToken(TKind.LT);
                    }
                    break;
                case '>':
                    if(peek(1)=='>' && peek(2)=='=') {
                        addToken(TKind.GT_GT_EQ);
                    } else if(peek(1)=='>') {
                        addToken(TKind.GT_GT);
                    } else if(peek(1)=='=') {
                        addToken(TKind.GT_EQ);
                    } else {
                        addToken(TKind.GT);
                    }
                    break;
                case '!':
                    if(peek(1)=='=') {
                        addToken(TKind.EXCLAIM_EQ);
                    } else {
                        addToken(TKind.EXCLAIM);
                    }
                    break;
                case '=':
                    if(peek(1)=='=') {
                        addToken(TKind.EQ_EQ);
                    } else {
                        addToken(TKind.EQ);
                    }
                    break;
                case '*':
                    if(peek(1)=='=') {
                        addToken(TKind.STAR_EQ);
                    } else {
                        addToken(TKind.STAR);
                    }
                    break;
                case '+':
                    if(peek(1)=='=') {
                        addToken(TKind.PLUS_EQ);
                    } else {
                        addToken(TKind.PLUS);
                    }
                    break;
                case '-':
                    if(peek(1)=='=') {
                        addToken(TKind.MINUS_EQ);
                    } else {
                        addToken(TKind.MINUS);
                    }
                    break;
                case '%':
                    if(peek(1)=='=') {
                        addToken(TKind.PERCENT_EQ);
                    } else {
                        addToken(TKind.PERCENT);
                    }
                    break;
                case '&':
                    if(peek(1)=='&') {
                        addToken(TKind.AMP_AMP);
                    } else if(peek(1)=='=') {
                        addToken(TKind.AMP_EQ);
                    } else {
                        addToken(TKind.AMP);
                    }
                    break;
                case '|':
                    if(peek(1)=='|') {
                        addToken(TKind.PIPE_PIPE);
                    } else if(peek(1)=='=') {
                        addToken(TKind.PIPE_EQ);
                    } else {
                        addToken(TKind.PIPE);
                    }
                    break;
                case '^':
                    if(peek(1)=='=') {
                        addToken(TKind.HAT_EQ);
                    } else {
                        addToken(TKind.HAT);
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
                        addToken(TKind.ELIPSIS);
                    } else if(isDigit(peek(-1)) || isDigit(peek(1))) {
                        // float literal
                        pos++;
                    } else {
                        addToken(TKind.DOT);
                    }
                    break;
                case '@': addToken(TKind.AT); break;
                case '~': addToken(TKind.TILDE); break;
                case '?': addToken(TKind.QMARK); break;
                case ',': addToken(TKind.COMMA); break;
                case ';': addToken(TKind.SEMICOLON); break;
                case ':': addToken(TKind.COLON); break;
                case '(': addToken(TKind.LBRACKET); break;
                case ')': addToken(TKind.RBRACKET); break;
                case '{': addToken(TKind.LCURLY); break;
                case '}': addToken(TKind.RCURLY); break;
                case '[': addToken(TKind.LSQUARE); break;
                case ']': addToken(TKind.RSQUARE); break;
                default:
                    pos++;
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
        // " string "
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
    TKind determineKind(string s) {
        if(s.length==0) return TKind.ID;
        if(s[0]=='\'' || s.startsWith("L'")) return TKind.CHAR;
        if(s[0]=='"' || s.startsWith("L\"")) return TKind.STRING;
        if(isDigit(s[0])) return TKind.NUMBER;
        if(s.length>1 && s[0]=='-' && isDigit(s[1])) return TKind.NUMBER;
        if(s.length>1 && s[0]=='.' && isDigit(s[1])) return TKind.NUMBER;
        return TKind.ID;
    }
    void addToken(TKind k = TKind.NONE) {
        if(tokenStart < pos) {
            string value = src[tokenStart..pos];
            TKind tk2 = determineKind(value);
            int column = tokenStart-lineStart;
            tokens ~= Token(tk2, tokenStart, pos-tokenStart, line, column);
        }
        if(k != TKind.NONE) {
            int column = pos-lineStart;
            int len = lengthOf(k);
            tokens ~= Token(k, pos, len, line, column);
            pos += len;
        }
        tokenStart = pos;
    }
}
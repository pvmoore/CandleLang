module candle._1lex.LexerManager;

import candle.all;

final class LexerManager {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }
    static ulong getNumLexedFiles() { return atomicLoad(numFilesLexed); }

    static Token[] lex(string src) {
        auto lexer = new Lexer(src);
        auto tokens = lexer.lex();

        atomicOp!"+="(totalNanos, lexer.elapsedNanos());
        atomicOp!"+="(numFilesLexed, 1);
        return tokens;
    }
private:
    shared static ulong totalNanos;
    shared static ulong numFilesLexed;
}

private:

__gshared LexerManager lexerManager;

shared static this() {
    lexerManager = new LexerManager();
}
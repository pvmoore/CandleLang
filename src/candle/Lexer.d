module candle.Lexer;

import candle.all;

final class Lexer {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }
    static ulong getNumLexedFiles() { return atomicLoad(numFilesLexed); }

    static Token[] lex(string src) {
        StopWatch watch;
        watch.start();
        auto lexer = new Lex(src);
        auto tokens = lexer.lex();
        watch.stop();

        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        atomicOp!"+="(numFilesLexed, 1);
        return tokens;
    }
private:
    shared static ulong totalNanos;
    shared static ulong numFilesLexed;
}

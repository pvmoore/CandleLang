module candle.Parser;

import candle.all;

final class Parser {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void parse(Project project) {
        StopWatch watch;
        watch.start();
        logParse("  Parsing %s", project);
        foreach(u; project.getUnits()) {
            if(u.isParsed) return;

            logParse("  Parsing %s", u);
            Tokens tokens = new Tokens(u);
            //log("%s", tokens.toString());
            u.parse(tokens);
        }
        logParse("  Finished parsing %s", project);
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;
}
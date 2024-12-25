module candle.parse.Parser;

import candle.all;

final class Parser {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void parseUnit(Unit unit) {
        logParse("  Parsing %s", unit);
        auto watch = StopWatch(AutoStart.yes);
        Tokens tokens = new Tokens(unit);
        //log("%s", tokens.toString());
        
        unit.parse(tokens);

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;
}

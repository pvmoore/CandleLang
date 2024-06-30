module candle.parseandresolve.Parser;

import candle.all;

final class Parser {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void parseAllModules(Candle candle, int pass) {
        logParse("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; candle.allModules()) {
            parse(p);
        }
    }
private:
    shared static ulong totalNanos;
    
    static void parse(Module module_) {
        StopWatch watch;
        watch.start();
        logParse("  Parsing %s", module_);
        foreach(u; module_.getUnits()) {
            if(u.isParsed) continue;

            logParse("  Parsing %s", u);
            Tokens tokens = new Tokens(u);
            //log("%s", tokens.toString());
            u.parse(tokens);
        }
        logParse("  Finished parsing %s", module_);
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
}

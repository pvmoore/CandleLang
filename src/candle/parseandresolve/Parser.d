module candle.parseandresolve.Parser;

import candle.all;

final class Parser {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void parseAllProjects(Candle candle, int pass) {
        logParse("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; candle.allProjects()) {
            parse(p);
        }
    }
private:
    shared static ulong totalNanos;
    
    static void parse(Project project) {
        StopWatch watch;
        watch.start();
        logParse("  Parsing %s", project);
        foreach(u; project.getUnits()) {
            if(u.isParsed) continue;

            logParse("  Parsing %s", u);
            Tokens tokens = new Tokens(u);
            //log("%s", tokens.toString());
            u.parse(tokens);
        }
        logParse("  Finished parsing %s", project);
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
}
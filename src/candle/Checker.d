module candle.Checker;

import candle.all;

final class Checker {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void checkAllModules(Candle candle) {
        logCheck("Check ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; candle.allModules()) {
            check(p);
        }
    }
private:
    shared static ulong totalNanos;
    
    /** 
     * Check all Stmt Nodes from the bottom up
     */
    static void check(Module module_) {
        StopWatch watch;
        watch.start();
        foreach(u; module_.getUnits()) {
            recurseChildren(u);
        }
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
    static void recurseChildren(Node n) {
        foreach(ch; n.children) {
            recurseChildren(ch);
        }
        logCheck("Checking %s", n.enode());
        n.check();
    }
}

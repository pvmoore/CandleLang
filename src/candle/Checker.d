module candle.Checker;

import candle.all;

final class Checker {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }
    /** 
     * Check all Stmt Nodes from the bottom up
     */
    static void check(Project project) {
        StopWatch watch;
        watch.start();
        foreach(u; project.getUnits()) {
            recurseChildren(u);
        }
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;

    static void recurseChildren(Node n) {
        foreach(ch; n.children) {
            recurseChildren(ch);
        }
        n.check();
    }
}
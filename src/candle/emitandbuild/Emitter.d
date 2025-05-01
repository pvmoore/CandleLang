module candle.emitandbuild.Emitter;

import candle.all;
import candle.emitandbuild.clang.CEmitter;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emitAllModules(Candle candle) {
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        StopWatch watch;
        watch.start();

        auto moduleEmitter = new CEmitter(candle);
        moduleEmitter.emitAllModules();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;
}

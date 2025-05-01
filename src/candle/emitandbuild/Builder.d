module candle.emitandbuild.Builder;

import candle.all;
import candle.emitandbuild.clang.CBuilder;

final class Builder {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool buildAllModules(Candle candle) {
        logBuild("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        StopWatch watch;
        watch.start();

        auto moduleBuilder = new CBuilder(candle);
        bool result = moduleBuilder.buildAllModules();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");

        return result;
    }
private:
    shared static ulong totalNanos;
}

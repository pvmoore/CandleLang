module candle.emitandbuild.Builder;

import candle.all;

final class Builder {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool buildAllModules(Candle candle) {
        logBuild("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; candle.allModules()) {
            if(!build(p)) return false;
        }
        return true;
    }
private:
    shared static ulong totalNanos;

    static bool build(Module module_) {
        StopWatch watch;
        watch.start();

        auto builder = new BuildModule(module_);
        bool result = builder.build();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        return result;
    }
}

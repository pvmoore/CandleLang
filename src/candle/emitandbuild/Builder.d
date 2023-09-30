module candle.emitandbuild.Builder;

import candle.all;

final class Builder {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool buildAllProjects(Candle candle) {
        logBuild("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; candle.allProjects()) {
            if(!build(p)) return false;
        }
        return true;
    }
private:
    shared static ulong totalNanos;

    static bool build(Project project) {
        StopWatch watch;
        watch.start();

        auto builder = new BuildProject(project);
        bool result = builder.build();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        return result;
    }
}
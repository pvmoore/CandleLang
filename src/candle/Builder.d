module candle.Builder;

import candle.all;

final class Builder {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool build(Project project) {
        StopWatch watch;
        watch.start();

        auto builder = new BuildProject(project);
        bool result = builder.build();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        return result;
    }
private:
    shared static ulong totalNanos;
}
module candle.Emitter;

import candle.all;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emit(Project project) {
        StopWatch watch;
        watch.start();

        new EmitProject(project).emit();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;
}
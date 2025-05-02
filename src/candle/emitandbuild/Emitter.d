module candle.emitandbuild.Emitter;

import candle.all;
import candle.emitandbuild.clang.CLangEmitter;
import candle.emitandbuild.llvm.LLVMEmitter;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emitAllModules(Candle candle) {
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        StopWatch watch;
        watch.start();

        auto clangEmitter = new CLangEmitter(candle);
        clangEmitter.emitAllModules();

        // auto llvmEmitter = new LLVMEmitter(candle);
        // llvmEmitter.emitAllModules();

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
private:
    shared static ulong totalNanos;
}

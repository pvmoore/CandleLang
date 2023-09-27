module candle.emitandbuild.Emitter;

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
    static void emitCommonHeader(Candle candle) {
        string name = "candle__common.h";
        auto path = Filepath(candle.targetDirectory, Filename(name));
        File file = File(path.value, "wb");
        file.write(HEADER_CONTENT);
        file.close();
    }
private:
    shared static ulong totalNanos;

    static string HEADER_CONTENT = "
#ifndef CANDLE_COMMON_TYPEDEFS_H
#define CANDLE_COMMON_TYPEDEFS_H

typedef unsigned char bool;
typedef unsigned char u8;
typedef signed char s8;
typedef unsigned short u16;
typedef signed short s16;
typedef unsigned int u32;
typedef signed int s32;
typedef signed long long s64;
typedef unsigned long long u64;
typedef float f32;
typedef double f64;

#define true 1
#define false 0
#define null 0

#include \"stdlib.h\"
#include \"stdio.h\"

static void candle__assert(s32 value, const char* unitName, u32 line) {
    if(value == 0) {
        putchar(13); putchar(10);
        printf(\"!! Assertion failed: [%s] Line %u\", unitName, line);
        putchar(13); putchar(10);
        exit(-1);
    } 
}

#endif
";
}
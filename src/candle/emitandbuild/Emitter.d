module candle.emitandbuild.Emitter;

import candle.all;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emit(Candle candle) {
        StopWatch watch;
        watch.start();

        emitCommonHeader(candle); 

        foreach(p; candle.allProjects()) {
            emit(p);
        }

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
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
    static void emitCommonHeader(Candle candle) {
        string name = "candle__common.h";
        auto path = Filepath(candle.targetDirectory, Filename(name));
        File file = File(path.value, "wb");
        file.write(HEADER_CONTENT);
        file.close();
    }
    static void emit(Project project) {
        
        moveTopLevelTypesToProjectRoot(project);

        // Move all structs, unions, enums and aliases to Project and
        // Sort them by dependency
        // Then emit them all

        foreach(u; project.getUnits()) {
            reorderTopLevelTypes(u);
        }

        new EmitProject(project).emit();
    }
    /**
     * Move all struct, union, enum and alias nodes to the Project node so that we can order them properly.
     */
    static void moveTopLevelTypesToProjectRoot(Project project) {

    }

    /** 
     * Emit all struct, union, enum and alias nodes.
     */
    static void emitTopLevelTypes(Project project) {

    }

    /** 
     * Move structs so that a struct value that is included in another struct is defined first.
     * If there is a circular dependency then throw a SemanticError
     */
    static void reorderTopLevelTypes(Unit unit) {
        logResolve("Moving structs %s", unit.name);
        bool[ulong] mustComeBefore;
        bool updated = true;

        ulong makeKey(uint a, uint b) { return (a.as!ulong << 32) | b.as!ulong; }

        bool moveStruct(Struct v, Struct s) {
            ulong key = makeKey(v.id, s.id);
            if(key in mustComeBefore) {
                // Circular dependency
                s.getCandle().addError(new SemanticError(s, "Circular dependency between %s and %s".format(s.name, v.name)));
                return false;
            }
            mustComeBefore[key] = true;
            unit.moveToIndex(s.index(), v);
            logResolve("Moving struct %s above struct %s", v.name, s.name);
            return true;
        }

        while(updated) {
            updated = false;

            foreach(s; unit.getStructs()) {
                foreach(v; s.getContainedStructValues()) {
                    // Ensure v is before s
                    auto indexOfS = s.index();
                    auto indexOfV = v.index();
                    if(indexOfV > indexOfS) {
                        if(!moveStruct(v, s)) return;
                        updated = true;
                    }
                }
            }
        }
    }
}
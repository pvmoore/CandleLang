module candle.emitandbuild.Emitter;

import candle.all;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emitAllProjects(Candle candle) {
        StopWatch watch;
        watch.start();
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");

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
        reorderTopLevelTypes(project);

        new EmitProject(project).emit();
    }
    /**
     * Move all struct, union, enum and alias nodes to the Project node so that we can order them properly.
     */
    static void moveTopLevelTypesToProjectRoot(Project project) {
        foreach(unit; project.getUnits()) {
            foreach(ch; unit.children.dup) {
                if(Struct s = ch.as!Struct) {
                    project.add(s);
                } else if(Union u = ch.as!Union) {
                    project.add(u);
                } else if(Enum e = ch.as!Enum) {
                    project.add(e);
                } else if(Alias a = ch.as!Alias) {
                    project.add(a);
                }
            }
        }
    }
    /** 
     * Move private structs, unions, enums and aliases so that:
     * - a struct, union, enum or alias that is included in another struct|union is defined first.
     *
     * If there is a circular dependency then throw a SemanticError
     */
    static void reorderTopLevelTypes(Project project) {
        logResolve("Reordering top level structs, unions, enums and aliases %s", project.name);
        bool[ulong] mustComeBefore;
        bool updated = true;
        Candle candle = project.candle;

        ulong makeKey(uint a, uint b) { return (a.as!ulong << 32) | b.as!ulong; }

        bool moveNode(Node v, Node s) {
            ulong key = makeKey(v.id, s.id);
            if(key in mustComeBefore) {
                // Circular dependency
                candle.addError(new SemanticError(s, "Circular dependency between %s and %s".format(s, v)));
                return false;
            }
            mustComeBefore[key] = true;
            project.moveToIndex(s.index(), v);
            logResolve("Moving %s above %s", v, s);
            return true;
        }
        Type getValueType(Type t) {
            if(Struct s = t.as!Struct) return s.as!Struct;
            if(Union u = t.as!Union) return u.as!Union;
            if(Enum e = t.as!Enum) return e.as!Enum;
            if(Alias a = t.as!Alias) return a.as!Alias;
            if(TypeRef tr = t.as!TypeRef) return getValueType(tr.decorated);
            return null;
        }
        bool isInOrder(Type a, Type b) {
            auto indexOfA = a.as!Node.index();
            auto indexOfB = b.as!Node.index();
            return indexOfA < indexOfB;
        }

        while(updated) {
            updated = false;

            foreach(ch; project.children) {
                if(Struct s = ch.as!Struct) {
                    if(!s.isPublic) {
                        foreach(v; s.getContainedStructValues()) {
                            if(v.isPublic) continue;
                            // Ensure v is before s
                            auto indexOfS = s.index();
                            auto indexOfV = v.index();
                            if(indexOfV > indexOfS) {
                                if(!moveNode(v, s)) return;
                                updated = true;
                            }
                        }
                    }
                } else if(Union u = ch.as!Union) {
                    if(!u.isPublic) {
                     
                    }
                } else if(Enum e = ch.as!Enum) {
                    if(!e.isPublic) {
                     
                    }
                } else if(Alias a = ch.as!Alias) {
                    if(!a.isPublic) {
                        if(Type t = getValueType(a.toType())) {
                            if(!isPublic(t) && !isInOrder(t, a)) {
                                if(!moveNode(t.as!Node, a)) return;
                                updated = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
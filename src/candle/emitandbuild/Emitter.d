module candle.emitandbuild.Emitter;

import candle.all;

final class Emitter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void emitAllModules(Candle candle) {
        StopWatch watch;
        watch.start();
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");

        emitCommonHeader(candle); 

        foreach(p; candle.allModules()) {
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

#define _CRT_SECURE_NO_WARNINGS

typedef unsigned char __bool;
typedef unsigned char __u8;
typedef signed char __s8;
typedef unsigned short __u16;
typedef signed short __s16;
typedef unsigned int __u32;
typedef signed int __s32;
typedef signed long long __s64;
typedef unsigned long long __u64;
typedef float __f32;
typedef double __f64;

#define true 1
#define false 0
#define null 0

#include \"stdlib.h\"
#include \"stdio.h\"

static void candle__assert(__s32 value, const char* unitName, __u32 line) {
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
    static void emit(Module module_) {
        
        moveTopLevelTypesToModuleRoot(module_);
        reorderTopLevelTypes(module_);

        new EmitModule(module_).emit();
    }
    /**
     * Move all struct, union, enum and alias nodes to the Module node so that we can order them properly.
     */
    static void moveTopLevelTypesToModuleRoot(Module module_) {
        foreach(unit; module_.getUnits()) {
            foreach(ch; unit.children.dup) {
                if(Struct s = ch.as!Struct) {
                    module_.add(s);
                } else if(Union u = ch.as!Union) {
                    module_.add(u);
                } else if(Enum e = ch.as!Enum) {
                    module_.add(e);
                } else if(Alias a = ch.as!Alias) {
                    module_.add(a);
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
    static void reorderTopLevelTypes(Module module_) {
        logResolve("Reordering top level structs, unions, enums and aliases %s", module_.name);
        bool[ulong] mustComeBefore;
        bool updated = true;
        Candle candle = module_.candle;

        ulong makeKey(uint a, uint b) { return (a.as!ulong << 32) | b.as!ulong; }

        bool moveNode(Node v, Node s) {
            ulong key = makeKey(v.id, s.id);
            if(key in mustComeBefore) {
                candle.addError(new SemanticError(EError.CIRCDEP, s, "Circular dependency between %s and %s".format(s, v)));
                return false;
            }
            mustComeBefore[key] = true;
            module_.moveToIndex(s.index(), v);
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

            foreach(ch; module_.children) {
                if(Struct s = ch.as!Struct) {
                    bool pubFlag = s.isPublic;

                    foreach(vt; s.getVarTypes()) {
                        Type v = getValueType(vt);
                        if(v && isPublic(v) == pubFlag && !isInOrder(v, s)) {
                            if(!moveNode(v.as!Node, s)) return;
                            updated = true;
                        }
                    }
                } else if(Union u = ch.as!Union) {
                    bool pubFlag = u.isPublic;
                     
                    
                } else if(Enum e = ch.as!Enum) {
                    bool pubFlag = e.isPublic;

                } else if(Alias a = ch.as!Alias) {
                    bool pubFlag = a.isPublic;

                    if(Type t = getValueType(a.toType())) {
                        if(pubFlag == isPublic(t) && !isInOrder(t, a)) {
                            if(!moveNode(t.as!Node, a)) return;
                            updated = true;
                        }
                    }
                }
            }
        }
    }
}

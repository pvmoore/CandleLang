module candle.Resolver;

import candle.all;

final class Resolver {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool resolve(Project project) {
        StopWatch watch;
        watch.start();
        logResolve("  Resolving %s", project);
        bool allResolved = true;

        foreach(u; project.getUnits()) {
            recurseChildren(u, allResolved);
        }
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        return allResolved;
    }
    static void afterAllResolved(Project[] allProjects) {
        StopWatch watch;
        watch.start();

        foreach(p; allProjects) {
            foreach(u; p.getUnits()) {
                moveStructs(u);
            }
        }

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
    /**
     * Try to resolve the type of a Node using the parent's type.
     * Note that the returned Type is the same reference to the parent's Type and not wrapped.
     * Returns null if the Type is not yet resolved
     */
    static Type resolveTypeFromParent(Node n) {
        Type t = null;
        switch(n.parent.enode()) with(ENode) {
            case VAR:
                // n is a var initialiser 
                t = n.parent.type(); 
                break;
            case BINARY: {
                Binary b = n.parent.as!Binary;
                if(n.id == b.right().id) {
                    if(b.left().isResolved()) {
                        t = b.left().type();
                    }
                }
                break;
            }
            case CALL: {
                // n is an argument. We need the call to be resolved before we know what our Type is
                if(n.parent.isResolved()) {
                    int i = n.index();
                    assert(i!=-1);

                    Target target = n.parent.as!Call.target;
                    if(Func f = target.type().as!Func) {
                        Type[] params = f.paramTypes();
                        if(i < params.length) {
                            t = params[i];
                        } else {
                            // This Target is invalid
                        }
                    } else {
                        // Either the target Type is not resolved or this Target is invalid
                    }
                }
                break;
            }
            default:
                throwIf(true, "Handle Resolver.resolveTypeFromParent %s", n.parent.enode());
                break;
        }
        return t;
    }
private:
    shared static ulong totalNanos;

    static void recurseChildren(Node n, ref bool allResolved) {
        foreach(ch; n.children) {
            recurseChildren(ch, allResolved);
        }
        if(n.isAttached()) {
            logResolve("Resolving %s", n.enode());
            n.resolve();
            if(n.isAttached()) {
                allResolved &= n.isResolved();
            }
        }
    }
    /** 
     * Move structs so that a struct value that is included in another struct is defined first.
     * If there is a circular dependency then throw a SemanticError
     */
    static void moveStructs(Unit unit) {
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
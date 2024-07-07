module candle.parseandresolve.Resolver;

import candle.all;

final class Resolver {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static bool resolveAllModules(Candle candle, int pass) {
        logResolve("Resolve (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        bool allResolved = true;
        foreach(m; candle.allModules()) {
            allResolved &= Resolver.resolve(m);
        }
        logResolve("  All resolved = %s", allResolved);

        if(allResolved && candle.hasErrors()) {
            afterAllResolved(candle.allModules());
        }

        return allResolved;
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

    static bool resolve(Module module_) {
        StopWatch watch;
        watch.start();
        logResolve("Resolving %s", module_);
        bool allResolved = true;

        foreach(u; module_.getUnits()) {
            recurseChildren(u, allResolved);
        }
        logResolve("%s Resolved = %s", module_, allResolved);
        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
        return allResolved;
    }
    static void afterAllResolved(Module[] allProjects) {
        StopWatch watch;
        watch.start();

        // Nothing to do at the moment

        watch.stop();
        atomicOp!"+="(totalNanos, watch.peek().total!"nsecs");
    }
    static void recurseChildren(Node n, ref bool allResolved) {
        foreach(ch; n.children) {
            recurseChildren(ch, allResolved);
        }
        if(n.isAttached()) {
            logResolve("  Resolving %s", n.enode());
            n.resolve();
            if(n.isAttached()) {
                allResolved &= n.isResolved();
            }
        }
    }
}

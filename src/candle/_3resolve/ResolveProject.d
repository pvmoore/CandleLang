module candle._3resolve.ResolveProject;

import candle.all;

final class ResolveProject {
public:
    this(Project project) {
        this.candle = project.candle;
        this.project = project;
    }
    bool resolve() {
        allResolved = true;

        foreach(u; project.getUnits()) {
            recurseChildren(u);
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
            case VAR: t = n.parent.type(); break;
            case CALL: {
                // We are an argument. We need the call to be resolved before we know what our Type is
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
                throwIf(true, "Handle ResolveProject.resolveTypeFromParent %s", n.parent.enode());
                break;
        }
        return t;
    }
private:
    Candle candle;
    Project project;
    bool allResolved;

    void recurseChildren(Node n) {
        foreach(ch; n.children) {
            recurseChildren(ch);
        }
        if(!n.isResolved()) {
            n.resolve();
            allResolved &= n.isResolved();
        }
    }
}
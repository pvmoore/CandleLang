module candle._3resolve.ResolveProject;

import candle.all;

final class ResolveProject {
public:
    this(Project project) {
        this.project = project;
    }
    bool resolve() {
        allResolved = true;

        resolveChildren(project);

        return allResolved;
    }
private:
    Project project;
    bool allResolved;

    void resolveChildren(Node n) {
        foreach(ch; n.children) {
            resolve(ch);
        }
    }

    void resolve(Node n) {
        logResolve("resolve %s", n);
        switch(n.enode()) with(ENode) {
            case BINARY: resolve(n.as!Binary); break;
            case CALL: resolve(n.as!Call); break;
            case CHAR: resolve(n.as!Char); break;
            case DOT: resolve(n.as!Dot); break;
            case FUNC: resolve(n.as!Func); break;
            case ID: resolve(n.as!Id); break;
            case NODE_REF: resolve(n.as!NodeRef); break;
            case NULL: resolve(n.as!Null); break;
            case NUMBER: resolve(n.as!Number); break;
            case POINTER: resolve(n.as!Pointer); break;
            case PRIMITIVE: resolve(n.as!Primitive); break;
            case PROJECT_ID: resolve(n.as!ProjectId); break;
            case RETURN: resolve(n.as!Return); break;
            case SCOPE: resolve(n.as!Scope); break;
            case STRUCT: resolve(n.as!Struct); break;
            case TYPE_REF: resolve(n.as!TypeRef); break;
            case UNARY: resolve(n.as!Unary); break;
            case UNIT: resolve(n.as!Unit); break;
            case VAR: resolve(n.as!Var); break;
            default:
                throw new Exception("ResolveProject: Handle node %s".format(n.enode()));
        }

        logResolve("  %s resolved = %s", n, n.isResolved());
        allResolved &= n.isResolved();
    }

    void resolve(Binary n) {
        resolveChildren(n);
        n.resolve();
    }
    void resolve(Call n) {
        if(!n.isResolved()) {
            logResolve("  resolving %s", n);

            if(n.isStartOfChain()) {
                Target target = findCallTarget(n);
                if(target) {
                    logResolve("    found target %s", target);
                    n.target = target;
                }
            } else {
                Node prev = n.prevLink();
                logResolve("  prev = %s", prev);
                if(!prev.isResolved()) return;

                Target target = findCallTarget(n, prev);
                if(target) {
                    logResolve("    found target %s", target);
                    n.target = target;
                }
            }
        }
        resolveChildren(n);
    }
    void resolve(Char n) {
        // Assume this is resolved
    }
    void resolve(Dot n) {
        resolveChildren(n);
    }
    void resolve(Func n) {
        resolveChildren(n);
    }
    void resolve(Id n) {
        if(!n.isResolved()) {
            logResolve("  resolving %s", n);

            if(n.isStartOfChain()) {
                Target target = findIdTarget(n);
                if(target) {
                    logResolve("    found target %s", target);
                    n.target = target;
                }
            } else {
                Node prev = n.prevLink();
                log("  prev = %s", prev);
                if(!prev.isResolved()) return;

                Target target = findIdTarget(n, prev);
                if(target) {
                    logResolve("    found target %s", target);
                    n.target = target;
                }
            }
        }
    }
    void resolve(NodeRef n) {
        resolveChildren(n);
    }
    void resolve(Null n) {
        if(!n.isResolved()) {
            n.setType(resolveTypeFromParent(n));
        }
    }
    void resolve(Number n) {
        // Assume this is resolved
    }
    void resolve(Pointer n) {
        resolveChildren(n);
    }
    void resolve(Primitive n) {
        // Assume this is resolved
    }
    void resolve(ProjectId n) {
        // Assume this is resolved if it can be
    }
    void resolve(Return n) {
        resolveChildren(n);
    }
    void resolve(Scope n) {
        resolveChildren(n);
    }
    void resolve(Struct n) {
        resolveChildren(n);
    }
    void resolve(TypeRef n) {
        if(!n.isResolved()) {
            if(!n.decorated) {
                n.decorated = findType(n.project, n.name);
            }
        }
    }
    void resolve(Unary n) {
        resolveChildren(n);
    }
    void resolve(Unit n) {
        resolveChildren(n);

        writeAst(n);
    }
    void resolve(Var n) {
        resolveChildren(n);
    }

    /**
     * Try to resolve the type of a Node using the parent's type.
     * Note that the returned Type is the same reference to the parent's Type and not wrapped.
     * Returns null if the Type is not yet resolved
     */
    Type resolveTypeFromParent(Node n) {
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
}
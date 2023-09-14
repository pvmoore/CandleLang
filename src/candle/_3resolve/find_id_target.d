module candle._3resolve.find_id_target;

import candle.all;

// TODO - gather all name matches to see if there is any ambiguity

/**
 * Scan backwards in the current function body to find the Var with given name.
 * All enclosing Struct Vars and Funcs will be checked (if we are inside a Struct function)
 * All enclosing Union Vars and Funcs will be checked (if we are inside a Union function)
 * All Unit Vars and Funcs will be checked.
 * All public Funcs, Structs and Unions will be checked in surrounding Projects
 */
Target findIdTarget(Id id) {
    logResolve("findIdTarget %s", id.name);
    bool weAreInAFunc = id.hasAncestor!Func;
    bool weAreInAStruct = id.hasAncestor!Struct;
    bool weAreInAUnion = id.hasAncestor!Union;

    // Check the surrounding Func if we are inside a Func
    if(weAreInAFunc) {
        Node n = id;
        while((n = n.prev()) !is null && !n.isA!Func) {
            if(Var v = n.as!Var) {
                if(v.name == id.name) return new Target(v);
            }
        }
    }

    // Check struct members
    if(weAreInAStruct) {
        Struct s = id.getAncestor!Struct;
        assert(s);

        Var v = s.getVar(id.name);
        if(v) { return new Target(v); }

        // Func f = s.getFunc(name);
        // if(f) return new Target(f);
    }

    // Check union members
    if(weAreInAUnion) {
        Union u = id.getAncestor!Union;
        assert(u);

        Var v = u.getVar(id.name);
        if(v) { return new Target(v); }

        // Func f = u.getFunc(name);
        // if(f) return new Target(f);
    }

    // Check all Unit members
    Project project = id.getProject();
    foreach(unit; project.getUnits()) {
        Var v = unit.getVar(id.name);
        if(v) return new Target(v);

        Func[] f = unit.getFuncs(id.name, true);
        if(f.length==1) return new Target(f[0]);
        if(f.length > 1) {
            // We have more then one name match. This is ambiguous since we only have the name
            throw new Exception("findIdTarget: Ambiguous function name match. Found %s".format(f));
        }
    }

    // Check external Projects
    foreach(p; project.getExternalProjects()) {
        foreach(unit; p.getUnits()) {
            // We only want public Funcs here
            Func[] f = unit.getFuncs(id.name, false);
            if(f.length==1) return new Target(f[0]);
            if(f.length > 1) {
                // We have more then one name match. This is ambiguous since we only have the name
                throw new Exception("findIdTarget: Ambiguous function name match. Found %s".format(f));
            }
        }
    }

    return null;
}
/**
 *  Find the callee Var or Func which must be a member of prev.
 *  Assume: prev must be one of:
 *    - ProjectId
 *    - Struct
 *    - Union
 *
 *  Assume:
 *    - prev is resolved
 */
Target findIdTarget(Id id, Node prev) {
    logResolve("findIdTarget %s (member)", id.name);
    switch(prev.enode()) with(ENode) {
        case PROJECT_ID: {
            ProjectId pid = prev.as!ProjectId;
            Project project = pid.project;
            foreach(u; project.getUnits()) {

                if(auto var = u.getVar(id.name)) return new Target(var).setExternal();

                Func[] funcs = u.getFuncs(id.name, false);
                if(funcs.length == 1) return new Target(funcs[0]).setExternal();
                if(funcs.length > 1) {
                    // We have more then one name match. This is ambiguous since we only have the name
                    throw new Exception("findIdTarget: Ambiguous function name match. Found %s".format(funcs));
                }
            }
            break;
        }
        case STRUCT:
        case UNION:
            break;
        default: throw new Exception("findIdTarget: Handle node %s".format(prev.enode()));
    }
    return null;
}
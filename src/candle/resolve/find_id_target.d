module candle.resolve.find_id_target;

import candle.all;

// TODO - gather all name matches to see if there is any ambiguity

/**
 * Scan backwards in the current function body to find the Var with given name.
 * All enclosing Struct Vars and Funcs will be checked (if we are inside a Struct function)
 * All enclosing Union Vars and Funcs will be checked (if we are inside a Union function)
 * All Unit Vars and Funcs will be checked.
 * All public Funcs, Structs and Unions will be checked in surrounding Modules
 */
Target findIdTarget(Id id) {
    logResolve("findIdTarget %s", id.name);
    bool weAreInAFunc = id.hasAncestor!Func;
    //bool weAreInAStruct = id.hasAncestor!Struct;
    //bool weAreInAUnion = id.hasAncestor!Union;

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
    /+
    if(weAreInAStruct) {
        Struct s = id.getAncestor!Struct;
        assert(s);

        Var v = s.getVar(id.name);
        if(v) { return new Target(v); }

        // Func f = s.getFunc(name);
        // if(f) return new Target(f);
    }+/

    // Check union members
    /+if(weAreInAUnion) {
        Union u = id.getAncestor!Union;
        assert(u);

        Var v = u.getVar(id.name);
        if(v) { return new Target(v); }

        // Func f = u.getFunc(name);
        // if(f) return new Target(f);
    }+/

    // Check all Unit members
    Module module_ = id.getModule();
    foreach(unit; module_.getUnits()) {
        Var v = unit.getVar(id.name, Visibility.ALL);
        if(v) return new Target(v);

        Func[] f = unit.getFuncs(id.name, Visibility.ALL);
        if(f.length==1) return new Target(f[0]);
        if(f.length > 1) {
            // We have more then one name match. This is ambiguous since we only have the name
            throw new Exception("findIdTarget: Ambiguous function name match. Found %s".format(f));
        }
    }

    // Check public members of external Modules where unqualified-access = true
    foreach(p; module_.getUnqualifiedExternalModules()) {
        foreach(unit; p.getUnits()) {
            // We only want public Funcs here
            Func[] f = unit.getFuncs(id.name, Visibility.PUBLIC);
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
 *    - ModuleId
 *    - Id of Struct
 *    - Id of Union
 *    - Enum
 *    - LiteralStruct
 *    - Call
 *
 *  Assume:
 *    - prev is resolved
 */
Target findIdTarget(Id id, Node prev) {
    logResolve("findIdTarget %s.%s", prev.enode(), id.name);
    assert(prev.isResolved());

    Candle candle = id.getCandle();

    switch(prev.enode()) with(ENode) {
        case MODULE_ID: {
            ModuleId pid = prev.as!ModuleId;
            Module module_ = pid.module_;
            foreach(u; module_.getUnits()) {

                // Is it a UDT?
                if(module_.isUserDefinedType(id.name, false)) {
                    todo("this is a user defined type");
                }

                // Is it a Var? 
                if(auto var = u.getVar(id.name, Visibility.PUBLIC)) { 
                    candle.addError(new SemanticError(EError.SNV, id, "External module variables are not accesible"));
                    return null;
                }

                // Is it a Func?
                Func[] funcs = u.getFuncs(id.name, Visibility.PUBLIC);
                if(funcs.length == 1) return new Target(funcs[0]).setInExternalModule();
                if(funcs.length > 1) {
                    // We have more then one name match. This is ambiguous since we only have the name
                    throw new Exception("findIdTarget: Ambiguous function name match. Found %s".format(funcs));
                }
            }
            break;
        }
        case ID: {
            Struct struct_ = prev.type().getStruct();
            if(struct_) {
                bool isExternal = struct_.getModule().id != id.getModule().id;
                if(auto var = struct_.getVar(id.name, !isExternal)) {
                    return new Target(var);
                } 
            } else {
                todo("handle %s".format(prev.type().etype()));
            }
            break;
        }
        case LITERAL_STRUCT:
        case CALL:
            // todo
        default: 
            throw new Exception("findIdTarget: Handle prev node %s".format(prev.enode()));
    }
    return null;
}

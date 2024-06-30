module candle.parseandresolve.find_call_target;

import candle.all;

/**
 *  Find the callee non-member Func
 */
Target findCallTarget(Call call) {
    logResolve("findCallTarget %s", call.name);
    //bool weAreInAStruct = call.hasAncestor!Struct;
    //bool weAreInAUnion = call.hasAncestor!Union;

    Func[] matches;

    // Check struct members (if we are inside a Struct Func)
    // if(weAreInAStruct) {
    //     Struct s = call.getAncestor!Struct;
    //     assert(s);

    //     matches ~= s.getFuncs(call.name);
    // }

    // Check union members (if we are inside a Union Func)
    // if(weAreInAUnion) {
    //     Union u = call.getAncestor!Union;
    //     assert(u);

    //     matches ~= u.getFuncs(call.name);
    // }

    // Check all Module functions
    Module module_ = call.getModule();
    foreach(unit; module_.getUnits()) {
        matches ~= unit.getFuncs(call.name, Visibility.ALL);
    }

    // Check public members of external Modules where unqualified-access = true
    foreach(p; module_.getUnqualifiedExternalModules()) {
        foreach(unit; p.getUnits()) {
            // We only want public Funcs here
            matches ~= unit.getFuncs(call.name, Visibility.PUBLIC);
        }
    }

    if(matches.length > 1) {
        filterOverloadsByNumArgs(call, matches);
    }

    if(matches.length > 1) {
        if(!call.args().areResolved()) {
            // We cannot proceed until the Call args are known
            return null;
        }

        filterOverloadsByArgType(call, matches);
    }

    if(matches.length == 1) {
        return new Target(matches[0]);
    }
    if(matches.length==0) {
        // Handle no match
    }

    return null;
}

/**
 *  Find the callee Func which must be a member of prev.
 *  Assume: prev must be one of:
 *    - ModuleId
 *    - Struct
 *    - Union
 *
 *  Assume:
 *    - prev is resolved
 */
Target findCallTarget(Call call, Node prev) {
    throwIf(!prev.isResolved());

    logResolve("findCallTarget %s (member)", call.name);
    switch(prev.enode()) with(ENode) {
        case MODULE_ID: {
            ModuleId pid = prev.as!ModuleId;
            Module module_ = pid.module_;
            foreach(u; module_.getUnits()) {

                Func[] funcs = u.getFuncs(call.name, Visibility.PUBLIC);
                if(funcs.length == 1) return new Target(funcs[0]).setInExternalModule();
                if(funcs.length > 1) {
                    // We have more then one name match
                    throw new Exception("findCallTarget: Handle overloads. Found %s".format(funcs));
                }
            }
            break;
        }
        case STRUCT:
        case UNION:
            break;
        default: throw new Exception("findTarget: Handle node %s".format(prev.enode()));
    }
    return null;
}

private:

/**
 *  Filter out any overloads that do not have the correct number of arguments.
 *  This can be done without all the Types being resolved
 */
void filterOverloadsByNumArgs(Call call, ref Func[] matches) {

    // We need the Call args to be resolved at this point
    // And the matches parameters also

    throw new Exception("filterOverloadsByNumArgs: Handle overloads. call unit = %s Found %s".format(call.getUnit(), matches));
}

/**
 *  Remove matches based on argument and parameter Types.
 *  Assume: Call args are resolved
 *          Overload Func parameters may not be resolved yet
 */
void filterOverloadsByArgType(Call call, ref Func[] matches) {

    throw new Exception("filterOverloadsByArgType: Handle overloads. Found %s".format(matches));
}

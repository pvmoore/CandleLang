module candle.resolve.find_type;

import candle.all;

/**
 * Attempt to find a Type with the specified 'name'. 
 * If 'inExternalModule' is true then we are looking in a different module 
 * to the requesting node meaning we should only check public Types.
 */
Type findType(Module module_, string name, bool inExternalModule = false) {
    logResolve("findType %s%s", name, inExternalModule ? " (external)" : "");

    auto visibility = Visibility.ALL;

    if(inExternalModule) {
        visibility = Visibility.PUBLIC;
    }

    // Check current Module units
    foreach(unit; module_.getUnits()) {
        logResolve("  Checking unit %s", unit.name);
        if(Struct s = unit.getStruct(name, visibility)) {
            logResolve("    found %s", s);
            return s;
        }
        if(Union u = unit.getUnion(name, visibility)) {
            logResolve("    found %s", u);
            return u;
        }
        if(Alias a = unit.getAlias(name, visibility)) {
            logResolve("    found %s", a);
            return a;
        }
    }

    if(!inExternalModule) {
        // Check unqualified external modules for public Types
        foreach(m; module_.getUnqualifiedExternalModules()) {
            logResolve("  Checking unqualified external module '%s'", m.name);

            if(Type t = findType(m, name, true)) {
                logResolve("    found externally %s", t);
                return t;
            }
        }
    }

    logResolve("  not found %s", name);

    return null;
}

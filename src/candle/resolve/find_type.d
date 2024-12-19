module candle.resolve.find_type;

import candle.all;

/**
 * Attempt to find a Type with the specified 'name'. If 'inExternalModule' is true then we are looking in a
 * different module to the requesting node meaning we should only check public Types.
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

bool isType(Module module_, Tokens t) {
    // if(t.kind() == EToken.LBRACKET) {
    //     bool ifp = isFunctionPtr(module_, t);
    //     if(ifp) syntaxError(t, "fp syntax");
    //     return ifp;
    // }
    if(t.kind() != EToken.ID) return false;
    if(isFunctionPtrNew(module_, t)) return true;
    if(isPrimitiveType(t)) return true;
    if(isUserType(module_, t)) return true;

    // Is it a type in one of the unqualified external Modules?
    foreach(m; module_.getUnqualifiedExternalModules()) {
        if(isUserType(m, t)) return true;
    }

    bool isModuleId = t.isKind(EToken.ID) && module_.isModuleName(t.value());

    if(isModuleId) {
        // std.foo(
        with(EToken) if(t.matches(ID, DOT, ID, LBRACKET)) return false;

        // std.struct
        with(EToken) if(t.matches(ID, DOT, ID)) return true;
    }
    return false;
}

/**
 * Find the offset of the end of the type. Assumes we are at the start of a Type
 */
int typeLength(Tokens t) {
    int pos = t.pos;
    int offset;

    // function ptr
    if(t.isValue("func")) {
        t.pushState();
        t.skip(EToken.ID);
        t.skip(EToken.LBRACKET);

        while(!t.isKind(EToken.RBRACKET)) {
            int len = typeLength(t);
            assert(len != 0);
            t.next(len);
            t.skipOptional(EToken.ID);
            t.skipOptional(EToken.COMMA);
            t.skipOptional(EToken.RT_ARROW);
        }
        t.skip(EToken.RBRACKET);
        int end = t.pos;
        t.popState();
        log("function ptr length = %s to %s (%s)", pos, end, end-pos);
        offset = end - pos;

    } else if(t.isKind(EToken.LBRACKET)) {
        // function ptr old

        t.pushState();
        t.next();
        while(!t.isKind(EToken.RBRACKET)) {
            int len = typeLength(t);
            assert(len != 0);
            t.next(len);
            t.skipOptional(EToken.ID);
            t.skipOptional(EToken.COMMA);
            t.skipOptional(EToken.RT_ARROW);
        }
        t.skip(EToken.RBRACKET);
        int end = t.pos;
        t.popState();
        log("function ptr length = %s to %s (%s)", pos, end, end-pos);
        offset = end - pos;
    } else {
        assert(t.isKind(EToken.ID));
        offset = 1;

        // std.struct
        with(EToken) if(t.matches(ID, DOT, ID)) {
            offset += 2;
        }

        if(t.isKind(EToken.LSQUARE)) {
            int i = t.findEndOfScope(offset);
            offset += i + 1;
        }
    }

    while(t.isKind(EToken.STAR, offset)) {
        offset++;
    }

    t.pos = pos;
    return offset;
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

/**
 * eg. func(void->void) 
 *     func(int a, int b -> int)
 */
bool isFunctionPtrNew(Module module_, Tokens t) {
    return t.isValue("func") && t.isKind(EToken.LBRACKET, 1);
}

/**
 * eg. (void->void) 
 *     (int a, int b -> int)
 */
// bool isFunctionPtrOld(Module module_, Tokens t) {
//     if(t.kind() != EToken.LBRACKET) return false;
//     t.pushState();

//     // (
//     t.skip(EToken.LBRACKET);

//     // () is not a function ptr
//     bool happy = !t.isKind(EToken.RBRACKET);

//     while(happy && !t.isKind(EToken.RBRACKET)) {
//         if(isType(module_, t)) {
//             int len = typeLength(t);
//             t.next(len);
//         } else {
//             happy = false;
//             break;
//         }
//         t.skipOptional(EToken.ID);
//         t.skipOptional(EToken.COMMA);
//         t.skipOptional(EToken.RT_ARROW);
//     }
//     t.popState();
//     return happy;
// }

bool isPrimitiveType(Tokens t) {
    switch(t.value()) {
        case "bool":
        case "byte": case "ubyte":
        case "short": case "ushort":
        case "int": case "uint":
        case "long": case "ulong":
        case "float":
        case "double":
        case "void":
            return true;
        default:
            return false;
    }
}
bool isUserType(Module module_, Tokens t) {
    return module_.isDeclaredType(t.value());
}

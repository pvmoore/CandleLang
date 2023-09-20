module candle.resolve.find_type;

import candle.all;


Type findType(Project project, string name) {
    logResolve("findType %s", name);

    foreach(unit; project.getUnits()) {
        logResolve("  Checking unit %s", unit.name);
        if(Struct s = unit.getStruct(name)) {
            logResolve("    found %s", s);
            return s;
        }
        if(Union u = unit.getUnion(name)) {
            logResolve("    found %s", u);
            return u;
        }
    }

    foreach(p; project.getExternalProjects()) {
        //logResolve("  Checking external project %s", p.name);

        // todo - the external Project may not yet be parsed
        //if(Type t = findType(p, name)) {
        //    return t;
        //}
        // If we get here then either:
        // - The external Project is not ready or
        // - The type does not exist in the external Project or
        // -
    }

    logResolve("  not found %s", name);

    return null;
}

bool isType(Project project, Tokens t) {
    if(t.kind() == EToken.LBRACKET) {
         return isFunctionPtr(project, t);
    }
    if(t.kind() != EToken.ID) return false;
    if(isPrimitiveType(t)) return true;
    if(isUserType(project, t)) return true;

    bool isProjectId = t.isKind(EToken.ID) && project.isProjectName(t.value());

    if(isProjectId) {
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
    if(t.isKind(EToken.LBRACKET)) {
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
 * eg. (void->void) 
 *     (int a, int b -> int)
 */
bool isFunctionPtr(Project project, Tokens t) {
    if(t.kind() != EToken.LBRACKET) return false;
    t.pushState();
    t.skip(EToken.LBRACKET);
    bool happy = true;
    while(happy && !t.isKind(EToken.RBRACKET)) {
        if(isType(project, t)) {
            int len = typeLength(t);
            t.next(len);
        } else {
            happy = false;
            break;
        }
        t.skipOptional(EToken.ID);
        t.skipOptional(EToken.COMMA);
        t.skipOptional(EToken.RT_ARROW);
    }
    t.popState();
    return happy;
}

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
bool isUserType(Project project, Tokens t) {
    return project.isDeclaredType(t.value());
    //return findType(project, t.value()) !is null;
}

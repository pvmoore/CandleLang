module candle.parse.parse_type;

import candle.all;

void parseType(Node parent, Tokens t) {
    logParse("parseType %s", t.debugValue());
    Project project = parent.getProject();
    string value = t.value();

    Node type;

    switch(value) {
        case "bool": type = makeNode!Primitive(t.coord(), EType.BOOL); break;
        case "byte": type = makeNode!Primitive(t.coord(), EType.BYTE); break;
        case "ubyte": type = makeNode!Primitive(t.coord(), EType.UBYTE); break;
        case "short": type = makeNode!Primitive(t.coord(), EType.SHORT); break;
        case "ushort": type = makeNode!Primitive(t.coord(), EType.USHORT); break;
        case "int": type = makeNode!Primitive(t.coord(), EType.INT); break;
        case "uint": type = makeNode!Primitive(t.coord(), EType.UINT); break;
        case "long": type = makeNode!Primitive(t.coord(), EType.LONG); break;
        case "ulong": type = makeNode!Primitive(t.coord(), EType.ULONG); break;
        case "float": type = makeNode!Primitive(t.coord(), EType.FLOAT); break;
        case "double": type = makeNode!Primitive(t.coord(), EType.DOUBLE); break;
        case "void": type = makeNode!Primitive(t.coord(), EType.VOID); break;
        default: break;
    }

    // Is it a user defined type?
    if(!type) {
        Project typeProject = project;
        bool isExternal = false;

        bool isProjectId = t.isKind(EToken.ID) && project.isProjectName(value);
        if(isProjectId) {
            typeProject = project.getDependency(value);
            isExternal = true;
            t.next();
            t.skip(EToken.DOT);
            value = t.value();
        } 

        Type ty = findType(typeProject, value);
        TypeRef tr = makeNode!TypeRef(t.coord(), value, ty, typeProject);
        tr.isExternal = isExternal;
        type = tr;
    }

    if(!type) {
        syntaxError(t, "a Type");
    }

    t.next();

    // Pointer
    if(t.isKind(EToken.STAR)) {
        Pointer ptr = makeNode!Pointer(type.coord);
        ptr.add(type);

        while(t.isKind(EToken.STAR)) {
            ptr.depth++;
            t.next();
        }

        type = ptr;
    }

    parent.add(type);
    
    logParse("  type = %s", type);
}
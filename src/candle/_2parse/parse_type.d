module candle._2parse.parse_type;

import candle.all;

void parseType(Node parent, Tokens t) {
    logParse("parseType %s", t.debugValue());
    Project project = parent.getProject();
    string value = t.value();

    Node type;

    switch(value) {
        case "bool": type = makeNode!Primitive(TypeKind.BOOL); break;
        case "byte": type = makeNode!Primitive(TypeKind.BYTE); break;
        case "ubyte": type = makeNode!Primitive(TypeKind.UBYTE); break;
        case "short": type = makeNode!Primitive(TypeKind.SHORT); break;
        case "ushort": type = makeNode!Primitive(TypeKind.USHORT); break;
        case "int": type = makeNode!Primitive(TypeKind.INT); break;
        case "uint": type = makeNode!Primitive(TypeKind.UINT); break;
        case "long": type = makeNode!Primitive(TypeKind.LONG); break;
        case "ulong": type = makeNode!Primitive(TypeKind.ULONG); break;
        case "float": type = makeNode!Primitive(TypeKind.FLOAT); break;
        case "double": type = makeNode!Primitive(TypeKind.DOUBLE); break;
        case "void": type = makeNode!Primitive(TypeKind.VOID); break;
        default: break;
    }

    if(type) t.next();

    // Is it a user defined type?
    if(!type) {

        Project typeProject = project;
        bool isExternal = false;

        bool isProjectId = t.isKind(TKind.ID) && project.isProjectName(value);
        if(isProjectId) {
            typeProject = project.getProject(value);
            isExternal = true;
            t.next();
            t.skip(TKind.DOT);
            value = t.value();
        }

        Type ty = findType(typeProject, value);
        TypeRef tr = makeNode!TypeRef(value, ty, typeProject);
        tr.isExternal = isExternal;
        type = tr;

        t.next();
    }

    if(!type) {
        syntaxError(t, "a Type");
    }

    logParse("  type = %s", type);

    // Pointer
    if(t.isKind(TKind.STAR)) {
        Pointer ptr = makeNode!Pointer();
        ptr.add(type);

        while(t.isKind(TKind.STAR)) {
            ptr.depth++;
            t.next();
        }

        type = ptr;
    }


    parent.add(type);
}
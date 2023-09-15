module candle._2parse.parse_type;

import candle.all;

void parseType(Node parent, Tokens t) {
    logParse("parseType %s", t.debugValue());
    Project project = parent.getProject();
    string value = t.value();

    Node type;

    switch(value) {
        case "bool": type = makeNode!Primitive(EType.BOOL); break;
        case "byte": type = makeNode!Primitive(EType.BYTE); break;
        case "ubyte": type = makeNode!Primitive(EType.UBYTE); break;
        case "short": type = makeNode!Primitive(EType.SHORT); break;
        case "ushort": type = makeNode!Primitive(EType.USHORT); break;
        case "int": type = makeNode!Primitive(EType.INT); break;
        case "uint": type = makeNode!Primitive(EType.UINT); break;
        case "long": type = makeNode!Primitive(EType.LONG); break;
        case "ulong": type = makeNode!Primitive(EType.ULONG); break;
        case "float": type = makeNode!Primitive(EType.FLOAT); break;
        case "double": type = makeNode!Primitive(EType.DOUBLE); break;
        case "void": type = makeNode!Primitive(EType.VOID); break;
        default: break;
    }

    if(type) t.next();

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
    if(t.isKind(EToken.STAR)) {
        Pointer ptr = makeNode!Pointer();
        ptr.add(type);

        while(t.isKind(EToken.STAR)) {
            ptr.depth++;
            t.next();
        }

        type = ptr;
    }


    parent.add(type);
}
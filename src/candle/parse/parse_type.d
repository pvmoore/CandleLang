module candle.parse.parse_type;

import candle.all;

void parseType(Node parent, Tokens t) {
    logParse("parseType %s", t.debugValue());
    Module module_ = parent.getModule();
    string value = t.value();

    Node type;

    // function ptr
    if(t.isValue("func")) {
        type = parseFunctionPtr(parent, t);
    }

    // Primitive type?
    if(!type) {
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
        if(type) {
            parent.add(type);
            t.next();
        }
    }

    // User defined type?
    if(!type) {
        Module typeModule = module_;
        bool isExternal = false;

        // mod.type
        bool isModuleId = t.isKind(EToken.ID) && module_.isModuleName(value);
        if(isModuleId) {

            // todo - this can be handled more elegantly by parsing it into a ModuleId.Id and then resolving it later into a type

            typeModule = module_.getModule(value);
            isExternal = true;
            t.next();
            t.skip(EToken.DOT);
            value = t.value();
        } 

        Type ty = findType(typeModule, value);
        TypeRef tr = makeNode!TypeRef(t.coord(), value, ty, typeModule);
        tr.isExternal = isExternal;
        type = tr;

        parent.add(type);
        t.next();
    }

    if(!type) {
        syntaxError(t, "a Type");
    }

    // Pointer
    if(t.isKind(EToken.STAR)) {
        Pointer ptr = makeNode!Pointer(type.coord);
        ptr.add(type);

        while(t.isKind(EToken.STAR)) {
            ptr.depth++;
            t.next();
        }

        type = ptr;
        parent.add(type);
    }
    
    logParse(" type = %s", type);
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

/** 
 * func(int->void)
 * func(a:int, b:bool->int)
 */
Func parseFunctionPtr(Node parent, Tokens t) {
    auto fp = makeNode!Func(t.coord());
    fp.isFuncPtr = true;
    parent.add(fp);

    t.skip("func");

    t.skip(EToken.LBRACKET);   
    while(!t.isKind(EToken.RT_ARROW)) {
        fp.numParams++;
        parseParam(fp, t);
        t.skipOptional(EToken.COMMA);
    }
    // return type
    t.skip(EToken.RT_ARROW);
    parseType(fp, t);
    Node rt = fp.last();
    rt.detach();
    fp.insertAt(0, rt);
    
    t.skip(EToken.RBRACKET);
    return fp;
}

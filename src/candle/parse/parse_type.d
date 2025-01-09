module candle.parse.parse_type;

import candle.all;

void parseType(Node parent, Tokens t) {
    logParse("parseType %s", t.debugValue());
    Module module_ = parent.getModule();
    Candle candle = parent.getCandle();
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

        // moduleId::type
        bool isModuleName = module_.isModuleName(value);
        bool isModuleNameColonColon = t.isKind(EToken.ID) && t.isKind(EToken.COLON_COLON, 1);

        if(isModuleName && !isModuleNameColonColon) {
            syntaxError(t, "'::' after module reference");
        }
        if(!isModuleName && isModuleNameColonColon) {
            syntaxError(t, "module reference. Module '%s' not found".format(value));
        }

        if(isModuleNameColonColon) {

            typeModule = module_.getModule(value);
            isExternal = true;
            t.next();

            t.skip(EToken.COLON_COLON);

            value = t.value();
        } 

        // Create a TypeRef and resolve it later
        TypeRef tr = makeNode!TypeRef(t.coord(), value, null, typeModule);
        tr.isExternal = isExternal;
        type = tr;

        parent.add(type);
        t.next();
    }

    if(!type) {
        syntaxError(t, "a Type");
    }

    assert(type);
    // At this point 'type' cannot be null

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

/** Return true if there is a type at the current token position */
bool isType(Module module_, Tokens t, bool isExpr) {
    if(t.kind() != EToken.ID) return false;
    if(isFunctionPtr(t)) return true;
    if(isPrimitiveType(t)) return true;

    bool isModuleId = t.isKind(EToken.ID) && module_.isModuleName(t.value());

    if(isModuleId) with(EToken) {

        // std::foo(
        if(t.matches(ID, COLON_COLON, ID, LBRACKET)) return false;

        // std::struct
        if(t.matches(ID, COLON_COLON, ID)) return true;
    } else {
        // Check for UDT

        if(t.value() == "not") return false;
        
        if(isExpr) {
            // Expression scope

        } else {
            // Statement scope

            // typename {*} id
            if(t.isKind(EToken.STAR, 1)) {
                int offset = 2;
                while(t.isKind(EToken.STAR, offset)) {
                    offset++;
                }
                return t.isKind(EToken.ID, offset);
            }

            // typename id
            if(t.isKind(EToken.ID, 1)) {
                switch(t.value(1)) {
                    case "and": case "or": case "is": case "as": 
                        return false;
                    default: 
                        return true;
                }
            }
        } 
    }
    return false;
}

/+
/** Find the offset of the end of the type. Assumes we are at the start of a Type */
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

    // } else if(t.isKind(EToken.LBRACKET)) {
    //     // function ptr old

    //     t.pushState();
    //     t.next();
    //     while(!t.isKind(EToken.RBRACKET)) {
    //         int len = typeLength(t);
    //         assert(len != 0);
    //         t.next(len);
    //         t.skipOptional(EToken.ID);
    //         t.skipOptional(EToken.COMMA);
    //         t.skipOptional(EToken.RT_ARROW);
    //     }
    //     t.skip(EToken.RBRACKET);
    //     int end = t.pos;
    //     t.popState();
    //     log("function ptr length = %s to %s (%s)", pos, end, end-pos);
    //     offset = end - pos;
    } else {
        assert(t.isKind(EToken.ID));
        offset = 1;

        // std.struct (deprecated)
        with(EToken) if(t.matches(ID, DOT, ID)) {
            offset += 2;
        }
        // std::struct
        with(EToken) if(t.matches(ID, COLON_COLON, ID)) {
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
+/

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

/** 
 * func(int->void)
 * func(int a -> void)
 * func(a:int, b:bool->int)
 * func(int a)                  // currently not supported. should we allow this?
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

/**
 * eg. func(void->void) 
 *     func(int a -> void)
 *     func(int a, int b -> int)
 */
bool isFunctionPtr(Tokens t) {
    return t.isValue("func") && t.isKind(EToken.LBRACKET, 1);
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

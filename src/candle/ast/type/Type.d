module candle.ast.type.Type;

import candle.all;

interface Type {
    EType etype();
    bool isResolved();
    bool canImplicitlyConvertTo(Type other);
    bool exactlyMatches(Type other);
    string getASTSummary();
}

Type copy(Type t) {
    // todo
    return t;
}
bool isPtr(Type t) {
    return t.isA!Pointer;
}
bool isValue(Type t) {
    return !isPtr(t);
}
bool isBool(Type t) {
    return t.etype() == EType.BOOL;
}
bool isVoid(Type t) {
    return t.etype() == EType.VOID;
}
bool isUnknown(Type t) {
    return t.etype() == EType.UNKNOWN;
}
bool isInteger(Type t) {
    switch(t.etype()) with(EType) {
        case UBYTE: case BYTE:
        case USHORT: case SHORT:
        case UINT: case INT:
        case ULONG: case LONG:
            return true;
        default: return false;
    }
}
bool isReal(Type t) {
    switch(t.etype()) with(EType) {
        case FLOAT: case DOUBLE:
            return true;
        default: return false;
    }
}
bool isVoidValue(Type t) {
    return t.isVoid() && t.isValue();
}
bool isStruct(Type t) {
    return t.etype() == EType.STRUCT;
}
bool isArray(Type t) {
    return t.etype() == EType.ARRAY;
}
bool isUnion(Type t) {
    return t.etype() == EType.UNION;
}
bool isEnum(Type t) {
    return t.etype() == EType.ENUM;
}
bool isFunc(Type t) {
    return t.etype() == EType.FUNC;
}
Struct getStruct(Type t) {
    if(Struct s = t.as!Struct) return s;
    if(Alias a = t.as!Alias) return a.toType().getStruct();
    if(TypeRef tr = t.as!TypeRef) return tr.decorated.getStruct();
    if(Pointer p = t.as!Pointer) return p.valueType().getStruct();
    return null;
}
Union getUnion(Type t) {
    if(Union u = t.as!Union) return u;
    if(Alias a = t.as!Alias) return a.toType().getUnion();
    if(TypeRef tr = t.as!TypeRef) return tr.decorated.getUnion();
    if(Pointer p = t.as!Pointer) return p.valueType().getUnion();
    return null;
}
Type getBaseValueType(Type t) {
    if(Alias a = t.as!Alias) return a.toType().getBaseValueType();
    if(TypeRef tr = t.as!TypeRef) return tr.decorated.getBaseValueType();
    if(Pointer p = t.as!Pointer) return p.valueType().getBaseValueType();
    return t;
}
string getName(Type t) {
    if(Alias a = t.as!Alias) return a.name;
    if(Struct s = t.as!Struct) return s.name ? s.name : "anonymous struct";
    if(Union u = t.as!Union) return u.name ? u.name : "anonymous union";
    if(Enum e = t.as!Enum) return e.name;
    if(Func f = t.as!Func) return f.name;
    if(Primitive p = t.as!Primitive) return p.toString();
    if(TypeRef tr = t.as!TypeRef) {
        if(tr.decorated) return getName(tr.decorated);
        return tr.name;
    }
    if(Pointer p = t.as!Pointer) return getName(p.valueType());
    return "%s".format(t.etype());
}

int size(Type t) {
    if(TypeRef tr = t.as!TypeRef) return size(tr.decorated);
    if(t.isA!Pointer) return 8;
    final switch(t.etype()) with(EType) {
        case VOID: return 0;
        case BOOL: case BYTE: case UBYTE: return 1;
        case SHORT: case USHORT: return 2;
        case INT: case UINT: case FLOAT: return 4;
        case LONG: case ULONG: case DOUBLE: case FUNC:
            return 8;
        case ALIAS:
            return t.as!Alias.toType().size();
        case STRUCT: 
            return t.as!Struct.getSize();
        case UNION:
            todo("implement size(Union)");
            return 0;
        case ARRAY:
            todo("implement size(Array)");
            return 0;
        case ENUM:
            todo("implement size(Enum)");
            return 0;
        case UNKNOWN:
            throw new Exception("size(UNKNOWN)");
    }
}
int alignment(Type t) {
    if(TypeRef tr = t.as!TypeRef) return alignment(tr.decorated);
    if(t.isPtr()) return 8;
    final switch(t.etype()) with(EType) {
        case UNKNOWN:
        case VOID:
            assert(false, "%s has no alignment".format(t.etype()));
        case BOOL:
        case BYTE: case UBYTE: return 1;
        case SHORT: case USHORT: return 2;
        case INT: case UINT: return 4;
        case LONG: case ULONG: return 8;
        case FLOAT: return 4;
        case DOUBLE:
        case FUNC: /// should always be a ptr 
            return 8;
        case ALIAS:
            return t.as!Alias.toType().alignment();    
        case STRUCT:
            return t.as!Struct.getAlignment();
        case UNION:    
        case ARRAY: 
        case ENUM: 
            assert(false, "alignment %s implement me".format(t.etype()));
    }
}
string initStr(Type t) {
    if(t.isA!Pointer) return "null";
    final switch(t.etype())with(EType) {
        case BOOL: return "false";
        case BYTE:
        case UBYTE:
        case SHORT:
        case USHORT:
        case INT:
        case UINT:
        case LONG:
        case ULONG:
            return "0";
        case FLOAT:
            return "0.0f";
        case DOUBLE:
            return "0.0";
        case FUNC:
            return "null";    
        case STRUCT:
            return "{0}";
        case ALIAS:
            return t.as!Alias.toType().initStr();
        case UNION:
        case ARRAY:
        case ENUM:
        case UNKNOWN:
        case VOID:
            return null;   
    }
    assert(false);
}
bool exactlyMatch(Type[] a, Type[] b) {
    if(a.length != b.length) return false;
    foreach(i; 0..a.length) if(!a[i].exactlyMatches(b[i])) return false;
    return true;
}
/**
 * Return the largest type of a or b.
 * Return null if they are not compatible.
 */
Type getBestType(Type a, Type b) {
    if(a.isVoidValue() || b.isVoidValue()) return null;

    if(a.exactlyMatches(b)) return a;

    if(a.isPtr() || b.isPtr()) return null;

    if(a.isStruct() || b.isStruct()) {
        // todo - some clever logic here
        return null;
    }
    if(a.isFunc() || b.isFunc()) {
        return null;
    }
    if(a.isArray() || b.isArray()) {
        return null;
    }

    if(a.isReal() == b.isReal()) {
        return a.etype() > b.etype() ? a : b;
    }
    if(a.isReal()) return a;
    if(b.isReal()) return b;
    return a;
}

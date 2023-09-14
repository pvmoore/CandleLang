module candle.ast.type.Type;

import candle.all;

interface Type {
    EType tkind();
    bool isResolved();
    bool canImplicitlyConvertTo(Type other);
    bool exactlyMatches(Type other);
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
    return t.tkind() == EType.BOOL;
}
bool isVoid(Type t) {
    return t.tkind() == EType.VOID;
}
bool isUnknown(Type t) {
    return t.tkind() == EType.UNKNOWN;
}
bool isInteger(Type t) {
    switch(t.tkind()) with(EType) {
        case UBYTE: case BYTE:
        case USHORT: case SHORT:
        case UINT: case INT:
        case ULONG: case LONG:
            return true;
        default: return false;
    }
}
bool isReal(Type t) {
    switch(t.tkind()) with(EType) {
        case FLOAT: case DOUBLE:
            return true;
        default: return false;
    }
}
bool isVoidValue(Type t) {
    return t.isVoid() && t.isValue();
}
bool isStruct(Type t) {
    return t.tkind() == EType.STRUCT;
}
bool isArray(Type t) {
    return t.tkind() == EType.ARRAY;
}
bool isFunc(Type t) {
    return t.tkind() == EType.FUNC;
}
int size(Type t) {
    if(t.isA!Pointer) return 8;
    final switch(t.tkind())with(EType) {
        case VOID: return 0;
        case BOOL: case BYTE: case UBYTE: return 1;
        case SHORT: case USHORT: return 2;
        case INT: case UINT: case FLOAT: return 4;
        case LONG: case ULONG: case DOUBLE: case FUNC:
            return 8;
        case STRUCT:
        case UNION:
            todo("implement size(Struct|Union)");
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
        return a.tkind() > b.tkind() ? a : b;
    }
    if(a.isReal()) return a;
    if(b.isReal()) return b;
    return a;
}
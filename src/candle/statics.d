module candle.statics;

import candle.all;

__gshared:

enum LOG_PARSE   = !true;
enum LOG_RESOLVE = !true;
enum LOG_CHECK   = !true;
enum LOG_EMIT    = !true;

File logFile;

Type TYPE_VOID;
Type TYPE_UNKNOWN;
Type TYPE_BOOL;
Type TYPE_BYTE;
Type TYPE_UBYTE;
Type TYPE_SHORT;
Type TYPE_USHORT;
Type TYPE_INT;
Type TYPE_UINT;
Type TYPE_LONG;
Type TYPE_ULONG;
Type TYPE_FLOAT;
Type TYPE_DOUBLE;

uint IDS = 0;

private Type[TypeKind] staticTypes;

static this() {
    import std : exists, mkdir;
    if(!exists(".logs/")) mkdir(".logs/");
    logFile = File(".logs/candle.log", "wb");

    TYPE_UNKNOWN = makeNode!Primitive(TypeKind.UNKNOWN);
    TYPE_VOID = makeNode!Primitive(TypeKind.VOID);
    TYPE_BOOL = makeNode!Primitive(TypeKind.BOOL);
    TYPE_BYTE = makeNode!Primitive(TypeKind.BYTE);
    TYPE_UBYTE = makeNode!Primitive(TypeKind.UBYTE);
    TYPE_SHORT = makeNode!Primitive(TypeKind.SHORT);
    TYPE_USHORT = makeNode!Primitive(TypeKind.USHORT);
    TYPE_INT = makeNode!Primitive(TypeKind.INT);
    TYPE_UINT = makeNode!Primitive(TypeKind.UINT);
    TYPE_LONG = makeNode!Primitive(TypeKind.LONG);
    TYPE_ULONG = makeNode!Primitive(TypeKind.ULONG);
    TYPE_FLOAT = makeNode!Primitive(TypeKind.FLOAT);
    TYPE_DOUBLE = makeNode!Primitive(TypeKind.DOUBLE);

    staticTypes[TypeKind.UNKNOWN] = TYPE_UNKNOWN;
    staticTypes[TypeKind.VOID] = TYPE_VOID;
    staticTypes[TypeKind.BOOL] = TYPE_BOOL;
    staticTypes[TypeKind.BYTE] = TYPE_BYTE;
    staticTypes[TypeKind.UBYTE] = TYPE_UBYTE;
    staticTypes[TypeKind.SHORT] = TYPE_SHORT;
    staticTypes[TypeKind.USHORT] = TYPE_USHORT;
    staticTypes[TypeKind.INT] = TYPE_INT;
    staticTypes[TypeKind.UINT] = TYPE_UINT;
    staticTypes[TypeKind.LONG] = TYPE_LONG;
    staticTypes[TypeKind.ULONG] = TYPE_ULONG;
    staticTypes[TypeKind.FLOAT] = TYPE_FLOAT;
    staticTypes[TypeKind.DOUBLE] = TYPE_DOUBLE;
}

Type getStaticType(TypeKind kind) {
    return staticTypes[kind];
}

static ~this() {
    logFile.close();
}

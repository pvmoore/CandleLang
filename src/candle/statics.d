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

private Type[EType] staticTypes;

static this() {
    import std : exists, mkdir;
    if(!exists(".logs/")) mkdir(".logs/");
    logFile = File(".logs/candle.log", "wb");

    TYPE_UNKNOWN = makeNode!Primitive(EType.UNKNOWN);
    TYPE_VOID = makeNode!Primitive(EType.VOID);
    TYPE_BOOL = makeNode!Primitive(EType.BOOL);
    TYPE_BYTE = makeNode!Primitive(EType.BYTE);
    TYPE_UBYTE = makeNode!Primitive(EType.UBYTE);
    TYPE_SHORT = makeNode!Primitive(EType.SHORT);
    TYPE_USHORT = makeNode!Primitive(EType.USHORT);
    TYPE_INT = makeNode!Primitive(EType.INT);
    TYPE_UINT = makeNode!Primitive(EType.UINT);
    TYPE_LONG = makeNode!Primitive(EType.LONG);
    TYPE_ULONG = makeNode!Primitive(EType.ULONG);
    TYPE_FLOAT = makeNode!Primitive(EType.FLOAT);
    TYPE_DOUBLE = makeNode!Primitive(EType.DOUBLE);

    staticTypes[EType.UNKNOWN] = TYPE_UNKNOWN;
    staticTypes[EType.VOID] = TYPE_VOID;
    staticTypes[EType.BOOL] = TYPE_BOOL;
    staticTypes[EType.BYTE] = TYPE_BYTE;
    staticTypes[EType.UBYTE] = TYPE_UBYTE;
    staticTypes[EType.SHORT] = TYPE_SHORT;
    staticTypes[EType.USHORT] = TYPE_USHORT;
    staticTypes[EType.INT] = TYPE_INT;
    staticTypes[EType.UINT] = TYPE_UINT;
    staticTypes[EType.LONG] = TYPE_LONG;
    staticTypes[EType.ULONG] = TYPE_ULONG;
    staticTypes[EType.FLOAT] = TYPE_FLOAT;
    staticTypes[EType.DOUBLE] = TYPE_DOUBLE;
}

Type getStaticType(EType kind) {
    return staticTypes[kind];
}

static ~this() {
    logFile.close();
}

module candle.ast.type.EType;

import candle.all;

enum EType {
    UNKNOWN,

    // PrimitiveTypes
    BOOL,
    UBYTE,
    BYTE,
    USHORT,
    SHORT,
    UINT,
    INT,
    ULONG,
    LONG,
    FLOAT,
    DOUBLE,
    VOID,

    STRUCT,
    UNION,
    FUNC,
    ARRAY,
    ENUM,
    ALIAS
}


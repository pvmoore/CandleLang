module candle.Value;

import candle.all;
import std.conv : to;

// Assume any calculations will be done as int or higher
struct Value {
    union Val {
        bool b;
        byte by;
        ubyte uby;
        short s;
        ushort us;
        int i;
        uint ui;
        long l;
        ulong ul;
        float f;
        double d;
    }
    Val value;
    EType kind;

    this(string s) {
        convert(s);
    }
    string toString() {
        switch(kind) with(EType) {
            case BOOL: return value.b.to!string;
            case BYTE: return value.by.to!string;
            case UBYTE: return value.uby.to!string ~ "u";
            case SHORT: return value.s.to!string;
            case USHORT: return value.us.to!string ~ "u";
            case INT: return value.i.to!string;
            case UINT: return value.ui.to!string ~ "u";
            case LONG: return value.l.to!string ~ "LL";
            case ULONG: return value.ul.to!string ~ "LLU";
            case FLOAT: { 
                string s = value.f.to!string;
                if(!s.contains('.')) {
                    s ~= ".0";
                }
                return s ~ "f";
            }
            case DOUBLE: { 
                string s = value.d.to!string;
                if(!s.contains('.')) {
                    s ~= ".0";
                }
                return s;
            }
            default: assert(false);
        }
    }
    bool isInteger() {
        return kind.isOneOf(
            EType.BYTE, EType.UBYTE, EType.SHORT, EType.USHORT,
            EType.INT, EType.UINT, EType.LONG, EType.ULONG);
    }
    bool isReal() {
        return !isBool() && !isInteger();
    }
    bool isBool() {
        return kind == EType.BOOL;
    }
    void changeType(EType newKind) {
        if(kind == newKind) return;
        switch(newKind) with(EType) {
            case BOOL: set(asBool()); break;
            case BYTE: set(asLong().as!byte); break;
            case UBYTE: set(asLong().as!ubyte); break;
            case SHORT: set(asLong().as!short); break;
            case USHORT: set(asLong().as!ushort); break;
            case INT: set(asLong().as!int); break;
            case UINT: set(asLong().as!uint); break;
            case LONG: set(asLong()); break;
            case ULONG: set(asLong().as!ulong); break;
            case FLOAT: set(asDouble().as!float); break;
            case DOUBLE: set(asDouble()); break;
            default: assert(false, "newKind is %s".format(newKind));
        }
    }
private:
    bool asBool() {
        return value.ul != 0;
    }
    long asLong() {
        switch(kind) with(EType) {
            case BOOL: return value.b != 0 ? 1 : 0;
            case BYTE: return value.by;
            case UBYTE: return value.by;
            case SHORT: return value.s;
            case USHORT: return value.s;
            case INT: return value.i;
            case UINT: return value.i;
            case LONG: return value.l;
            case ULONG: return value.l;
            case FLOAT: return value.f.as!long;
            case DOUBLE: return value.d.as!long;
            default: assert(false);
        } 
    }
    double asDouble() {
        switch(kind) with(EType) {
            case BOOL: return value.b != 0 ? 1 : 0;
            case BYTE: return value.by;
            case UBYTE: return value.by;
            case SHORT: return value.s;
            case USHORT: return value.s;
            case INT: return value.i;
            case UINT: return value.i;
            case LONG: return value.l;
            case ULONG: return value.l;
            case FLOAT: return value.f;
            case DOUBLE: return value.d;
            default: assert(false);
        } 
    }
    void set(bool b) {
        value.b = b;
        kind = EType.BOOL;
    }
    void set(byte b) {
        value.by = b;
        kind = EType.BYTE;
    }
    void set(ubyte b) {
        value.uby = b;
        kind = EType.UBYTE;
    }
    void set(short s) {
        value.s = s;
        kind = EType.SHORT;
    }
    void set(ushort s) {
        value.us = s;
        kind = EType.USHORT;
    }
    void set(int i) {
        value.i = i;
        kind = EType.INT;
    }
    void set(uint i) {
        value.ui = i;
        kind = EType.UINT;
    }
    void set(long l) {
        value.l = l;
        kind = EType.LONG;
    }
    void set(ulong l) {
        value.ul = l.as!ulong;
        kind = EType.ULONG;
    }
    void set(float f) {
        value.f = f;
        kind = EType.FLOAT;
    }
    void set(double d) {
        value.d = d;
        kind = EType.DOUBLE;
    }
    void setUnspecifiedInteger(ulong v) {
        if(v <= ubyte.max) {
            set(v.as!ubyte);
        } else if(v <= ushort.max) {
            set(v.as!ushort);
        } else if(v <= uint.max) {
            set(v.as!uint);
        } else {
            set(v);        
        }
    }
    void setUnspecifiedInteger(long v) {
        if(v < 0) {
            if(v >= byte.min) {
                set(v.as!byte);
            } else if(v >= short.min) {
                set(v.as!short);
            } else if(v >= int.min) {
                set(v.as!int);
            } else {
                set(v);
            }
        } else {
            if(v <= byte.max) {
                set(v.as!byte);
            } else if(v <= short.max) {
                set(v.as!short);
            } else if(v <= int.max) {
                set(v.as!int);
            } else {
                set(v);        
            }
        }
    }
    void convert(string s) {
        if(s.length > 1) {
            if(s[0..2] == "0x" || s[0..2] == "0X") {
                setUnspecifiedInteger(to!ulong(s[2..$], 16));
                return;
            }
            if(s[0..2] == "0b" || s[0..2] == "0B") {
                setUnspecifiedInteger(to!ulong(s[2..$], 2));
                return;
            }
            if("true" == s) {
                set(true);
                return;
            }
            if("false" == s) {
                set(false);
                return;
            }
            if(s[0]=='\'') {
                int v = 0;
                if(s[1]=='\\') {
                    switch(s[1]) {
                        case '0' : v = 0; break;
                        case 'b' : v = 8; break;
                        case 't' : v = 9; break;
                        case 'n' : v = 10; break;
                        case 'f' : v = 12; break;
                        case 'r' : v = 13; break;
                        case '\"': v = 34; break;
                        case '\'': v = 39; break;
                        case '\\': v = 92; break;
                        case 'x' :
                            set(to!ulong(s[2..4], 16));
                            return;
                        case 'u' :
                            set(to!ulong(s[2..6], 16));
                            return;
                        case 'U' :
                            to!ulong(s[2..10], 16);
                            return;
                        default:
                            break;
                    }
                } else {
                    v = s[1].to!uint;
                }
                set(v);
                return;
            }

            bool consume(char ch, char ch2) {
                if(s.length > 0 && (s[$-1] == ch || s[$-1] == ch2)) {
                    s = s[0..$-1];
                    return true;
                }
                return false;
            }
            bool consumeL() {
                return consume('l', 'L');
            }
            bool consumeU() {
                return consume('u', 'U');
            }
            bool consumeF() {
                return consume('f', 'F');
            }

            // L   = int
            // LL  = long
            // UL  = uint
            // ULL = ulong

            if(consumeL()) {
                if(consumeL()) {
                    if(consumeU()) {
                        // ULL
                        set(s.to!ulong);
                        return;
                    }
                    // LL
                    set(s.to!long);
                    return;
                } else if(consumeU()) {
                    // UL
                    set(s.to!uint);
                    return;
                }
                // L
                set(s.to!int);
                return;
            }

            if(consumeF()) {
                set(to!float(s));
                return;
            }
            if(s.contains(".")) {
                set(to!double(s));
                return;
            }
        }
        // Find the smallest integer type to represent this number
        setUnspecifiedInteger(to!long(s));
    }
}

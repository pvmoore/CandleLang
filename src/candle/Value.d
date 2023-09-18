module candle.Value;

import candle.all;
import std.conv : to;

struct Value {
    // Assume any calculations will be done as int or higher
    union Val {
        bool b;

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
            case INT: return value.i.to!string;
            case UINT: return value.ui.to!string;
            case LONG: return value.l.to!string;
            case ULONG: return value.ul.to!string;
            case FLOAT: return value.f.to!string;
            case DOUBLE: return value.d.to!string;
            default: assert(false);
        }
    }
private:
    void set(bool b) {
        value.b = b;
        kind = EType.BOOL;
    }
    void set(int i) {
        value.i = i;
        kind = EType.INT;
    }
    void set(long l) {
        value.l = l;
        kind = EType.LONG;
    }
    void set(ulong l) {
        if(l <= 0xffff_ffffL) {
            value.ui = l.as!ulong.as!uint;
            kind = EType.UINT;
        } else {
            value.ul = l.as!ulong;
            kind = EType.ULONG;
        }
    }
    void set(float f) {
        value.f = f;
        kind = EType.FLOAT;
    }
    void set(double d) {
        value.d = d;
        kind = EType.DOUBLE;
    }

    void convert(string s) {
        if(s.length > 1) {
            if(s[0..2] == "0x" || s[0..2] == "0X") {
                set(to!long(s[2..$], 16));
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

        // Assume it is an int or long
        long v = to!long(s);
        if(v <= 0x7fff_ffff) {
            set(v.as!int);
        } else {
            set(v);
        }
    }
}

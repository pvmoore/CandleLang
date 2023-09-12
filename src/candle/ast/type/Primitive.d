module candle.ast.type.Primitive;

import candle.all;

/**
 *  Primitive
 */
final class Primitive : Node, Type {
public:
    this(TypeKind k) {
        this._kind = k;
    }
    override NKind nkind() { return NKind.PRIMITIVE; }
    override TypeKind tkind() { return _kind; }
    override bool isResolved() { return true; }
    override Type type() { return this; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Primitive other = otherType.as!Primitive;
        return other && _kind == other._kind;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        Primitive other = otherType.as!Primitive;
        if(!other) return false;

        if(otherType.isBool()) return true;
        if(this.isVoid() || otherType.isVoid()) return false;
        if(this.isUnknown() || otherType.isUnknown()) return false;

        if(isInteger(this)) {
            if(other.isInteger()) {
                return other.size() >= this.size();
            } else {
                return false;
            }
        } else {
            // Assume we are real
            assert(this.isReal());

            if(otherType.isReal()) {
                return other.size() >= this.size();
            } else {
                // No implicit conversion from integer to real
                return false;
            }
        }
    }
    override string toString() {
        import std.string:toLower;
        return "%s".format(tkind()).toLower();
    }
private:
    TypeKind _kind;
}
module candle.ast.type.Primitive;

import candle.all;

/**
 *  Primitive
 */
final class Primitive : Node, Type {
public:
    this(EType k) {
        this._kind = k;
    }

    override ENode enode() { return ENode.PRIMITIVE; }
    override EType etype() { return _kind; }
    override bool isResolved() { return _kind!=EType.UNKNOWN; }
    override Type type() { return this; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());

        Primitive other = getPrimitive(otherType);
        return other && _kind == other._kind;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        Primitive other = getPrimitive(otherType);
        if(!other) return false;

        if(this.isVoid() || otherType.isVoid()) return false;
        if(this.isUnknown() || otherType.isUnknown()) return false;
        
        // Allow all implicit convert to bool
        if(otherType.isBool()) return true;

        // Allow bool -> any for now and see how it goes
        if(this.isBool()) return true;

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
        return "%s".format(etype()).toLower();
    }
    override string getASTSummary() {
        return "%s".format(etype()).toLower();
    }
private:
    EType _kind;

    Primitive getPrimitive(Type t) {
        if(Primitive p = t.as!Primitive) return p;
        if(Alias a = t.as!Alias) return getPrimitive(a.toType());
        if(TypeRef tr = t.as!TypeRef) return getPrimitive(tr.decorated);
        return null;
    }
}

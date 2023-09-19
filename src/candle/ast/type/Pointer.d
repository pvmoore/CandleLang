module candle.ast.type.Pointer;

import candle.all;

/**
 *  Pointer
 *      Type    the value type
 */
final class Pointer : Node, Type {
public:
    int depth;

    this(int depth = 0) {
        this.depth = depth;
    }

    Type valueType() { return first().as!Type; }

    override ENode enode() { return ENode.POINTER; }
    override EType etype() { return valueType().etype(); }
    override bool isResolved() { return valueType.isResolved(); }
    override Type type() { return this; }
    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Pointer other = otherType.as!Pointer;
        return depth == other.depth && valueType.exactlyMatches(other.valueType());
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Pointer other = otherType.as!Pointer;
        return other && other.valueType().etype() == this.etype();
    }
    override string toString() {
        return "*".repeat(depth);
    }
private:
}
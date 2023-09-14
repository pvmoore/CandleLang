module candle.ast.type.Array;

import candle.all;

/**
 *  ArrayType
 *      Type        element type
 *      Expr        length
 *      { Expr }    elements
 */
final class Array : Node, Type {
public:

    Type elementType() { return first().as!Type; }
    Expr length() { return children[1].as!Expr; }

    ulong lengthValue() {
        if(_lengthValue == 0) {
            assert(length().isResolved());
            if(Number n = length().as!Number) {
                _lengthValue = n.value.value.l;
            }
        }
        return _lengthValue;
    }

    override ENode enode() { return ENode.ARRAY; }
    override EType etype() { return EType.ARRAY; }
    override bool isResolved() { return elementType.isResolved() && length().isResolved(); }
    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Array other = otherType.as!Array;
        if(!other) return false;

        bool lengthMatches = lengthValue() == other.lengthValue();

        return elementType.exactlyMatches(other.elementType()) && lengthMatches;
    }
    override bool canImplicitlyConvertTo(Type other) {
        return false;
    }
    override Type type() { return this; }

    override string toString() {
        return "Array";
    }
private:
    ulong _lengthValue;
}
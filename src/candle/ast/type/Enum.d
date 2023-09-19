module candle.ast.type.Enum;

import candle.all;

/**
 *  Enum
 *      { Id Expr }     values
 */
final class Enum : Node, Type {
public:
    override ENode enode() { return ENode.ENUM; }
    override EType etype() { return EType.ENUM; }
    override bool isResolved() { return true; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return false;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        return false;
    }
    override Type type() { return this; }

    override string toString() {
        return "Enum";
    }
private:
}
module candle.ast.type.Enum;

import candle.all;

/**
 *  Enum
 *      { Id Expr }     values
 */
final class Enum : Node, Type {
public:

    void resolve() {

    }

    override ENode nkind() { return ENode.ENUM; }
    override EType tkind() { return EType.ENUM; }
    override bool isResolved() { return true; }
    override bool exactlyMatches(Type otherType) {
        return false;
    }
    override bool canImplicitlyConvertTo(Type other) {
        return false;
    }
    override Type type() { return this; }

    override string toString() {
        return "Enum";
    }
private:
}
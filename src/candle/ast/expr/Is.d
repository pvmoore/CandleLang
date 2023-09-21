module candle.ast.expr.Is;

import candle.all;

/**
 *  Is
 *      Expr
 *      Expr
 */
final class Is : Expr {
public:
    bool negate; // "is not"

    Node left() { return first(); }
    Node right() { return last(); }

    override ENode enode() { return ENode.IS; }
    override Type type() { return TYPE_BOOL; }
    override int precedence() { return precedenceOf(Operator.EQ); }
    override bool isResolved() { return _isResolved; }
    override string toString() {
        return "Is";
    }
    /** 
     * Expr is Expr
     * Type is Type
     */
    override void resolve() {
        if(!left().isResolved() || !right().isResolved()) return;
        
        Type leftType = left().type();
        Type rightType = right().type();

        // Type is Type
        if(left().isA!Type && right().isA!Type) {
            Rewriter.toBool(this, negate^leftType.exactlyMatches(rightType));
            return;
        }
        // Type is value
        // value is Type
        if(left().isA!Type || right().isA!Type) {
            getCandle().addError(new SemanticError(this, "Comparing Type to non Type is not allowed"));
            return;
        }
        // value is value
        if(leftType.isValue() && rightType.isValue()) {
            /// If the types are different then the result must be false
            if(leftType.etype() != rightType.etype()) {
                Rewriter.toBool(this, negate^false);
                return;
            }
            // Struct
            if(leftType.etype() == EType.STRUCT) {
                todo();
            }
            // Union
            if(leftType.etype() == EType.UNION) {
                todo();
            }
            // Array
            if(leftType.etype() == EType.ARRAY) {
                todo();
            }
            // Enum
            if(leftType.etype() == EType.ENUM) {
                todo();
            }
            // Func
            if(leftType.etype() == EType.FUNC) {
                todo();
            }
            // Primitive
            if(leftType.isA!Primitive) {
                Rewriter.toBoolEquals(this);
                return;
            }
            assert(false, "handle %s is %s".format(left().enode(), right().enode()));
        }
    }
private:
    bool _isResolved;
}
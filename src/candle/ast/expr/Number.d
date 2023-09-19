module candle.ast.expr.Number;

import candle.all;

/**
 *  Number
 */
final class Number : Expr {
public:
    string stringValue;
    Value value;

    override ENode enode() { return ENode.NUMBER; }
    override Type type() { return getStaticType(value.kind); }
    override int precedence() { return 0; }
    override bool isResolved() { return _isResolved; }
    override string toString() {
        return "%s (%s)".format(value, type());
    }
    override void parse(Tokens t) {
        this.stringValue = t.value(); t.next();
        this.value = Value(this.stringValue);
    }
    override void resolve() {
        if(Var var = parent.as!Var) {
            auto vt = var.type().as!Primitive;
            if(vt.isResolved() && vt.etype() != value.kind) {
                convertTo(vt);
            }
        }
        _isResolved = true;
    }
private:
    bool _isResolved;

    void convertTo(Type t) {
        value.changeType(t.etype());
        // Change double constant to float
        // if(value.kind == EType.DOUBLE && t==EType.FLOAT) {
        //     value.changeType(t);
        // } else if(value.isInteger() && t==EType.DOUBLE) {
        //     value.changeType(t);
        // } else {

        // }
    }
}
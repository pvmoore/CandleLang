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
    override bool isResolved() { return true; }
    override string toString() {
        return "%s (%s)".format(value, type());
    }
    override void parse(Tokens t) {
        this.stringValue = t.value(); t.next();
        this.value = Value(this.stringValue);
    }
private:
}
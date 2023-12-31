module candle.ast.expr.Char;

import candle.all;

/**
 *  Char
 */
final class Char : Expr {
public:
    string stringValue;
    Value value;

    override ENode enode() { return ENode.CHAR; }
    override Type type() { return TYPE_INT; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "%s -> %s (int)".format(stringValue, value);
    }
    override void parse(Tokens t) {
        this.stringValue = t.value(); t.next();
        this.value = Value(this.stringValue);
    }
private:
}
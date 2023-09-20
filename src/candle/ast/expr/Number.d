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
    override void resolve() {
        if(Var var = parent.as!Var) {
            changeType(var);
        } else if(Binary b = parent.as!Binary) {
            changeType(b);
        }
    }
private:
    void changeType(Node p) {
        if(!p.isResolved()) return;
        auto vt = p.type().as!Primitive;
        if(vt && vt.etype() != value.kind) {
            value.changeType(vt.etype());
        }
    }
}
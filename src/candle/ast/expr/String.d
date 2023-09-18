module candle.ast.expr.String;

import candle.all;

/**
 *  String
 */
final class String : Expr {
public:
    string stringValue;

    override ENode enode() { return ENode.STRING; }
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "\"%s\"".format(stringValue);
    }
    override void parse(Tokens t) {
        // Gather all sequential strings into one
        while(t.isKind(EToken.STRING)) {
            this.stringValue ~= t.value()[1..$-1]; t.next();
        }
    }
private:
}
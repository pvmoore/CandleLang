module candle.ast.expr.String;

import candle.all;

/**
 *  String
 *
 * eg.
 *    "string"
 *   r"raw string"
 */
final class String : Expr {
public:
    string stringValue;
    bool isRaw;

    override ENode enode() { return ENode.STRING; }
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "\"%s\"".format(stringValue);
    }
    override void parse(Tokens t) {
        this.isRaw = t.value()[0] == 'r';
        const n = isRaw ? 2 : 1;

        // Gather all sequential strings into one
        while(t.isKind(EToken.STRING)) {
            if((t.value()[0] == 'r') != isRaw) {
                break;
            }
            this.stringValue ~= t.value()[n..$-1]; t.next();
        }
    }
private:
}

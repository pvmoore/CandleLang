module candle.ast.expr.String;

import candle.all;

/**
 *  String
 *
 * eg.
 *    "string"
 *   c"c string" 
 *   r"raw c string"
 *
 * TODO: 1) Assume "string" is just c"string". Ensure we add /0 to the end when we emit the string constant
 *       2) Handle raw strings in the lexer. By the time we get here the escapes have all been applied 
 */
final class String : Expr {
public:
    string stringValue;
    bool isRaw;
    bool isCharArray;

    override ENode enode() { return ENode.STRING; }
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "\"%s\"%s".format(stringValue, isRaw ? " (raw)" : "");
    }
    override void parse(Tokens t) {
        const ch = t.value()[0];
        this.isRaw = ch == 'r';
        this.isCharArray = ch == 'c';
        const n = isRaw || isCharArray ? 2 : 1;

        // Gather all sequential strings into one
        while(t.isKind(EToken.STRING) && t.value()[0] == ch) {
            this.stringValue ~= t.value()[n..$-1]; 
            t.next();
        }
    }
private:
}

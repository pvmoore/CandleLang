module candle.ast.expr.String;

import candle.all;

/**
 *  String
 */
final class String : Expr {
public:
    string stringValue;

    override NKind nkind() { return NKind.STRING; }
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return true; }
    override string toString() {
        return "\"%s\"".format(stringValue);
    }
private:
}
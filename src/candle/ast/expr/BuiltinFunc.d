module candle.ast.expr.BuiltinFunc;

import candle.all;

/**
 *  BuiltinFunc
 *      { Expr }    arguments
 */
final class BuiltinFunc : Expr {
public:
    string name;

    int numArgs() { return numChildren(); }
    Expr[] args() { return children.as!(Expr[]); }

    override ENode enode() { return ENode.BUILTIN_FUNC; }
    override Type type() { return TYPE_UNKNOWN; }
    override int precedence() { return 200; }
    override bool isResolved() { return _isResolved; }
    override string toString() {
        return "BuiltinFunc %s".format(name);
    }

    void resolve() {
        if(isResolved()) return;
        switch(name) {
            case "assert":
                _isResolved = true;
                break;
            default: break;
        }
    }
private:
    bool _isResolved;
}
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
    /** 
     * BUILTIN_FUNC ::= '@' name '(' { Expr } ')'
     */
    override void parse(Tokens t) {
        t.skip(EToken.AT);

        this.name = t.value(); t.next();

        if(t.isKind(EToken.LBRACKET)) {
            t.skip(EToken.LBRACKET);

            bool hasArgs = !t.isKind(EToken.RBRACKET);
            if(hasArgs) {
                Parens p = makeNode!Parens(t.coord());
                this.add(p);

                while(!t.isKind(EToken.RBRACKET)) {
                    parseExpr(p, t);
                    t.skipOptional(EToken.COMMA);
                }
                p.detach();
                while(p.hasChildren()) {
                    this.add(p.first());
                }
            }
            t.skip(EToken.RBRACKET);
        }

        if(t.isKind(EToken.SEMICOLON)) {
            this.isStmt = true;
        }
    }
    override void resolve() {
        if(isResolved()) return;
        switch(name) {
            case "assert":
                _isResolved = true;
                break;
            default: break;
        }
    }
    override void check() {
        switch(name) {
            case "assert":
                if(numChildren()!=1) {
                    getCandle().addError(new SyntaxError(getUnit(), coord, 
                        "Expected 1 argument but found %s".format(numChildren())));
                }
                break;
            default: break;
        }
    }
private:
    bool _isResolved;
}
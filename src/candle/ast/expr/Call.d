module candle.ast.expr.Call;

import candle.all;

/**
 *  Call
 *      { Expr }    arguments
 */
final class Call : Expr {
public:
    string name;
    Target target;

    int numArgs() { return numChildren(); }
    Expr[] args() { return children.as!(Expr[]); }

    override ENode enode() { return ENode.CALL; }
    override Type type() { return target ? target.type() : TYPE_UNKNOWN; }
    override int precedence() { return 200; }
    override bool isResolved() { return target !is null; }
    override string toString() {
        string t = target ? "%s".format(target) : " unresolved";
        return "Call %s -> %s".format(name, t);
    }
    override void parse(Tokens t) {
        this.name = t.value(); t.next();

        t.skip(EToken.LBRACKET);

        bool hasArgs = !t.isKind(EToken.RBRACKET);

        if(hasArgs) {

            Parens p = makeNode!Parens(t.coord());
            this.add(p);

            while(!t.isKind(EToken.RBRACKET)) {
                parseExpr(p, t);

                if(t.isKind(EToken.COMMA)) {
                    t.next();
                }
            }

            p.detach();
            while(p.hasChildren()) {
                this.add(p.first());
            }
        }
        t.skip(EToken.RBRACKET);
    }
    override void resolve() {
        logResolve("  resolving %s", this);

        if(isStartOfChain()) {
            this.target = findCallTarget(this);
            if(target) {
                logResolve("    found target %s", target);
            }
        } else {
            Node prev = prevLink();
            logResolve("  prev = %s", prev);
            if(!prev.isResolved()) return;

            this.target = findCallTarget(this, prev);
            if(target) {
                logResolve("    found target %s", target);
            }
        }
    }
private:
}
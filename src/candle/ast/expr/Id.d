module candle.ast.expr.Id;

import candle.all;

/**
 *  Id
 */
final class Id : Expr {
public:
    string name;
    Target target;

    override ENode enode() { return ENode.ID; }
    override Type type() { return target ? target.type() : TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return target !is null; }
    override string toString() {
        string t = target ? "%s".format(target) : "unresolved";
        return "Id %s -> %s".format(name, t);
    }
    override void parse(Tokens t) {
        this.name = t.value(); t.next();
    }
    override void resolve() {
        if(isResolved()) return;
        logResolve("  resolving %s", this);

        if(isStartOfChain()) {
            this.target = findIdTarget(this);
            if(target) {
                logResolve("    found target %s", target);
            }
        } else {
            Node prev = prevLink();
            log("  prev = %s", prev);
            if(!prev.isResolved()) return;

            this.target = findIdTarget(this, prev);
            if(target) {
                logResolve("    found target %s", target);
            }
        }
    }
private:
}
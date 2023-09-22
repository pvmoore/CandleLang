module candle.Target;

import candle.all;

final class Target {
public:
    // The target (either Var or Func)
    Var var;
    Func func;
    bool isExternal;

    this(Var v) {
        this.var = v;
    }
    this(Func f) {
        this.func = f;
    }
    auto setExternal() {
        isExternal = true;
        return this;
    }

    Node node() { return var ? var : func; }
    Type type() { return node.type(); }
    bool isPublic() { return var ? var.isPublic : func.isPublic; }
    bool isMember() { return var && var.isMember(); }
    Project project() { return node().getProject(); }

    override string toString() {
        string e = isExternal ? "%s::".format(node().getProject().name) : "";
        string m;
        if(isMember()) {
            if(Struct s = var.parent.as!Struct) {
                m = s.name ~ ":";
            } else if(Union u = var.parent.as!Union) {
                m = u.name ~ ":";
            }
        }
        return "[%s]".format(var ? "Var %s%s%s".format(e, m, var.name) : "Func %s%s".format(e, func.name));
    }
private:
}
module candle.resolve.Target;

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
    bool isPublic() { return var ? false : func.isPublic; }
    Project project() { return node().getProject(); }

    override string toString() {
        string e = isExternal ? "%s::".format(node().getProject().name) : "";
        return "[%s]".format(var ? "Var %s%s".format(e, var.name) : "Func %s%s".format(e, func.name));
    }
private:
}
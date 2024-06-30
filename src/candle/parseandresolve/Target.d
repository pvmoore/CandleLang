module candle.parseandresolve.Target;

import candle.all;

final class Target {
public:
    // The target (either Var or Func)
    Var var;
    Func func;
    bool isInExternalModule;

    this(Var v) {
        this.var = v;
    }
    this(Func f) {
        this.func = f;
    }
    auto setInExternalModule() {
        isInExternalModule = true;
        return this;
    }

    Node node() { return var ? var : func; }
    Type type() { return node.type(); }
    string name() { return var ? var.name : func.name; }
    bool isFunc() { return func !is null; }
    bool isVar() { return var !is null; }
    bool isPublic() { return var ? var.isPublic : func.isPublic; }
    bool isExtern() { return func ? func.isExtern : false; }
    bool isMember() { return var && var.isMember(); }
    Module module_() { return node().getModule(); }

    override string toString() {
        string e = isInExternalModule ? "%s::".format(node().getModule().name) : "";
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

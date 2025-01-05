module candle.ast.expr.ModuleId;

import candle.all;

/**
 *  ModuleId
 */
final class ModuleId : Expr {
public:
    string name;
    Module module_;

    override ENode enode() { return ENode.MODULE_ID; }
    override Type type() { return TYPE_VOID; }
    override int precedence() { return 0; }
    override bool isResolved() { return module_ !is null; }
    override string toString() {
        return "ModuleId -> %s".format(module_);
    }
    override void parse(Tokens t) {
        this.name = t.value(); t.next();
        this.module_ = getModule().getModule(name);

        if(t.kind() != EToken.COLON_COLON) {
            syntaxError(t, "'::' after module reference");
        }
    }
private:
}

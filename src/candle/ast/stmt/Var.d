module candle.ast.stmt.Var;

import candle.all;

/**
 *  Var
 *      Type
 *      [ Expr ]    initialiser
 */
final class Var : Stmt {
public:
    string name;

    bool hasInitialiser() { return numChildren() > 1; }
    bool isParameter() { return parent.isA!Func; }
    Expr initialiser() { assert(hasInitialiser()); return last().as!Expr; }

    override NKind nkind() { return NKind.VAR; }
    override Type type() { return first().as!Type; }
    override string toString() {
        string n = name ? "%s".format(name) : "(unnamed)";
        return "Var %s".format(n);
    }
private:
}
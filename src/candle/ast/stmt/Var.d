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
    bool isPublic;

    bool hasInitialiser() { return numChildren() > 1; }
    bool isParameter() { return parent.isA!Func; }
    bool isMember() { return parent.isA!Struct || parent.isA!Union; }
    bool isLocal() { return parent.isA!Scope; }
    bool isGlobal() { return parent.isA!Unit; }
    Expr initialiser() { assert(hasInitialiser()); return last().as!Expr; }

    override ENode enode() { return ENode.VAR; }
    override Type type() { return first().as!Type; }
    override string toString() {
        string n = name ? "%s".format(name) : "(unnamed)";
        string pub = isPublic ? ", pub" : "";
        string l = ", line %s".format(coord.line+1);
        return "Var %s%s%s".format(n, pub, l);
    }
    /**
     * VAR ::= ['pub'] Type [ Id [ '=' Expr ] ]
     */
    override void parse(Tokens t) {
        logParse("parseVar %s", t.debugValue());

        t.consumeModifiers();
        this.isPublic = t.getAndResetPubModifier();

        // Type
        parseType(this, t);

        // Name (optional)
        if(t.isKind(EToken.ID)) {
            this.name = t.value(); t.next();

            // Expression
            if(t.isKind(EToken.EQ)) {
                t.next();

                parseExpr(this, t);
            }
        }

        if(t.isKind(EToken.SEMICOLON)) {
            t.next();
        }

        // Move this var above any Funcs
        if(Unit unit = parent.as!Unit) {
            Func f = unit.findFirstChildOf!Func;
            int index = f ? f.index() : int.max;
            if(index != int.max) {
                int vIndex = unit.indexOf(this);
                if(vIndex > index) {
                    unit.moveToIndex(index, this);
                }
            }
        }
    }
private:
}
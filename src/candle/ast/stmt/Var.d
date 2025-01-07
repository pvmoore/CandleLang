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
    bool isConst;   // for extern c function parameters only 

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
        string con = isConst ? ", const" : "";
        string l = ", line %s".format(coord.line+1);
        return "Var %s%s%s%s".format(n, pub, con, l);
    }

    /** 
     * VAR ::= [ 'const' ] Type Id  
     */
    void parseParam(Tokens t) {
        logParse("parseParam(param) %s", t.debugValue());

        // const (extern c function parameters only)
        if(t.isValue("const")) {
            this.isConst = true;
            t.next();
        }
   
        // Type
        parseType(this, t);

        // Name
        if(t.isKind(EToken.ID)) {
            this.name = t.value(); 
            t.next();
        }
    }

    /**
     * VAR ::= ['pub'] Type Id [ '=' Expr ] 
     */
    override void parse(Tokens t) {
        logParse("parseVar %s", t.debugValue());

        t.consumeModifiers();
        this.isPublic = t.getAndResetPubModifier();

        // Type
        parseType(this, t);

        // Name
        this.name = t.value(); t.next();

        // Expression
        if(t.isKind(EToken.EQ)) {
            t.next();

            parseExpr(this, t);
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

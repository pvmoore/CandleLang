module candle.ast.type.Struct;

import candle.all;

/**
 *  Struct
 *      { Var }
 */
final class Struct : Node, Type {
public:
    string name;
    bool isPublic;

    Var getVar(string name) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(v=>v.name==name)
                       .frontOrElse!Var(null);
    }
    Func[] getFuncs(string name) {
        return children.filter!(it=>it.isA!Func)
                       .map!(it=>it.as!Func)
                       .filter!(v=>v.name==name)
                       .array();
    }
    Var[] getVars() {
        return children.filter!(it=>it.isA!Var).map!(it=>it.as!Var).array;
    }
    Func[] getFuncs() {
        return children.filter!(it=>it.isA!Func).map!(it=>it.as!Func).array;
    }

    override ENode enode() { return ENode.STRUCT; }
    override EType etype() { return EType.STRUCT; }
    override bool isResolved() { return true; }
    override Type type() { return this; }

    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Struct other = otherType.as!Struct;
        if(!other) return false;
        // TODO
        return false;
    }
    override bool canImplicitlyConvertTo(Type other) {
        // TODO
        return false;
    }
    override string toString() {
        string pub = isPublic ? ", pub" : "";
        return "Struct %s%s".format(name, pub);
    }
    /**
     *  STRUCT ::= 'struct' Id ( BODY | ';')
     *  BODY   ::= '{' { Var } '}'
     */
    override void parse(Tokens t) {
        
        this.isPublic = t.getAndResetPubModifier();

        t.skip("struct");

        this.name = t.value(); t.next();

        if(t.isKind(EToken.LCURLY)) {
            t.next();

            while(!t.isKind(EToken.RCURLY)) {
                parseVar(this, t);
            }
            t.skip(EToken.RCURLY);

            // Move this above any Vars or Funcs
            if(Unit unit = parent.as!Unit) {
                Var v = unit.findFirstChildOf!Var;
                Func f = unit.findFirstChildOf!Func;
                int index = minOf(v ? v.index() : int.max, f ? f.index() : int.max);
                if(index != int.max) {
                    int sIndex = unit.indexOf(this);
                    if(sIndex > index) {
                        unit.moveToIndex(index, this);
                    }
                }
            }
        } else {
            t.skip(EToken.SEMICOLON);
        }
    }
private:
}
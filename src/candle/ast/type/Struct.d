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
    bool isPacked;

    Var getVar(string name, bool includePrivate) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(v=>v.name==name)
                       .filter!(v=>v.isPublic || includePrivate)
                       .frontOrElse!Var(null);
    }
    Var[] getVars() {
        return children.filter!(it=>it.isA!Var).map!(it=>it.as!Var).array;
    }
    Type[] getVarTypes() {
        return getVars().map!(it=>it.type()).array;
    }
    Struct[] getContainedStructValues() {
        return getVarTypes().filter!(it=>!it.isPtr())
                            .map!(it=>it.getStruct())
                            .filter!(it=>it !is null)
                            .array;
    }
    Union[] getContainedUnionValues() {
        return getVarTypes().filter!(it=>!it.isPtr())
                            .map!(it=>it.getUnion())
                            .filter!(it=>it !is null)
                            .array;
    }
    uint getSize() { return calculateSize(); }
    int getAlignment() { return calculateAlignment(); }

    override ENode enode() { return ENode.STRUCT; }
    override EType etype() { return EType.STRUCT; }
    override bool isResolved() { return true; }
    override Type type() { return this; }


    override bool exactlyMatches(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Struct other = otherType.as!Struct;
        if(!other) {
            if(TypeRef tr = otherType.as!TypeRef) {
                other = tr.decorated.as!Struct;
            }
            if(!other) return false;
        }
        return id == other.id;
    }
    override bool canImplicitlyConvertTo(Type otherType) {
        assert(isResolved() && otherType.isResolved());
        Struct other = otherType.as!Struct;
        if(!other) return false;
        // TODO
        return false;
    }
    override string toString() {
        return "Struct %s".format(name); 
    } 
    override string toVerboseString() {
        string sz;
        string al;
        if(isResolved()) { 
            sz = ", size %s".format(calculateSize());
            al = ", align %s".format(calculateAlignment());
        }
        string pk = isPacked ? ", packed" : "";
        string l = ", line %s".format(coord.line+1);
        string pub = isPublic ? ", pub" : "";
        return "Struct %s%s%s%s%s%s".format(name, pub, pk, sz, al, l);
    }
    /**
     *  STRUCT ::= ['pub'] 'struct' Id ( BODY | ';')
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
            // if(Unit unit = parent.as!Unit) {
            //     Var v = unit.findFirstChildOf!Var;
            //     Func f = unit.findFirstChildOf!Func;
            //     int index = minOf(v ? v.index() : int.max, f ? f.index() : int.max);
            //     if(index != int.max) {
            //         int sIndex = unit.indexOf(this);
            //         if(sIndex > index) {
            //             unit.moveToIndex(index, this);
            //         }
            //     }
            // }
        } else {
            t.skip(EToken.SEMICOLON);
        }
    }
private:
    uint _size;
    uint _alignment;

    uint calculateSize() {
        if(_size) return _size;
        if(isPacked) todo("implement packed size");
        uint offset  = 0;
        uint largest = 1;

        foreach(t; getVarTypes()) {
            assert(t.isResolved());
            uint align_    = t.alignment();
            uint and       = (align_-1);
            uint newOffset = (offset + and) & ~and;

            offset = newOffset + t.size;

            if(align_ > largest) largest = align_;
        }

        /// The final size must be a multiple of the largest alignment
        _size = (offset + (largest-1)) & ~(largest-1);
        return _size;
    }
    /** Alignment of largest member */
    uint calculateAlignment() {
        if(_alignment) return _alignment;
        if(numChildren()==0) {
            /// An empty struct has align of 1
            _alignment = 1;
        } else {
            import std.algorithm.searching;
            _alignment = getVarTypes().map!(it=>alignment(it)).maxElement;
        }
        return _alignment;
    }
}
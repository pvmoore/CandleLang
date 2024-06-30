module candle.ast.Unit;

import candle.all;

/**
 *  Unit
 *      { Stmt }
 */
final class Unit : Node {
public:
    // Static data
    Module module_;
    string name;
    string filename;
    Token[] tokens;
    string src;

    // Dynamic data
    bool isParsed;

    this(Module module_, string filename) {
        this.module_ = module_;
        this.filename = filename;
        this.name = Filename(filename).getBaseName();

        readSource();
        lexSource();
        scanTypes();
    }
    override ENode enode() { return ENode.UNIT; }
    override bool isResolved() { return true; }
    override Type type() { return TYPE_UNKNOWN; }

    Var getVar(string name, Visibility v) {
        return getVars(v).filter!(it=>it.name==name).frontOrElse!Var(null);
    }
    Var[] getVars(Visibility v) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    Func[] getFuncs(string name, Visibility v) {
        return getFuncs(v).filter!(it=>it.name==name).array;
    }
    Func[] getFuncs(Visibility v) {
        return children.filter!(it=>it.isA!Func)
                       .map!(it=>it.as!Func)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    Enum getEnum(string name, Visibility v) {
        return getEnums(v).filter!(it=>it.name == name).frontOrElse!Enum(null);
    }
    Enum[] getEnums(Visibility v) {
        return children.filter!(it=>it.isA!Enum)
                       .map!(it=>it.as!Enum)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    Struct getStruct(string name, Visibility v) {
        return getStructs(v).filter!(it=>it.name == name).frontOrElse!Struct(null);
    }
    Struct[] getStructs(Visibility v) {
        return children.filter!(it=>it.isA!Struct)
                       .map!(it=>it.as!Struct)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    Union getUnion(string name, Visibility v) {
        return getUnions(v).filter!(it=>it.name == name).frontOrElse!Union(null);
    }
    Union[] getUnions(Visibility v) {
        return children.filter!(it=>it.isA!Union)
                       .map!(it=>it.as!Union)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    Alias getAlias(string name, Visibility v) {
        return getAliases(v).filter!(it=>it.name == name).frontOrElse!Alias(null);
    }
    Alias[] getAliases(Visibility v) {
        return children.filter!(it=>it.isA!Alias)
                       .map!(it=>it.as!Alias)
                       .filter!(it=>it.hasVisibility(v))
                       .array;
    }
    override string toString() {
        return "Unit %s (Module %s)".format(name, getModule().name);
    }
    override void parse(Tokens t) {
        int lastPos = t.pos;

        while(!t.eof()) {
            parseStmt(this, t);

            // Check that we have not stalled
            if(t.pos == lastPos) throw new Exception("No progress made");
            lastPos = t.pos;
        }
        isParsed = true;
    }
private:
    void readSource() {
        import std.file : read;
        this.src = cast(string)read(module_.directory.value ~ filename);
    }
    void lexSource() {
        this.tokens = Lexer.lex(src);
    }
    void scanTypes() {
        Tokens t = new Tokens(this);
        while(!t.eof()) {
            if(t.isValue("struct") || t.isValue("union")) {
                bool isPublic = t.isValue("pub", -1);
                string structName = t.value(1);
                module_.scannedTypes[structName] = isPublic;
            } else if(t.isValue("alias")) {
                bool isPublic = t.isValue("pub", -1);
                module_.scannedTypes[t.value(1)] = isPublic;
            } else {
                switch(t.kind()) with(EToken) {
                    case LBRACKET:
                    case LCURLY:
                    case LSQUARE:
                        t.findEndOfScope();
                        break;
                    default: break;
                }
            }
            t.next();
        }
        //log("[%s] Scanned types: %s", name, scannedTypes);
    }
}

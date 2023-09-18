module candle.ast.Unit;

import candle.all;

/**
 *  Unit
 *      { Stmt }
 */
final class Unit : Node {
public:
    // Static data
    Project project;
    string name;
    string filename;
    Token[] tokens;
    string src;

    // Dynamic data
    bool isParsed;

    this(Project project, string filename) {
        this.project = project;
        this.filename = filename;
        this.name = Filename(filename).getBaseName();

        readSource();
        lexSource();

        // TODO - scan for Types?
    }
    override ENode enode() { return ENode.UNIT; }
    override bool isResolved() { return true; }
    override Type type() { return TYPE_UNKNOWN; }

    Var getVar(string name) {
        return children.filter!(it=>it.isA!Var)
                       .map!(it=>it.as!Var)
                       .filter!(v=>v.name==name)
                       .frontOrElse!Var(null);
    }
    Var[] getVars() {
        return children.filter!(it=>it.isA!Var).map!(it=>it.as!Var).array;
    }
    Func[] getFuncs(string name, bool includePrivate) {
        return children.filter!(it=>it.isA!Func)
                       .map!(it=>it.as!Func)
                       .filter!(v=>v.name==name)
                       .filter!(v=>v.isPublic || includePrivate)
                       .array();
    }
    Func[] getFuncs() {
        return children.filter!(it=>it.isA!Func).map!(it=>it.as!Func).array;
    }
    Struct getStruct(string name) {
        return getStructs().filter!(it=>it.name == name).frontOrElse!Struct(null);
    }
    Struct[] getStructs() {
        return children.filter!(it=>it.isA!Struct).map!(it=>it.as!Struct).array;
    }
    Union getUnion(string name) {
        return getUnions().filter!(it=>it.name == name).frontOrElse!Union(null);
    }
    Union[] getUnions() {
        return children.filter!(it=>it.isA!Union).map!(it=>it.as!Union).array;
    }
    override string toString() {
        return "Unit %s (Project %s)".format(name, getProject().name);
    }
private:
    void readSource() {
        import std.file : read;
        this.src = cast(string)read(project.directory.value ~ filename);
    }
    void lexSource() {
        this.tokens = Lexer.lex(src);
    }
}
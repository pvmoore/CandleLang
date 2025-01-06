module candle.ast.Node;

import candle.all;

abstract class Node {
public:
    Node[] children;
    Node parent;
    uint id;
    FileCoord coord;

    final int numChildren() { return children.length.as!int; }
    final bool hasChildren() { return children.length > 0; }
    final bool isAttached() { 
        if(enode()==ENode.MODULE) return true;
        if(!parent) return false;
        return parent.isAttached(); 
    }

    abstract ENode enode();
    abstract Type type();
    abstract bool isResolved();

    void parse(Tokens tokens) {
        // By default do nothing
    }
    /** Will be called in bottom-up order */
    void resolve() {
        
    }
    /** Will be called in bottom-up order */
    void check() {
       
    }

    final void add(Node n) {
        n.detach();
        n.parent = this;
        children ~= n;
    }
    final void insertAt(int index, Node n) {
        n.detach();
        n.parent = this;
        children.insertAt(index, n);
    }
    final void replaceWith(Node other) {
        assert(other.parent is null);
        assert(parent !is null);
        int ourIndex = parent.indexOf(this);
        parent.insertAt(ourIndex, other);
        this.detach();
    }
    final void moveToIndex(int index, Node ch) {
        int i = indexOf(ch);
        if(i!=index) {
            ch.detach();
            insertAt(index, ch);
        }
    }
    final void detach() {
        if(parent) {
            int i = parent.indexOf(this);
            parent.children.removeAt(i);
            parent = null;
        }
    }
    final int indexOf(Node n) {
        foreach(i, ch; children) {
            if(ch is n) return i.as!int;
        }
        assert(false);
    }
    final int index() {
        assert(parent);
        return parent.indexOf(this);
    }
    final Node next() {
        if(!parent) return null;
        int i = parent.indexOf(this);
        if(i+1 < parent.numChildren()) return parent.children[i+1];
        return parent.next();
    }
    final Node prev() {
        if(!parent) return null;
        int i = parent.indexOf(this);
        if(i>0) return parent.children[i-1];
        return parent;
    }
    /** Similar to prev() but will return null if this is the first child */
    final Node prevSibling() {
        if(!parent) return null;
        int i = parent.indexOf(this);
        if(i>0) return parent.children[i-1];
        return null;
    }
    final Node first() {
        if(!hasChildren()) return null;
        return children[0];
    }
    final Node last() {
        if(!hasChildren()) return null;
        return children[$-1];
    }
    final Unit getUnit() {
        if(this.isA!Unit) return this.as!Unit;
        assert(parent);
        return parent.getUnit();
    }
    final Module getModule() {
        if(this.isA!Module) return this.as!Module;
        assert(parent);
        return parent.getModule();
    }
    final Candle getCandle() {
        if(auto p = this.as!Module) return p.candle;
        if(auto u = this.as!Unit) return u.module_.candle;
        assert(parent);
        return parent.getCandle();
    }
    final NodeRange range() {
        return NodeRange(this);
    }
    final string dumpToString(string indent = "") {
        string s = "%s%s\n".format(indent, this.isA!Type ? this.as!Type.getASTSummary() : this.toString());
        foreach(ch; children) {
            s ~= ch.dumpToString(indent ~ "  ");
        }
        return s;
    }
    T findFirstChildOf(T)() {
        foreach(ch; children) if(ch.isA!T) return ch.as!T;
        return null;
    }
    bool hasAncestor(T)() {
        if(!parent) return false;
        if(parent.isA!T) return true;
        return parent.hasAncestor!T;
    }
    T getAncestor(T)() {
        if(!parent) return null;
        if(parent.isA!T) return parent.as!T;
        return parent.getAncestor!T;
    }
protected:



private:
}

//──────────────────────────────────────────────────────────────────────────────────────────────────

bool areResolved(T)(T[] nodes) if(is(T:Node) || is(T:Type)) {
    foreach(n; nodes) if(!n.isResolved()) return false;
    return true;
}
/** Return true if all Scope Nodes are resolved including all children recursively */
bool isScopeResolved(Scope s) {
    return s.range().all!(it=>it.isResolved());
}
bool isPublic(T)(T n) if(is(T:Node) || is(T:Type)) {
    if(Struct s = n.as!Struct) return s.isPublic;
    if(Union u = n.as!Union) return u.isPublic;
    if(Enum e = n.as!Enum) return e.isPublic;
    if(Alias a = n.as!Alias) return a.isPublic;
    if(Func f = n.as!Func) return f.isPublic;
    if(Var v = n.as!Var) return v.isPublic;
    if(TypeRef tr = n.as!TypeRef) return tr.type().isPublic;
    if(Pointer p = n.as!Pointer) return false;
    if(Primitive p = n.as!Primitive) return false;
    assert(false, "isPublic %s".format(n));
}
bool isPrivate(T)(T n) if(is(T:Node) || is(T:Type)) {
    return !isPublic(n);
}
bool hasVisibility(T)(T n, Visibility v) if(is(T:Node) || is(T:Type)) {
    if(v == Visibility.ALL) return true;
    bool isPub = isPublic(n);
    bool visPub = v == Visibility.PUBLIC; 
    return isPub == visPub;
}
void writeAllUnitAsts(Candle candle) {
    foreach(p; candle.allModules()) {
        writeAllUnitAsts(candle, p);
    }
}
void writeAllUnitAsts(Candle candle, Module module_) {
    if(candle.dumpAst) {
        foreach(u; module_.getUnits()) {
            string name = "%s__%s.canast".format(module_.name, u.name);
            Filepath path = Filepath(candle.targetDirectory.add(Directory("ast")), Filename(name));

            path.write(u.dumpToString());
        }
    }
}
void writeAllModuleASTs(Candle candle) {
    if(candle.dumpAst) {
        foreach(p; candle.allModules()) {
            string name = "%s.canast".format(p.name);
            Filepath path = Filepath(candle.targetDirectory.add(Directory("ast")), Filename(name));
            
            string buf;
            foreach(ch; p.children) {
                if(!ch.isA!Unit) {
                    buf ~= ch.dumpToString("");
                }
            }
            path.write(buf);
        }
    }
}

//──────────────────────────────────────────────────────────────────────────────────────────────────

/**
 * Usage:
 *   node.range().filter!(it=>...).map!(it=>...).array;
 */
struct NodeRange {
    this(Node n) {
        stack.reserve(16);
        stack ~= NI(n, -1);
        fetchNext();
    }
    Node front() { return _front; }
    bool empty() { return _front is null; }
    void popFront() { fetchNext(); }
private:
    void fetchNext() {
        while(stack.length > 0) {

            NI* s = &stack[$-1];
            Node n = s.node;
            int i = s.i++;

            if(i == -1) {
                _front = n;
                return;

            } else if(i < n.numChildren()) {
                stack ~= NI(n.children[i], -1);
            } else {
                stack.length--;
            }
        }
        _front = null;
    }

    struct NI {
        Node node;
        int i;
    }
    NI[] stack;
    Node _front;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────

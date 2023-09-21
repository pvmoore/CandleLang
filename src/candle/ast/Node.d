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
        if(enode()==ENode.PROJECT) return true;
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
        // By default do nothing
    }
    /** Will be called in bottom-up order */
    void check() {
        // By default do nothing
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
    final Project getProject() {
        if(this.isA!Project) return this.as!Project;
        assert(parent);
        return parent.getProject();
    }
    final Candle getCandle() {
        if(auto p = this.as!Project) return p.candle;
        if(auto u = this.as!Unit) return u.project.candle;
        assert(parent);
        return parent.getCandle();
    }
    final void dump(string indent = "") {
        log("%s%s", indent, this);
        foreach(ch; children) {
            ch.dump(indent ~ "  ");
        }
    }
    final string dumpToString(string indent = "") {
        string s = "%s%s\n".format(indent, this);
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
bool areResolved(T)(T[] nodes) if(is(T:Node)) {
    foreach(n; nodes) if(!n.isResolved()) return false;
    return true;
}
void recurse(Node n, void delegate(Node n) callback) {
    callback(n);
    foreach(ch; n.children) {
        recurse(ch, callback);
    }
}

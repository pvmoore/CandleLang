module candle.ast.NodeRef;

import candle.all;

/**
 *  NodeRef
 */
final class NodeRef : Node {
public:
    Node other;

    this(Node other) {
        this.other = other;
    }

    override NKind nkind() { return NKind.NODE_REF; }
    override bool isResolved() { return other.isResolved(); }
    override Type type() { return other.type(); }
    override string toString() {
        return "NodeRef -> %s".format(other);
    }
private:
}
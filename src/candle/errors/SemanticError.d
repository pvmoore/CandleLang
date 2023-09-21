module candle.errors.SemanticError;

import candle.all;

final class SemanticError : CandleError {
public:
    this(Node node, string message) {
        this.node = node;
        this.message = message;
    }
    override string brief() {
        return formatBrief(node.getUnit(), node.coord, message);
    }
    override string verbose() {
        return formatVerboseMultiline(node.getUnit(), node.coord, message);
    }
    override bool isDuplicateOf(CandleError e) {
        auto other = e.as!SemanticError;
        if(!other) return false;
        return node.id == other.node.id;
    }
private:
    Node node;
    string message;
}
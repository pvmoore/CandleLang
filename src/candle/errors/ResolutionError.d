module candle.errors.ResolutionError;

import candle.all;

final class ResolutionError : CandleError {
public:
    this(Node node) {
        this.node = node;
    }    
    override string formatted() {
        string msg = "unresolved %s".format(node.enode);
        if(auto call = node.as!Call) {
            msg = "function '%s' not found".format(call.name);
        } else if(auto id = node.as!Id) {
            msg = "undefined";
        }
        return formattedError(node.getUnit(), node.coord, msg);
    }
    override bool isDuplicateOf(CandleError e) {
        auto other = e.as!ResolutionError;
        if(!other) return false;
        return node.id == other.node.id;
    }
private:
    Node node;
}
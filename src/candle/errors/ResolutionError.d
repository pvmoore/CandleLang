module candle.errors.ResolutionError;

import candle.all;

final class ResolutionError : CandleError {
public:
    this(Node node) {
        this.node = node;
    }    
    override string formatted() {
        string msg = "Unresolved %s".format(node.enode);
        if(auto call = node.as!Call) {
            msg = "Function '%s' not found".format(call.name);
        } else if(auto id = node.as!Id) {
            msg = "Undefined symbol '%s'".format(id.name);
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
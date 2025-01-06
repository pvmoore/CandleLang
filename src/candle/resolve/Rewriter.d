module candle.resolve.Rewriter;

import candle.all;

final class Rewriter {
public:
    static ulong getElapsedNanos() { return atomicLoad(totalNanos); }

    static void rewrite(Node replace, Node withThis) {
        todo();
    }
    static void remove(Node n) {
        n.detach();
    }
    static void toBool(Node n, bool value) {
        auto b = makeNode!Number(n.coord, value);
        n.replaceWith(b);
    }
    static void toType(Node n, Node t) {
        n.replaceWith(t);
    }
    static void toBoolEquals(Is n) {
        auto b = makeNode!Binary(n.coord);
        b.op = n.negate ? Operator.NEQ : Operator.EQ;
        b.add(n.first());
        b.add(n.first());
        n.replaceWith(b);
    }
private:
    shared static ulong totalNanos;
}

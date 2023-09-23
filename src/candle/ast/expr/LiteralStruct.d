module candle.ast.expr.LiteralStruct;

import candle.all;

/**
 *  LiteralStruct
 *      { Expr }
 */
final class LiteralStruct : Expr {
public:
    string[] names;

    Expr[] exprs() { return children.as!(Expr[]); }

    override ENode enode() { return ENode.LITERAL_STRUCT; }
    override Type type() { return struct_ ? struct_ : TYPE_UNKNOWN; }
    override int precedence() { return 0; }
    override bool isResolved() { return struct_ !is null; }
    override string toString() {
        return "LiteralStruct (%s)".format(struct_);
    }
    /**
     * LITERAL ::= '{' EXPRS '}'
     * EXPRS   ::= [ name '=' Expr { ',' name '=' Expr } ]
     */
    override void parse(Tokens t) {
        t.skip(EToken.LCURLY);

        while(!t.isKind(EToken.RCURLY)) {
            names ~= t.value(); t.next();
            t.skip(EToken.EQ);
            parseExpr(this, t);
            t.expectOneOf(EToken.COMMA, EToken.RCURLY);
            t.skipOptional(EToken.COMMA);
        }

        t.skip(EToken.RCURLY);
    }
    override void resolve() {
        if(isResolved()) return;

        Type t = Resolver.resolveTypeFromParent(this);
        struct_ = getStruct(t);
    }
    override void check() {

    }
private:
    Struct struct_;
}
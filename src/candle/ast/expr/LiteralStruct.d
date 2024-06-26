module candle.ast.expr.LiteralStruct;

import candle.all;

/**
 *  LiteralStruct
 *      { Expr }
 *
 *  eg.
 *
 *  { name = 5, key = 7 }
 *
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
     * EXPR    ::= name '=' Expr
     * EXPRS   ::= [ EXPR { ',' EXPR } ]
     */
    override void parse(Tokens t) {
        // {
        t.skip(EToken.LCURLY);

        while(!t.isKind(EToken.RCURLY)) {
            // name
            names ~= t.value(); t.next();

            // =
            t.skip(EToken.EQ);

            // Expr
            parseExpr(this, t);

            // , or }
            t.expectOneOf(EToken.COMMA, EToken.RCURLY);
            t.skipOptional(EToken.COMMA);
        }
        // }
        t.skip(EToken.RCURLY);
    }
    override void resolve() {
        if(isResolved()) return;

        // The Type must always be resolved from the parent
        Type t = Resolver.resolveTypeFromParent(this);
        struct_ = getStruct(t);
    }
    /**
     * - name must exist as a Var of the Struct
     * - name must be visible
     */
    override void check() {

    }
private:
    Struct struct_;
}

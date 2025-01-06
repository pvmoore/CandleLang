module candle.ast.expr.BuiltinFunc;

import candle.all;

/**
 *  BuiltinFunc
 *      { Expr|Type }    arguments
 *      [ Scope ]
 *
 * @assert(Expr)
 * @typeOf(Expr)
 *
 * TODO:
 *   @sizeOf @offsetOf @alignOf -> uint
 *   @isPointer @isInteger @isValue @isStruct @isEnum @isUnion -> bool
 */
final class BuiltinFunc : Expr {
public:
    string name;

    int numArgs() { return numChildren(); }
    Expr[] args() { return children.as!(Expr[]); }

    override ENode enode() { return ENode.BUILTIN_FUNC; }
    override Type type() {
        switch(name) {
            case "assert": 
                return TYPE_VOID;
            case "typeOf":
            default: 
                return TYPE_UNKNOWN; 
        } 
    }
    override int precedence() { return 200; }
    override bool isResolved() { return _isResolved; }
    override string toString() {
        string l = ", line %s".format(coord.line+1);
        return "BuiltinFunc %s%s".format(name, l);
    }
    /** 
     * BUILTIN_FUNC ::= '@' name [ ARGS ] [ STMTS ]
     * ARGS         ::= '(' [ Expr { ','  Expr} ] ')'
     * STMTS        ::= '{' { Stmt } '}'
     */
    override void parse(Tokens t) {
        // @
        t.skip(EToken.AT);

        // name
        this.name = t.value(); t.next();

        // (
        if(t.isKind(EToken.LBRACKET)) {
            t.skip(EToken.LBRACKET);

            bool hasArgs = !t.isKind(EToken.RBRACKET);
            if(hasArgs) {
                Parens p = makeNode!Parens(t.coord());
                this.add(p);

                while(!t.isKind(EToken.RBRACKET)) {
                    parseExpr(p, t);
                    t.skipOptional(EToken.COMMA);
                }
                p.detach();
                while(p.hasChildren()) {
                    this.add(p.first());
                }
            }
            // )
            t.skip(EToken.RBRACKET);
        } else {
            todo("assume a single Expr?");
        }

        // {
        if(t.isKind(EToken.LCURLY)) {
            Scope scope_ = makeNode!Scope(t.coord());
            this.add(scope_);

            t.skip(EToken.LCURLY);

            while(!t.isKind(EToken.RCURLY)) {
                if(t.eof()) syntaxError(t, "}");

                parseStmt(scope_, t);
            }
            // }
            t.skip(EToken.RCURLY);
        }
    }
    override void resolve() {
        if(isResolved()) return;
        switch(name) {
            case "assert": resolveAssert(); break;
            case "typeOf": resolveTypeOf(); break;
            default:
                break;
        }
    }
    override void check() {
        // switch(name) {
        //     case "assert":
        //     case "isType":
        //         if(numChildren()!=1) {
        //             getCandle().addError(new SyntaxError(getUnit(), coord, 
        //                 "Expected 1 argument but found %s".format(numChildren())));
        //         }
        //         break;
        //     default: break;
        // }
    }
private:
    bool _isResolved;

    void resolveAssert() {
        if(checkNumArgs(1, false)) {
            _isResolved = true;
        }
    }
    void resolveTypeOf() {
        if(checkNumArgs(1, false)) {
            if(!first().isResolved()) return;
            TypeRef tr = makeNode!TypeRef(coord, null, first().type(), getModule());
            Rewriter.toType(this, tr);
        }       
    }

    bool checkNumArgs(int requiredNum, bool hasScope) {

        int expectedNumArgs = hasScope ? requiredNum + 1 : requiredNum;

        if(numChildren() != expectedNumArgs) {
            getCandle().addError(new SyntaxError(getUnit(), coord, 
                "Expecting %s argument(s) but found %s".format(requiredNum, numChildren())));
            return false;
        }
        return true;
    }
}

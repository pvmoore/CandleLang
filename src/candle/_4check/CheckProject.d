module candle._4check.CheckProject;

import candle.all;

final class CheckProject {
public:
    this(Project project) {
        this.candle = project.candle;
        this.project = project;
    }
    void check() {
        checkChildren(project);
    }
private:
    Candle candle;
    Project project;

    void checkChildren(Node n) {
        foreach(ch; n.children) {
            check(ch);
        }
    }

    void check(Node n) {
        logCheck("check %s", n.enode());
        switch(n.enode()) with(ENode) {
            case BINARY: check(n.as!Binary); break;
            case BUILTIN_FUNC: check(n.as!BuiltinFunc); break;
            case CALL: check(n.as!Call); break;
            case CHAR: check(n.as!Char); break;
            case DOT: check(n.as!Dot); break;
            case FUNC: check(n.as!Func); break;
            case ID: check(n.as!Id); break;
            case NULL: check(n.as!Null); break;
            case NUMBER: check(n.as!Number); break;
            case POINTER: check(n.as!Pointer); break;
            case PRIMITIVE: check(n.as!Primitive); break;
            case PROJECT_ID: check(n.as!ProjectId); break;
            case RETURN: check(n.as!Return); break;
            case SCOPE: check(n.as!Scope); break;
            case STRUCT: check(n.as!Struct); break;
            case TYPE_REF: check(n.as!TypeRef); break;
            case UNARY: check(n.as!Unary); break;
            case UNIT: check(n.as!Unit); break;
            case VAR: check(n.as!Var); break;
            default: throw new Exception("CheckProject: Handle node %s".format(n.enode()));
        }
    }
    void check(Binary n) {
        checkChildren(n);
    }
    void check(BuiltinFunc n) {
        checkChildren(n);
        switch(n.name) {
            case "assert":
                if(n.numChildren()!=1) {
                    candle.addError(new SyntaxError(n.getUnit(), n.coord, "Expected 1 argument"));
                }
                break;
            default: break;
        }
    }
    void check(Call n) {
        checkChildren(n);
    }
    void check(Char n) {
        
    }
    void check(Dot n) {
        checkChildren(n);
    }
    void check(Func n) {
        checkChildren(n);
    }
    void check(Id n) {
        
    }
    void check(Null n) {
        
    }
    void check(Number n) {
        
    }
    void check(Pointer n) {
        checkChildren(n);
    }
    void check(Primitive n) {
        
    }
    void check(ProjectId n) {
        
    }
    void check(Return n) {
        checkChildren(n);
    }
    void check(Scope n) {
        checkChildren(n);
    }
    void check(Struct n) {
        checkChildren(n);
    }
    void check(TypeRef n) {
        
    }
    void check(Unary n) {
        checkChildren(n);
    }
    void check(Unit n) {
        checkChildren(n);
    }
    void check(Var n) {
        checkChildren(n);       
    }
}
module candle.emit.EmitProject;

import candle.all;

final class EmitProject {
public:
    this(Project project) {
        this.candle = project.candle;
        this.project = project;
        this.sourceBuf = new StringBuffer();
        this.headerBuf = new StringBuffer();
    }
    void emit() {
        logEmit("🕯 Emit %s", project.name);
        buf = sourceBuf;
        emit(project);

        // Write the file now
        string filename = project.name ~ ".c";
        File file = File(Filepath(candle.targetDirectory, Filename(filename)).value, "wb");
        file.write(sourceBuf.toString());
        file.close();

        // Write the file now
        string header = project.name ~ ".h";
        File hFile = File(Filepath(candle.targetDirectory, Filename(header)).value, "wb");
        hFile.write(headerBuf.toString());
        hFile.close();
    }
private:
    Candle candle;
    Project project;
    StringBuffer buf, sourceBuf, headerBuf;
    string indent;

    void push() { indent ~= "  "; }
    void pop() { indent = indent[0..$-2]; }
    bool isHeader() { return buf is headerBuf; }

    void writeStmt(A...)(string fmt, A args) {
        buf.add(indent);
        add(fmt, args);
    }
    void add(A...)(string fmt, A args) {
        buf.add(fmt, args);
    }

    void recurseChildren(Node n) {
        foreach(ch; n.children) {
            emit(ch);
        }
    }

    string getName(Id n) {
        return n.target.isPublic() ? "%s__%s".format(n.target.project().name, n.name) : n.name;
    }
    string getName(Call n) {
        return n.target.isPublic() ? "%s__%s".format(n.target.project().name, n.name) : n.name;
    }
    string getName(Struct n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Union n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Func n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }

    void emitHeader() {
        buf.add("#ifndef %s_H\n", project.name);
        buf.add("#define %s_H\n\n", project.name);
        buf.add("#include \"candle__common.h\"\n\n");
        foreach(u; project.getUnits()) {
            foreach(s; u.getStructs()) {
                if(s.isPublic) {
                    emit(s);
                }
            }
            foreach(un; u.getUnions()) {
                if(un.isPublic) {
                    emit(un);
                }
            }
            foreach(f; u.getFuncs()) {
                if(f.isPublic) {
                    emit(f, true);
                }
            }
        }
        buf.add("\n#endif // %s_H\n", project.name);
    }

    void beforeNode(Node n) {
        logEmit("emit %s", n.enode());
        Expr expr = n.as!Expr;
        Stmt stmt = n.as!Stmt;
        Var var = n.as!Var;
        bool isAStmt = stmt && !expr;
        if(var && var.isParameter()) return;
        if(isAStmt || (expr && expr.isStmt)) {
            writeStmt("");
        }
    }
    void afterExpr(Expr e) {
        if(e.isStmt) add(";\n");
    }

    void emit(Node n) {
        beforeNode(n);
        switch(n.enode()) with(ENode) {
            case BINARY: emit(n.as!Binary); break;
            case BUILTIN_FUNC: emit(n.as!BuiltinFunc); break;
            case CALL: emit(n.as!Call); break;
            case CHAR: emit(n.as!Char); break;
            case DOT: emit(n.as!Dot); break;
            case FUNC: emit(n.as!Func); break;
            case ID: emit(n.as!Id); break;
            case NULL: emit(n.as!Null); break;
            case NUMBER: emit(n.as!Number); break;
            case PARENS: emit(n.as!Parens); break;
            case POINTER: emit(n.as!Pointer); break;
            case PRIMITIVE: emit(n.as!Primitive); break;
            case PROJECT_ID: emit(n.as!ProjectId); break;
            case RETURN: emit(n.as!Return); break;
            case SCOPE: emit(n.as!Scope); break;
            case STRUCT: emit(n.as!Struct); break;
            case TYPE_REF: emit(n.as!TypeRef); break;
            case UNARY: emit(n.as!Unary); break;
            case UNIT: emit(n.as!Unit); break;
            case VAR: emit(n.as!Var); break;
            default: throw new Exception("EmitProject: Handle node %s".format(n.enode()));
        }
        if(Expr expr = n.as!Expr) {
            afterExpr(expr);
        }
    }

    void emit(Binary n) {
        emit(n.left());
        add(" %s ", stringOf(n.op));
        emit(n.right());
    }
    void emit(BuiltinFunc n) {
        switch(n.name) {
            case "assert":
                add("candle__assert(");
                emit(n.first());
                add(", \"%s\", %s)", n.getUnit().filename, n.coord.line+1);
                break;
            default: break;
        }
    }
    void emit(Call n) {
        string name = getName(n);
        add(name);
        add("(");
        foreach(i, ch; n.children) {
            if(i>0) add(", ");
            emit(ch);
        }
        add(")");
    }
    void emit(Char n) {
        add(n.stringValue);
    }
    void emit(Dot n) {
        recurseChildren(n);
    }
    void emit(Func n, bool asPrototype = false) {
        if(n.isExtern && !asPrototype) return;

        if(n.isFuncPtr) {
            // returntype (*name)(param1, param2);
            Var v = n.parent.as!Var;
            assert(v);
            emit(n.returnType().as!Node);
            add(" (*%s)(", v.name);
            foreach(i, p; n.params()) {
                if(i>0) add(",");
                emit(p.type().as!Node);
                // Should we use the name?
                // if(p.name) {
                //     add(" %s", p.name);
                // }
            }
            add(")");
            return;
        }

        if(!n.isPublic && !n.isExtern && !n.isProgramEntry) {
            add("static ");
        }

        emit(n.returnType().as!Node);

        string name = getName(n);

        add(" %s(", name);
        foreach(i, p; n.params()) {
            if(i>0) add(", ");
            emit(p);
        }
        add(")");
        if(n.isExtern || asPrototype) {
            add(";\n");
        } else {
            add(" ");
            emit(n.body_());
        }
    }
    void emit(Id n) {
        add(getName(n));
    }
    void emit(Null n) {
        add("null");
    }
    void emit(Number n) {
        add(n.value.toString());
    }
    void emit(Parens n) {
        add("(");
        emit(n.expr());
        add(")");
    }
    void emit(Pointer n) {
        emit(n.valueType().as!Node);
        add("*".repeat(n.depth));
    }
    void emit(Primitive n) {
        switch(n.etype()) with(EType) {
            case BOOL: buf.add("bool"); break;
            case UBYTE: buf.add("u8"); break;
            case BYTE: buf.add("s8"); break;
            case USHORT: buf.add("u16"); break;
            case SHORT: buf.add("s16"); break;
            case UINT: buf.add("u32"); break;
            case INT: buf.add("s32"); break;
            case ULONG: buf.add("u64"); break;
            case LONG: buf.add("s64"); break;
            case FLOAT: buf.add("f32"); break;
            case DOUBLE: buf.add("f64"); break;
            case VOID: buf.add("void"); break;
            default: throw new Exception("EmitUnit: Handle Primitive %s".format(n.etype()));
        }
    }
    void emit(ProjectId n) {
        // std.call()

        // Ignore for now
    }
    void emit(Project n) {
        writeStmt("// Project .. %s\n\n", project.name);

        // Emit header '<project_name>.h'
        buf = headerBuf;
        emitHeader();
        buf = sourceBuf;

        // Add includes for all dependent Projects
        foreach(p; n.getExternalProjects()) {
            writeStmt("#include \"%s.h\"\n", p.name);
        }

        // Add our own header
        writeStmt("#include \"%s.h\"\n", n.name);

        //writeStmt("static const char* candle_projectName;");// = \"%s\";", n.name);

        // Emit Project private prototypes
        writeStmt("// Prototypes\n");
        foreach(u; n.getUnits()) {
            foreach(s; u.getStructs()) {
                //writeStmt("struct %s;\n", getName(s));
            }
            foreach(un; u.getUnions()) {
                //writeStmt("union %s;\n", getName(un));
            }
            foreach(f; u.getFuncs()) {
                emit(f, true);
            }
        }
        add("\n");

        recurseChildren(n);
    }
    void emit(Return n) {
        add("return");
        if(n.hasChildren()) {
            add(" ");
            recurseChildren(n);
        }
        add(";\n");
    }
    void emit(Scope n) {
        add("{\n");
        push();
        recurseChildren(n);
        pop();
        add("}\n");
    }
    void emit(Struct n) {
        if(!n.isPublic || isHeader()) {
            string name = getName(n);
            writeStmt("typedef struct %s {\n", name);
            push();
            foreach(v; n.getVars()) {
                emit(v);
            }
            pop();
            add("} %s;\n\n".format(name));
        }
    }
    void emit(TypeRef n) {
        switch(n.decorated.etype()) with(EType) {
            case STRUCT:
                add("%s".format(getName(n.decorated.as!Struct)));
                break;
            case UNION:
                add(getName(n.decorated.as!Union));
                break;
            default:
                throwIf(true, "EmitProject: Handle %s", n.decorated.etype());
                break;
        }
    }
    void emit(Unary n) {
        add("%s", stringOf(n.op));
        emit(n.expr());
    }
    void emit(Union n) {
        string name = getName(n);
        writeStmt("\ttypedef union {");
        foreach(v; n.getVars()) {
            emit(v);
        }
        add("} %s;\n\n".format(name));
    }
    void emit(Unit n) {
        writeStmt("//──────────────────────────────────────────────────────────────────────────────────────────────────\n");
        writeStmt("// %s.can\n", n.name);
        writeStmt("//──────────────────────────────────────────────────────────────────────────────────────────────────\n");
        recurseChildren(n);
    }
    void emit(Var n) {
        if(n.isGlobal()) {
            add("static ");
        }

        emit(n.type().as!Node);

        bool isFunctionPtr = n.type().as!Func !is null;
        if(n.name && !isFunctionPtr) {
            add(" %s", n.name);
        }
        if(n.hasInitialiser()) {
            add(" = ");
            emit(n.initialiser());
        } else {
            if(n.isGlobal() || n.isLocal()) {
                // set a default value if possible
                if(string s = n.type().initStr()) {
                    add(" = %s", s);
                }
            }
        }
        if(!n.isParameter()) {
            add(";\n");
        }
    }
}
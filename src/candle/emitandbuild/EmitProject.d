module candle.emitandbuild.EmitProject;

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

        // Emit header '<project_name>.h'
        buf = headerBuf;
        emitHeader();

        // Emit body '<project_name>.c'
        buf = sourceBuf;
        emitBody();

        // Write the file now
        string filename = project.name ~ ".c";
        File file = File(Filepath(candle.targetDirectory, Filename(filename)).value, "wb");
        file.write(sourceBuf.toString());
        file.close();

        // Write the file now
        string header = project.includeName;
        File hFile = File(Filepath(candle.targetDirectory, Filename(header)).value, "wb");
        hFile.write(headerBuf.toString());
        hFile.close();
    }
private:
    Candle candle;
    Project project;
    StringBuffer buf, sourceBuf, headerBuf;
    string indent;
    uint line;
    bool emitLineNumbers;

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
        if(n.target.isExtern()) return n.name; 
        return n.target.isPublic() ? "%s__%s".format(n.target.project().name, n.name) : n.name;
    }
    string getName(Struct n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Union n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Alias n) {
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Func n) {
        if(n.isExtern) return n.name;
        return n.isPublic ? "%s__%s".format(n.getProject().name, n.name) : n.name;
    }

    void emitHeader() {
        buf.add("#ifndef %s__H\n", project.name);
        buf.add("#define %s__H\n\n", project.name);
        buf.add("#include \"candle__common.h\"\n\n");

        foreach(ch; project.children) {
            if(Struct s = ch.as!Struct) {
                if(s.isPublic) {
                    emit(s);
                    add("\n");
                }
            } else if(Union u = ch.as!Union) {
                if(u.isPublic) {
                    emit(u);
                    add("\n");
                }
            } else if(Enum e = ch.as!Enum) {
                if(e.isPublic) {
                    emit(e);
                    add("\n");
                }
            } else if(Alias a = ch.as!Alias) {
                if(a.isPublic) {
                    emit(a);
                    add("\n");
                }
            }
        }

        foreach(u; project.getUnits()) {
            foreach(f; u.getFuncs(Visibility.PUBLIC)) {
                emit(f, true);
            }
        }
        buf.add("\n#endif // %s__H\n", project.name);
    }
    void emitBody() {
        writeStmt("// Project .. %s\n\n", project.name);

        // Add includes for all dependent Projects
        writeStmt("// Dependency Project headers\n");
        foreach(p; project.getExternalProjects()) {
            writeStmt("#include \"%s\"\n\n", p.includeName);
        }

        // Include our own public header
        writeStmt("// Project header\n");
        writeStmt("#include \"%s\"\n\n", project.includeName);

        //writeStmt("static const char* candle_projectName;");// = \"%s\";", n.name);

        foreach(ch; project.children) {
            if(Struct s = ch.as!Struct) {
                if(!s.isPublic) {
                    emit(s);
                    add("\n");
                }
            } else if(Union u = ch.as!Union) {
                if(!u.isPublic) {
                    emit(u);
                    add("\n");
                }
            } else if(Enum e = ch.as!Enum) {
                if(!e.isPublic) {
                    emit(e);
                    add("\n");
                }
            } else if(Alias a = ch.as!Alias) {
                if(!a.isPublic) {
                    emit(a);
                    add("\n");
                }
            } else if(Unit u = ch.as!Unit) {
                // Emit this later
            } else {
                assert(false, "what is this node? %s".format(ch.enode()));
            }
        }

        writeStmt("\n// Private functions\n");
        foreach(unit; project.getUnits()) {
            unit.getFuncs(Visibility.PRIVATE)
                .each!((it) {
                    emit(it, true);
                });
        }
        add("\n");

        emitLineNumbers = true;

        foreach(u; project.getUnits()) {
            emit(u);
        }
    }
    void castTo(Type t) {
        add("(");
        emit(t.as!Node);
        add(")");
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
    void afterNode(Node n) {
        if(Expr expr = n.as!Expr) {
            if(expr.isStmt) afterStmt(expr.as!Stmt);
        }
    }
    void afterStmt(Stmt stmt) {
        add(";");
        if(candle.emitLineNumber && emitLineNumbers && !isHeader() && stmt.coord.line != line) {
            line = stmt.coord.line;
            add(" // Line %s", line+1);
        }
        add("\n");
    }

    void emit(Node n) {
        beforeNode(n);
        switch(n.enode()) with(ENode) {
            case ALIAS: emit(n.as!Alias); break;
            case AS: emit(n.as!As); break;
            case BINARY: emit(n.as!Binary); break;
            case BUILTIN_FUNC: emit(n.as!BuiltinFunc); break;
            case CALL: emit(n.as!Call); break;
            case CHAR: emit(n.as!Char); break;
            case DOT: emit(n.as!Dot); break;
            case FUNC: emit(n.as!Func); break;
            case ID: emit(n.as!Id); break;
            case LITERAL_STRUCT: emit(n.as!LiteralStruct); break;
            case NULL: emit(n.as!Null); break;
            case NUMBER: emit(n.as!Number); break;
            case PARENS: emit(n.as!Parens); break;
            case POINTER: emit(n.as!Pointer); break;
            case PRIMITIVE: emit(n.as!Primitive); break;
            case PROJECT_ID: emit(n.as!ProjectId); break;
            case RETURN: emit(n.as!Return); break;
            case SCOPE: emit(n.as!Scope); break;
            case STRING: emit(n.as!String); break;
            case STRUCT: break;
            case TYPE_REF: emit(n.as!TypeRef); break;
            case UNARY: emit(n.as!Unary); break;
            case UNIT: emit(n.as!Unit); break;
            case VAR: emit(n.as!Var); break;
            default: throw new Exception("EmitProject: Handle node %s".format(n.enode()));
        }
        afterNode(n);
    }
    void emit(Alias n) {
        add("typedef ");
        emit(n.toType().as!Node);
        add(" %s", getName(n));
        //afterStmt(n.as!Stmt);

        add(";\t// %s = ", n.name);
        emit(n.toType().as!Node);
        add(";\n");
    }
    void emit(As n) {
        castTo(n.type());
        emit(n.expr());
    }
    void emit(Binary n) {
        if(!n.type().exactlyMatches(n.left().type())) {
            castTo(n.type());
        }
        emit(n.left());
        add(" %s ", stringOf(n.op));

        bool isAssign = n.op.isAssign();
        if(isAssign || !n.type().exactlyMatches(n.right().type())) {
            castTo(n.type());
        }
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
        emit(n.left());
        if(!n.left.isA!ProjectId) {
            if(n.left().type().isPtr()) {
                add("->");
            } else {
                add(".");
            }
        }
        emit(n.right());
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
    void emit(LiteralStruct n) {
        add("{");
        if(n.names.length == 0) {
            add("0");
        } else {
            Expr[] exprs = n.exprs();
            foreach(i; 0..n.names.length) {
                if(i>0) add(", ");
                add(".%s = ", n.names[i]);
                emit(exprs[i]);
            }
        }
        add("}");
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
            case BOOL: buf.add("__bool"); break;
            case UBYTE: buf.add("__u8"); break;
            case BYTE: buf.add("__s8"); break;
            case USHORT: buf.add("__u16"); break;
            case SHORT: buf.add("__s16"); break;
            case UINT: buf.add("__u32"); break;
            case INT: buf.add("__s32"); break;
            case ULONG: buf.add("__u64"); break;
            case LONG: buf.add("__s64"); break;
            case FLOAT: buf.add("__f32"); break;
            case DOUBLE: buf.add("__f64"); break;
            case VOID: buf.add("void"); break;
            default: throw new Exception("EmitUnit: Handle Primitive %s".format(n.etype()));
        }
    }
    void emit(ProjectId n) {
        // Do we need to do anything here?
    }
    void emit(Return n) {
        add("return");
        if(n.hasChildren()) {
            add(" ");
            recurseChildren(n);
        }
        afterStmt(n);
    }
    void emit(Scope n) {
        add("{\n");
        push();
        recurseChildren(n);
        pop();
        add("}\n");
    }
    void emit(String n) {
        if(n.isRaw || n.isCharArray) {
            add("\"");
            add(n.stringValue);
            add("\"");
        } else todo("implement emit String");
    }
    void emit(Struct n) {
        if(!n.isPublic || isHeader()) {
            string name = getName(n);
            writeStmt("typedef struct %s {\n", name);
            push();
            foreach(v; n.getVars()) {
                emit(v.as!Node);
            }
            pop();
            add("} %s;\n".format(name));
        }
    }
    void emit(TypeRef n) {
        switch(n.decorated.etype()) with(EType) {
            case STRUCT:
                add(getName(n.decorated.as!Struct));
                break;
            case UNION:
                add(getName(n.decorated.as!Union));
                break;
            case ALIAS:
                add(getName(n.decorated.as!Alias));
                break;
            default:
                throwIf(true, "EmitProject.emit(TypeRef): Handle %s", n.decorated.etype());
                break;
        }
    }
    void emit(Unary n) {
        add("%s", stringOf(n.op));
        emit(n.expr());
    }
    void emit(Union n) {
        if(!n.isPublic || isHeader()) {
            string name = getName(n);
            writeStmt("\ttypedef union {");
            foreach(v; n.getVars()) {
                emit(v);
            }
            add("} %s;\n".format(name));
        }
    }
    void emit(Unit n) {
        line = 0;
        writeStmt("//──────────────────────────────────────────────────────────────────────────────────────────────────\n");
        writeStmt("// %s.can\n", n.name);
        writeStmt("//──────────────────────────────────────────────────────────────────────────────────────────────────\n");
        recurseChildren(n);
    }
    void emit(Var n) {
        if(n.isGlobal()) {
            add("static ");
        }
        if(n.isConst) {
            add("const ");
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
            afterStmt(n);
        }
    }
}

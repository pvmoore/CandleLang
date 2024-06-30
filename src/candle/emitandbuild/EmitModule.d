module candle.emitandbuild.EmitModule;

import candle.all;

final class EmitModule {
public:
    this(Module module_) {
        this.candle = module_.candle;
        this.module_ = module_;
        this.sourceBuf = new StringBuffer();
        this.headerBuf = new StringBuffer();
    }
    void emit() {
        logEmit("🕯 Emit %s", module_.name);

        // Emit header '<module_name>.h'
        buf = headerBuf;
        emitHeader();

        // Emit body '<module_name>.c'
        buf = sourceBuf;
        emitBody();

        // Write the file now
        string filename = module_.name ~ ".c";
        File file = File(Filepath(candle.targetDirectory, Filename(filename)).value, "wb");
        file.write(sourceBuf.toString());
        file.close();

        // Write the file now
        string header = module_.headerName;
        File hFile = File(Filepath(candle.targetDirectory, Filename(header)).value, "wb");
        hFile.write(headerBuf.toString());
        hFile.close();
    }
private:
    Candle candle;
    Module module_;
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

    string getName(Target t) {
        bool prependModuleName = t.isFunc() || t.isPublic();

        if(t.isExtern() || (t.isFunc() && t.func.isProgramEntry)) {
            prependModuleName = false;
        }

        return prependModuleName ? "%s__%s".format(t.module_().name, t.name()) : t.name();
    }
    // string getName(Id n) {
    //     return n.target.isPublic() ? "%s__%s".format(n.target.module_().name, n.name) : n.name;
    // }
    // string getName(Call n) {
    //     if(n.target.isExtern()) return n.name; 
    //     return n.target.isPublic() ? "%s__%s".format(n.target.module_().name, n.name) : n.name;
    // }
    string getName(Struct n) {
        if(n.isExtern) return n.name;
        return "%s__%s".format(n.getModule().name, n.name);
    }
    string getName(Union n) {
        if(n.isExtern) return n.name;
        return "%s__%s".format(n.getModule().name, n.name);
    }
    string getName(Alias n) {
        return "%s__%s".format(n.getModule().name, n.name);
    }
    string getName(Func n) {
        if(n.isExtern || n.isProgramEntry) return n.name;
        return "%s__%s".format(n.getModule().name, n.name);
    }

    void emitHeader() {
        buf.add("#ifndef %s__H\n", module_.name);
        buf.add("#define %s__H\n\n", module_.name);
        buf.add("#include \"candle__common.h\"\n\n");

        foreach(ch; module_.children) {
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

        foreach(u; module_.getUnits()) {
            foreach(f; u.getFuncs(Visibility.PUBLIC)) {
                emit(f, true);
            }
        }
        buf.add("\n#endif // %s__H\n", module_.name);
    }
    void emitBody() {
        writeStmt("// Module .. %s\n\n", module_.name);

        // Add includes for all dependent Modules
        writeStmt("// Dependency Module headers\n");
        foreach(p; module_.getExternalModules()) {
            writeStmt("#include \"%s\"\n\n", p.headerName);
        }

        // Include our own public header
        writeStmt("// Module header\n");
        writeStmt("#include \"%s\"\n\n", module_.headerName);

        //writeStmt("static const char* candle_moduleName;");// = \"%s\";", n.name);

        foreach(ch; module_.children) {
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
        foreach(unit; module_.getUnits()) {
            unit.getFuncs(Visibility.PRIVATE)
                .each!((it) {
                    emit(it, true);
                });
        }
        add("\n");

        emitLineNumbers = true;

        foreach(u; module_.getUnits()) {
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
            case MODULE_ID: emit(n.as!ModuleId); break;
            case RETURN: emit(n.as!Return); break;
            case SCOPE: emit(n.as!Scope); break;
            case STRING: emit(n.as!String); break;
            case STRUCT: break;
            case TYPE_REF: emit(n.as!TypeRef); break;
            case UNARY: emit(n.as!Unary); break;
            case UNIT: emit(n.as!Unit); break;
            case VAR: emit(n.as!Var); break;
            default: throw new Exception("EmitModule: Handle node %s".format(n.enode()));
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
        string name = getName(n.target);
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
        if(!n.left.isA!ModuleId) {
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
        add(getName(n.target));
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
    void emit(ModuleId n) {
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

            if(n.isExtern) {
                writeStmt("struct %s;\n", name);
                return;
            }

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
                throwIf(true, "EmitModule.emit(TypeRef): Handle %s", n.decorated.etype());
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

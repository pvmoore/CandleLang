module candle._5emit.EmitProject;

import candle.all;

final class EmitProject {
public:
    this(Project project) {
        this.project = project;
        this.sourceBuf = new StringBuffer();
        this.headerBuf = new StringBuffer();
    }
    void emit() {

        buf = sourceBuf;

        emit(project);

        // Write the file now
        string filename = project.name ~ ".c";
        File file = File(Filepath(project.targetDirectory(), Filename(filename)).value, "wb");
        file.write(sourceBuf.toString());
        file.close();

        // Write the file now
        string header = project.name ~ ".h";
        File hFile = File(Filepath(project.targetDirectory(), Filename(header)).value, "wb");
        hFile.write(headerBuf.toString());
        hFile.close();
    }
private:
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
        return n.target.isPublic() ? "%s_%s".format(n.target.project().name, n.name) : n.name;
    }
    string getName(Call n) {
        return n.target.isPublic() ? "%s_%s".format(n.target.project().name, n.name) : n.name;
    }
    string getName(Struct n) {
        return n.isPublic ? "%s_%s".format(n.getProject().name, n.name) : n.name;
    }
    string getName(Union n) {
        return n.isPublic ? "%s_%s".format(n.getProject().name, n.name) : n.name;
    }

    void emitCommonHeaderItems() {
        buf.add("// ============== Common typedefs\n");
        buf.add("#ifndef CANDLE_COMMON_TYPEDEFS_H\n");
        buf.add("#define CANDLE_COMMON_TYPEDEFS_H\n\n");
        buf.add("typedef unsigned char bool;\n");
        buf.add("typedef unsigned char ubyte;\n");
        buf.add("typedef signed char byte;\n");
        buf.add("typedef unsigned short ushort;\n");
        buf.add("typedef unsigned int uint;\n");
        buf.add("typedef unsigned long long ulong;\n");
        buf.add("#define true 1\n");
        buf.add("#define false 0\n");
        buf.add("#define null 0\n\n");
        buf.add("#endif // CANDLE_COMMON_TYPEDEFS_H\n\n");
        buf.add("// ============== Publics\n\n");
    }

    void emitHeader() {
        buf.add("#ifndef %s_H\n", project.name);
        buf.add("#define %s_H\n\n", project.name);
        emitCommonHeaderItems();
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

    void emit(Node n) {
        logEmit("emit %s", n.nkind());
        switch(n.nkind()) with(NKind) {
            case BINARY: emit(n.as!Binary); break;
            case CALL: emit(n.as!Call); break;
            case CHAR: emit(n.as!Char); break;
            case DOT: emit(n.as!Dot); break;
            case FUNC: emit(n.as!Func); break;
            case ID: emit(n.as!Id); break;
            case NULL: emit(n.as!Null); break;
            case NUMBER: emit(n.as!Number); break;
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
            default: throw new Exception("EmitUnit: Handle node %s".format(n.nkind()));
        }
    }

    void emit(Binary n) {
        emit(n.left());
        add(" %s ", stringOf(n.op));
        emit(n.right());
    }
    void emit(Call n) {

        string name = getName(n);

        if(n.isStmt) {
            writeStmt(name);
        } else {
            add(name);
        }
        add("(");
        foreach(i, ch; n.children) {
            if(i>0) add(", ");
            emit(ch);
        }
        add(")");

        if(n.isStmt) add(";\n");
    }
    void emit(Char n) {
        add(n.stringValue);
    }
    void emit(Dot n) {
        recurseChildren(n);
    }
    void emit(Func n, bool asPrototype = false) {
        if(n.isExtern && !asPrototype) return;

        emit(n.returnType().as!Node);

        string name = n.isPublic ? "%s_%s".format(project.name, n.name) : n.name;

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
        switch(n.value.kind) with(TypeKind) {
            case FLOAT: add("f"); break;
            case LONG: add("LL"); break;
            case ULONG: add("ULL"); break;
            default: break;
        }
    }
    void emit(Pointer n) {
        emit(n.valueType().as!Node);
        add("*".repeat(n.depth));
    }
    void emit(Primitive n) {
        switch(n.tkind()) with(TypeKind) {
            case BOOL: buf.add("bool"); break;
            case UBYTE: buf.add("ubyte"); break;
            case BYTE: buf.add("byte"); break;
            case USHORT: buf.add("ushort"); break;
            case SHORT: buf.add("short"); break;
            case UINT: buf.add("uint"); break;
            case INT: buf.add("int"); break;
            case ULONG: buf.add("ulong"); break;
            case LONG: buf.add("long long"); break;
            case FLOAT: buf.add("float"); break;
            case DOUBLE: buf.add("double"); break;
            case VOID: buf.add("void"); break;
            default: throw new Exception("EmitUnit: Handle Primitive %s".format(n.tkind()));
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

        // Add includes for all external Project dependencies here ...
        foreach(p; project.allProjects()) {
            writeStmt("#include \"%s.h\"\n", p.name);
        }

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
        writeStmt("return");
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
        switch(n.decorated.tkind()) with(TypeKind) {
            case STRUCT:
                add("%s".format(getName(n.decorated.as!Struct)));
                break;
            case UNION:
                add(getName(n.decorated.as!Union));
                break;
            default:
                throwIf(true, "EmitProject: Handle %s", n.decorated.tkind());
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
        writeStmt("// Unit %s\n", n.name);
        writeStmt("//──────────────────────────────────────────────────────────────────────────────────────────────────\n");
        recurseChildren(n);
    }
    void emit(Var n) {
        if(!n.isParameter()) writeStmt("");
        emit(n.type().as!Node);
        if(n.name) {
            add(" %s", n.name);
        }
        if(n.hasInitialiser()) {
            add(" = ");
            emit(n.initialiser());
        }
        if(!n.isParameter()) {
            add(";\n");
        }
    }
}
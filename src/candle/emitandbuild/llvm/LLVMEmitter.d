module candle.emitandbuild.llvm.LLVMEmitter;

import candle.all;
import llvm2x;

final class LLVMEmitter {
public:
    this(Candle candle) {
        this.candle = candle;
        initialise();
    }
    void emitAllModules() {
        llvm = new LLVMContextWrapper();
        scope(exit) destroy!false(llvm);

        setDiagnosticHandler();

        foreach(m; candle.modules) {
            if(m.name != "test") continue;
            emitModule(m);
        }
    }
private:
    Candle candle;
    LLVMContextWrapper llvm;
    LLVMModuleRef currModule;   // current module
    LLVMValueRef currFuncValue; // current function if we are inside one
    LLVMValueRef lhs;           // current lvalue for store operations
    LLVMValueRef rhs;           // current rvalue 

    void initialise() {
        uint major, minor, patch;
        LLVMGetVersion(&major, &minor, &patch);
        log("LLVM version: %s.%s.%s", major,  minor, patch);
    }
    void recurseChildren(Node n) {
        foreach(ch; n.children) {
            emit(ch);
        }
    }
    void emit(Node n) {
        switch(n.enode()) {
            case ENode.ALIAS: emit(n.as!Alias); break; 
            case ENode.AS: emit(n.as!As); break;
            case ENode.BUILTIN_FUNC: emit(n.as!BuiltinFunc); break;
            case ENode.FUNC: emit(n.as!Func); break;
            case ENode.NUMBER: emit(n.as!Number); break;
            case ENode.STRUCT: emit(n.as!Struct); break;
            case ENode.UNIT: emit(n.as!Unit); break;
            case ENode.VAR: emit(n.as!Var); break;
            default: throwIf(true, "Handle Enode.%s parent = %s", n.enode(), n.parent.enode()); break;
        }
    }
    void emitModule(Module m) {
        log("Emitting module %s", m.name);
        this.currModule = llvm.createModule(m.name);

        recurseChildren(m);

        log("%s", currModule.printModuleToString());
    }
    void emit(Alias a) {
        log("Emitting alias %s", a.name);
        // Ignore
    }
    void emit(As n) {
        log("Emitting as");

        // Expr as Type
        
        todo("cast");
    }
    void emit(BuiltinFunc n) {
        log("Emitting builtin function %s", n.name);
        switch(n.name) {
            case "assert":
                // ignore for now

                //add("candle__assert(");
                //emit(n.first());
                // add(", \"%s\", %s)", n.getUnit().filename, n.coord.line+1);
                break;
            default: todo("Handle builtin function %s".format(n.name)); break;
        }
    }
    void emit(Struct s) {
        todo("Emitting struct %s".format(s.name));

        // assume this is a named struct
        //LLVMTypeRef structType = llvm.structType(s.name, s.getVarTypes().map!(f => getLLVMType(f)).array, false);
    }
    void emit(Func f) {
        log("Emitting function %s", f.name);

        LLVMTypeRef returnType = getLLVMType(f.returnType());
        LLVMTypeRef[] paramTypes = f.paramTypes().map!(t => getLLVMType(t)).array;

        LLVMTypeRef funcType = LLVMFunctionType(returnType, paramTypes);
        this.currFuncValue = LLVMAddFunction(currModule, f.name.toStringz(), funcType);

        LLVMSetLinkage(currFuncValue, LLVMLinkage.LLVMInternalLinkage);
        LLVMSetFunctionCallConv(currFuncValue, CallingConv.C); // CallingConv.Fast

        LLVMBasicBlockRef entry = LLVMAppendBasicBlock(currFuncValue, "entry");
        LLVMPositionBuilderAtEnd(llvm.builder, entry);

        recurseChildren(f.body_());

        // Add return void if needed
        if(f.returnType().etype() == EType.VOID) {
            LLVMValueRef ret = LLVMBuildRetVoid(llvm.builder);
        }

        LLVMVerifyFunction(currFuncValue, LLVMVerifierFailureAction.LLVMPrintMessageAction);
    }
    void emit(Number n) {
        log("Emitting Number %s", n.stringValue);
        LLVMTypeRef numType = getLLVMType(n.type());
        log("  type: %s", numType.toString());

        LLVMValueRef value;
        switch(n.value.kind) {
            case EType.UBYTE:  value = LLVMConstInt(numType, n.value.asLong(), 0); break;
            case EType.BYTE:   value = LLVMConstInt(numType, n.value.asLong(), 1); break;
            case EType.USHORT: value = LLVMConstInt(numType, n.value.asLong(), 0); break;
            case EType.SHORT:  value = LLVMConstInt(numType, n.value.asLong(), 1); break;
            case EType.UINT:   value = LLVMConstInt(numType, n.value.asLong(), 0); break;
            case EType.INT:    value = LLVMConstInt(numType, n.value.asLong(), 1); break;
            case EType.ULONG:  value = LLVMConstInt(numType, n.value.asLong(), 0); break;
            case EType.LONG:   value = LLVMConstInt(numType, n.value.asLong(), 1); break;
            case EType.FLOAT:  value = LLVMConstReal(numType, n.value.asDouble()); break;
            case EType.DOUBLE: value = LLVMConstReal(numType, n.value.asDouble()); break;
            default: throwIf(true, "We shouldn't get here. type is %s", n.value.kind);
        }
        this.rhs = value;
    }
    void emit(Unit u) {
        log("Emitting unit %s", u.name);
        recurseChildren(u);
    }
    void emit(Var v) {
        log("Emitting var %s".format(v.name));
        LLVMTypeRef varType = getLLVMType(v.type());
        if(v.isLocal()) {
            log("Local...%s %s", varType.toString(), v.name);
            this.lhs = LLVMBuildAlloca(llvm.builder, varType, v.name.toStringz());
        } else if(v.isGlobal()) {
            log("Global...");
            this.lhs = LLVMAddGlobal(currModule, varType, v.name.toStringz());
        } else if(v.isParameter()) {
            log("Parameter...");
            todo("Handle parameter %s".format(v.name));
            this.lhs = LLVMGetParam(currFuncValue, v.index);
        } else todo("Handle var %s".format(v.name));

        if(v.hasInitialiser()) {
            log("Initialiser...");
            emit(v.initialiser());
            this.rhs = LLVMBuildStore(llvm.builder, this.rhs, this.lhs);
        }
        log("Var done");
    }
    LLVMTypeRef getLLVMType(Type t) {
        switch(t.etype()) {
            case EType.VOID: return llvm.voidType();
            case EType.BOOL: return llvm.int1Type();
            case EType.BYTE: return llvm.int8Type();
            case EType.SHORT: return llvm.int16Type();
            case EType.INT: return llvm.int32Type();
            case EType.LONG: return llvm.int64Type();
            case EType.FLOAT: return llvm.floatType();
            case EType.DOUBLE: return llvm.doubleType();
            default: throwIf(true, "Handle EType.%s", t.etype());
        }
        assert(false);
    }
    void setDiagnosticHandler() {
        // Set the Diagnostic handler
        void* diagnosticContext = null;
        LLVMContextSetDiagnosticHandler(llvm.ctx, &myDiagnosticHandler, diagnosticContext);
    }
}

extern(C) void myDiagnosticHandler(LLVMDiagnosticInfoRef info, void* ctx) {
    log("Diagnostic handler called");
    LLVMDiagnosticSeverity severity = LLVMGetDiagInfoSeverity(info);
    string msg = cast(string)LLVMGetDiagInfoDescription(info).fromStringz();
    log("[%s]: ", severity, msg);
}



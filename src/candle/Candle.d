module candle.Candle;

import candle.all;

enum CompileState {
    NONE,
    PREPARING,
    PARSING,
    RESOLVING,
    CHECKING,
    EMITTING,
    BUILDING
}

final class Candle {
public:
    // Static data
    bool isDebug;
    string subsystem;
    Directory mainDirectory;
    Directory targetDirectory;
    bool rtChecksNullRef = true;
    bool rtChecksOob = true;

    bool dumpAst;
    bool emitLineNumber;

    // Dynamic data
    Module mainModule;
    Module[string] modules;
    CompileState compileState;
    
    Module[] allModules() { return modules.values(); }
    bool hasErrors() { return errors.length > 0; }
    CandleError[] getErrors() { return errors; }

    this() {
        logo();
    }
    void readConfig(string filename) {
        // TODO
    }

    Module getOrCreateModule(Directory directory) {
        assert(compileState == compileState.PREPARING);

        Module[] ms = modules.values().find!(it=>it.directory == directory);
        if(ms.length > 0) {
            return ms[0];
        }
        Module m = makeNode!Module(this, directory);
        this.modules[m.name] = m;
        return m;
    }
    bool compile() {
        this.compileState = CompileState.NONE;
        this.mainModule = null;
        this.modules.clear();

        ensureDirectoryExists(targetDirectory);
        ensureDirectoryExists(targetDirectory.add(Directory("build")));

        if(dumpAst) {
            ensureDirectoryExists(targetDirectory.add(Directory("ast")));
        }

        bool verbose = false;

        try{
            //──────────────────────────────────────────────────────────────────────────────────────────────────
            // Gather all Modules 
            if(verbose) log("Preparing");
            compileState = CompileState.PREPARING;
            mainModule = getOrCreateModule(mainDirectory);

            //──────────────────────────────────────────────────────────────────────────────────────────────────    
            if(verbose) log("Parsing");
            compileState = CompileState.PARSING;
            lexAndParseAllModules();
            writeAllUnitAsts(this);

            //──────────────────────────────────────────────────────────────────────────────────────────────────
            if(verbose) log("Resolving");
            compileState = CompileState.RESOLVING;
            if(!resolveAllModules()) {
                return false;
            }

            writeAllUnitAsts(this);

            //──────────────────────────────────────────────────────────────────────────────────────────────────
            if(verbose) log("Checking");
            compileState = CompileState.CHECKING;
            checkAllModules();
            if(hasErrors()) return false;

            // After this point we should not get any more CandleErrors

            //──────────────────────────────────────────────────────────────────────────────────────────────────
            if(verbose) log("Emitting");
            compileState = CompileState.EMITTING;
            emitAllModules();

            writeAllModuleASTs(this);

            //──────────────────────────────────────────────────────────────────────────────────────────────────
            if(verbose) log("Building");
            compileState = CompileState.BUILDING;
            if(buildAllModules()) {
                if(link()) {
                    log(ansiWrap("Success ", Ansi.GREEN) ~ Ansi.GREEN_BOLD ~ "✔✔✔" ~ Ansi.RESET);
                } else {
                    log(ansiWrap("Failed ", Ansi.RED) ~ Ansi.RED_BOLD ~ "✘✘✘" ~ Ansi.RESET);
                }
                dumpStats();
            }    

        }catch(AbortCompilation e) {
            return false;
        }catch(Exception e) {
            log("Exception: %s", e);
            return false;
        }finally{
            compileState = CompileState.NONE;
            writeAllUnitAsts(this);
        }
        return true;
    }
    void addError(CandleError error) {
        writefln("ADDING %s", error);
        foreach(e; errors) {
            if(error.isDuplicateOf(e)) return;
        }
        errors ~= error;
    }
    CandleError[] findErrors(EError err) {
        return errors.filter!(it=>it.eerror() == err).array;
    }
    bool removeError(CandleError err) { 
        foreach(i, e; errors) {
            if(e.eerror() == err.eerror() && e.coord() == err.coord()) {
                errors.removeAt(i);
                return true;
            }
        }
        return false;
    }
private:
    CandleError[] errors;

    void logo() {
        log("\n══════════════════════");
        log(" " ~ ansiWrap("🕯", Ansi.WHITE_BOLD) ~"Candle Lang %s", Version.stringOf);
        log("══════════════════════\n");
    }
    void ensureDirectoryExists(Directory dir) {
        if(!dir.exists()) {
            dir.create();
        } else {
            // Clean it?
        }
    }
    void lexAndParseAllModules() {
        foreach(m; allModules()) {
            m.lexAndParseUnits();
        }
    }
    bool resolveAllModules() {
        bool resolved = false;
        int maxPasses = 4;
        for(int pass = 0; !resolved && pass < maxPasses; pass++) {
            // Run a resolve phase on all Modules (even if there are errors)
            resolved = Resolver.resolveAllModules(this, pass);
        }
        // Convert unresolved nodes to ResolutionErrors
        if(!resolved) {
            Node[] nodes;
            foreach(m; allModules()) {
                nodes ~= m.range().filter!(it=>!it.isResolved()).array;
            }
            foreach(Node n; nodes) {
                addError(new ResolutionError(EError.SNF, n));
            }
            assert(errors, "Where are the resolution errors?");
        }
        return resolved;
    }
    void checkAllModules() {
        Checker.checkAllModules(this);
    }
    void emitAllModules() {
        Emitter.emitAllModules(this);
    }
    /** 
     * Build all Modules into one object file per module
     */
    bool buildAllModules() {
        return Builder.buildAllModules(this);
    }
    /** 
     * Link all object files together
     */
    bool link() {
        return Linker.link(this);
    }
    void dumpStats() {
        //  🌩🌧🌤🌻🍒🌹🍓🍔✒✕✖✗✘✓✔🗹♏
        log("╔═════════════════════════════════════════════════════════════════════");
        log("║ " ~ ansiWrap("Modules", Ansi.BLUE_BOLD));
        foreach(p; allModules().sort()) {
            log("║ %s", p);
        }
        log("╟─────────────────────────────────────────────────────────────────────");
        log("║ " ~ ansiWrap("Timings", Ansi.BLUE_BOLD));
        log("║ Lexing ...... %.2f ms (%s files)", Lexer.getElapsedNanos()/ONE_MILLION, Lexer.getNumLexedFiles());
        log("║ Parsing ..... %.2f ms", Parser.getElapsedNanos()/ONE_MILLION);
        log("║ Resolving ... %.2f ms", Resolver.getElapsedNanos()/ONE_MILLION);
        log("║ Rewriting ... %.2f ms", Rewriter.getElapsedNanos()/ONE_MILLION);
        log("║ Checking .... %.2f ms", Checker.getElapsedNanos()/ONE_MILLION);
        log("║ Emitting .... %.2f ms", Emitter.getElapsedNanos()/ONE_MILLION);
        log("║ Building .... %.2f ms", Builder.getElapsedNanos()/ONE_MILLION);
        log("║ Linking ..... %.2f ms", Linker.getElapsedNanos()/ONE_MILLION);
        log("╟─────────────────────────────────────────────────────────────────────");

        auto stats = GC.stats();
        auto profileStats = GC.profileStats();
        log("║ " ~ ansiWrap("GC Stats", Ansi.BLUE_BOLD));
        log("║ Used .............. %s MB (%000,s bytes)", stats.usedSize/(1024*1024), stats.usedSize);
        log("║ Free .............. %s MB (%000,s bytes)", stats.freeSize/(1024*1024), stats.freeSize);
        log("║ Collections ....... %s", profileStats.numCollections);
        log("║ Collection time ... %.2f ms", profileStats.totalCollectionTime.total!"nsecs"/1000000.0);
        log("║ Pause time ........ %.2f ms", profileStats.totalPauseTime.total!"nsecs"/1000000.0);
        log("╚═════════════════════════════════════════════════════════════════════");
    }
}

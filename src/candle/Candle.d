module candle.Candle;

import candle.all;

final class Candle {
public:
    // Static data
    bool isDebug;
    string subsystem;
    Directory mainDirectory;
    Directory targetDirectory;
    bool nullChecks = true;
    bool dumpAst;

    // Generated data
    Project mainProject;
    Project[string] projects;
    
    Project[] allProjects() { return projects.values(); }
    bool hasErrors() { return errors.length > 0; }
    CandleError[] getErrors() { return errors; }

    void readConfig(string filename) {
        // TODO
    }
    bool compile() {
        logo();
        ensureDirectoryExists(targetDirectory);
        ensureDirectoryExists(targetDirectory.add(Directory("build")));

        if(dumpAst) {
            ensureDirectoryExists(targetDirectory.add(Directory("ast")));
        }

        mainProject = makeNode!Project(this, mainDirectory);

        try{
            if(!parseAndResolve()) {
                return false;
            }

            checkAllProjects();
            if(hasErrors()) return false;

            emitAllProjects();

            if(buildAllProjects()) {
                if(link()) {
                    // Success
                    log("OK " ~ Ansi.GREEN_BOLD ~ "✔✔✔" ~ Ansi.RESET);
                } else {
                    // Fail
                    log("Failed " ~ Ansi.RED_BOLD ~ "✘✘✘" ~ Ansi.RESET);
                }
            }    

            //  🌩🌧🌤🌻🍒🌹🍓🍔✒✕✖✗✘✓✔🗹♏

            log("\n════════════════════════════════════════════════════════════════════════════════════════");
            log("Projects:");
            foreach(p; allProjects()) {
                log("  %s", p);
            }
            log("════════════════════════════════════════════════════════════════════════════════════════");
            log("Timing:");
            log("  Lexing ..... %.2f ms (%s files)", Lexer.getElapsedNanos()/1_000_000.0, Lexer.getNumLexedFiles());
            log("  Parsing .... %.2f ms", Parser.getElapsedNanos()/1_000_000.0);
            log("  Resolving .. %.2f ms", Resolver.getElapsedNanos()/1_000_000.0);
            log("  Rewriting .. %.2f ms", Rewriter.getElapsedNanos()/1_000_000.0);
            log("  Checking ... %.2f ms", Checker.getElapsedNanos()/1_000_000.0);
            log("  Emitting ... %.2f ms", Emitter.getElapsedNanos()/1_000_000.0);
            log("  Building ... %.2f ms", Builder.getElapsedNanos()/1_000_000.0);
            log("  Linking .... %.2f ms", Linker.getElapsedNanos()/1_000_000.0);
            log("════════════════════════════════════════════════════════════════════════════════════════");

        }catch(AbortCompilation e) {
            return false;
        }catch(Exception e) {
            log("Exception: %s", e);
            return false;
        }finally{
            if(dumpAst) {
                foreach(p; allProjects()) {
                    foreach(u; p.getUnits()) {
                        writeAst(u);
                    }
                }
            }
        }
        return true;
    }
    void addError(CandleError error) {
        foreach(e; errors) {
            if(error.isDuplicateOf(e)) return;
        }
        errors ~= error;
    }
private:
    CandleError[] errors;

    void logo() {
        log("\n══════════════════════");
        log(" " ~ ansiWrap("🕯", Ansi.WHITE_BOLD) ~"Candle Lang %s", 0.1);
        log("══════════════════════\n");
    }
    void ensureDirectoryExists(Directory dir) {
        if(!dir.exists()) {
            dir.create();
        } else {
            // Clean it?
        }
    }
    bool parseAndResolve() {
        bool resolved = false;
        int maxPasses = 2;
        for(int pass = 0; !resolved && pass < maxPasses; pass++) {
            // Run a parse phase on all Projects
            parseAllProjects(pass);

            // Run a resolve phase on all Projects
            resolved = resolveAllProjects(pass);
        }
        if(!resolved) {
            Node[] nodes;
            foreach(p; allProjects()) {
                p.getUnresolved(nodes);
            }
            foreach(Node n; nodes) {
                addError(new ResolutionError(n));
            }
            assert(errors, "Where are the resolution errors?");
        }
        return resolved;
    }

    void parseAllProjects(int pass) {
        logParse("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; allProjects()) {
            logParse("  Parse %s", p);

            Parser.parse(p);
        }
    }
    bool resolveAllProjects(int pass) {
        logResolve("Resolve (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        bool allResolved = true;
        foreach(p; allProjects()) {
            logResolve("  Resolve %s", p);

            allResolved &= Resolver.resolve(p);
        }
        logResolve("  All resolved = %s", allResolved);
        return allResolved;
    }
    void checkAllProjects() {
        logCheck("Check ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; allProjects()) {
            logCheck("  Check %s", p.name);
            Checker.check(p);
        }
    }
    void emitAllProjects() {
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        new CommonHeader(this).emit();  
        foreach(p; allProjects()) {
            Emitter.emit(p);
        }
    }
    /** 
     * Build all Projects into one object file per project
     */
    bool buildAllProjects() {
        logBuild("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; allProjects()) {
            bool result = Builder.build(p);
            if(!result) return false;
        }
        return true;
    }
    /** 
     * Link all object files together
     */
    bool link() {
        return Linker.link(this);
    }
}
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
    bool emitLineNumber;

    // Generated data
    Project mainProject;
    Project[string] projects;
    bool astDumped;
    
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

            writeAllUnitAsts(this);

            checkAllProjects();
            if(hasErrors()) return false;

            // After this point we should not get any more CandleErrors

            emitAllProjects();

            writeAllProjectASTs(this);

            if(buildAllProjects()) {
                if(link()) {
                    log(ansiWrap("Success ", Ansi.GREEN) ~ Ansi.GREEN_BOLD ~ "✔✔✔" ~ Ansi.RESET);
                } else {
                    log(ansiWrap("Failed ", Ansi.RED) ~ Ansi.RED_BOLD ~ "✘✘✘" ~ Ansi.RESET);
                }
            }    

            dumpStats();

        }catch(AbortCompilation e) {
            return false;
        }catch(Exception e) {
            log("Exception: %s", e);
            return false;
        }finally{
            writeAllUnitAsts(this);
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
    bool parseAndResolve() {
        bool resolved = false;
        int maxPasses = 3;
        for(int pass = 0; !resolved && !hasErrors() && pass < maxPasses; pass++) {

            // Run a parse phase on all Projects
            parseAllProjects(pass);

            // Run a resolve phase on all Projects
            resolved = resolveAllProjects(pass);
        }
        // Convert unresolved nodes to ResolutionErrors
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
        Parser.parseAllProjects(this, pass);
    }
    bool resolveAllProjects(int pass) {
        return Resolver.resolveAllProjects(this, pass);
    }
    void checkAllProjects() {
        Checker.checkAllProjects(this);
    }
    void emitAllProjects() {
        Emitter.emitAllProjects(this);
    }
    /** 
     * Build all Projects into one object file per project
     */
    bool buildAllProjects() {
        return Builder.buildAllProjects(this);
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
        log("║ " ~ ansiWrap("Projects", Ansi.BLUE_BOLD));
        foreach(p; allProjects()) {
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
        log("╚═════════════════════════════════════════════════════════════════════");
    }
}

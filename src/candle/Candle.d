module candle.Candle;

import candle.all;

final class Candle {
public:
    // Static data
    bool isDebug;
    string subsystem;
    Directory mainDirectory;
    Directory targetDirectory;
    bool dumpAst;

    // Generated data
    Project mainProject;
    Project[string] projects;
    CandleError[] errors;
    
    Project[] allProjects() { return projects.values(); }

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

            if(!checkAllProjects()) {
                return false;
            }

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
            log("  Lexing %.2f ms (%s files)", LexerManager.getElapsedNanos()/1_000_000.0, LexerManager.getNumLexedFiles());
            log("════════════════════════════════════════════════════════════════════════════════════════");

        }catch(AbortCompilation e) {
            return false;
        }catch(Exception e) {
            log("Exception: %s", e);
            return false;
        }finally{
            
        }
        return true;
    }
private:
    void logo() {
        log("\n══════════════════════");
        log(" 🕯 Candle Lang %s", 0.1);
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
                errors ~= new ResolutionError(n);
            }
            assert(errors, "Where are the resolution errors?");
        }
        return resolved;
    }

    void parseAllProjects(int pass) {
        logParse("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; allProjects()) {
            logParse("  Parse %s", p);

            auto parser = new ParseProject(p);
            parser.parse();
        }
    }
    bool resolveAllProjects(int pass) {
        logResolve("Resolve (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        bool allResolved = true;
        foreach(p; allProjects()) {
            logResolve("  Resolve %s", p);

            auto resolver = new ResolveProject(p);
            allResolved &= resolver.resolve();
        }
        logResolve("  All resolved = %s", allResolved);
        return allResolved;
    }
    bool checkAllProjects() {
        logCheck("Check ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        bool allPassCheck = true;
        foreach(p; allProjects()) {
            logCheck("  Check %s", p.name);

            auto checker = new CheckProject(p);
            allPassCheck |= checker.check();
        }
        return allPassCheck;
    }
    void emitAllProjects() {
        logEmit("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        new CommonHeader(this).emit();  
        foreach(p; allProjects()) {
            new EmitProject(p).emit();
        }
    }
    /** 
     * Build all Projects into one object file per project
     */
    bool buildAllProjects() {
        logBuild("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        foreach(p; allProjects()) {
            auto builder = new BuildProject(p);
            if(!builder.build()) {
                return false;
            }
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
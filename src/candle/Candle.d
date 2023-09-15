module candle.Candle;

import candle.all;

final class Candle {
public:
    this(Compilation comp) {
        this.comp = comp;
        comp.mainProject = makeNode!Project(comp, comp.mainDirectory);
        comp.mainProject.dumpProperties();
    }
    void compile() {
        log("Compiling");
        try{
            if(parseAndResolve()) {

                if(checkAllProjects()) {

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
                }
            }

            //  🌩🌧🌤🌻🍒🌹🍓🍔✒✕✖✗✘✓✔🗹♏

            log("\n════════════════════════════════════════════════════════════════════════════════════════");
            log("Projects:");
            foreach(p; comp.allProjects()) {
                log("  %s", p);
            }
            log("════════════════════════════════════════════════════════════════════════════════════════");
            log("Timing:");
            log("  Lexing %.2f ms (%s files)", LexerManager.getElapsedNanos()/1_000_000.0, LexerManager.getNumLexedFiles());
            log("════════════════════════════════════════════════════════════════════════════════════════");

        }catch(SyntaxError e) {
            log("%s", e.formatted());
        }catch(Exception e) {
            log("Exception: %s", e);
        }
    }
private:
    Compilation comp;

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
            log("There were problems found");
        }
        return resolved;
    }

    void parseAllProjects(int pass) {
        log("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; comp.allProjects()) {
            logParse("  Parse %s", p);

            auto parser = new ParseProject(p);
            parser.parse();
        }
    }
    bool resolveAllProjects(int pass) {
        log("Resolve (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        bool allResolved = true;
        foreach(p; comp.allProjects()) {
            logResolve("Resolve %s", p);

            auto resolver = new ResolveProject(p);
            allResolved &= resolver.resolve();
        }
        log("   All resolved = %s", allResolved);
        return allResolved;
    }
    bool checkAllProjects() {
        log("Check ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        bool allPassCheck = true;
        foreach(p; comp.allProjects()) {
            logCheck("  Check %s", p.name);

            auto checker = new CheckProject(p);
            allPassCheck |= checker.check();
        }
        return allPassCheck;
    }
    void emitAllProjects() {
        log("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");
        new CommonHeader(comp).emit();  
        foreach(p; comp.allProjects()) {
            new EmitProject(p).emit();
        }
    }
    /** 
     * Build all Projects into one object file per project
     */
    bool buildAllProjects() {
        log("Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");

        foreach(p; comp.allProjects()) {
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
        return Linker.link(comp.mainProject);
    }
}
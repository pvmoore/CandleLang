module candle.Candle;

import candle.all;

final class Candle {
public:
    this(BuildProperties props) {
        this.mainProject = makeNode!Project(props, props.mainDirectory);
        mainProject.dumpProperties();
    }
    void compile() {
        log("Compiling");
        try{

            // Parse and Resolve phases. These will need to be run several times until all
            // Nodes are resolved

            bool resolved = false;
            int maxPasses = 2;
            for(int pass = 0; !resolved && pass < maxPasses; pass++) {
                // Run a parse phase on all Projects
                parseAllProjects(pass);

                // Run a resolve phase on all Projects
                resolved = resolveAllProjects(pass);
            }

            if(resolved) {

                // Perform semantic checking on all Projects
                if(checkAllProjects()) {

                    emitAllProjects();

                    if(link()) {
                        // Success
                        log("OK " ~ Ansi.GREEN_BOLD ~ "✔✔✔" ~ Ansi.RESET);
                    } else {
                        // Fail
                        log("Failed " ~ Ansi.RED_BOLD ~ "✘✘✘" ~ Ansi.RESET);
                    }
                }
            }

            //  🌩🌧🌤🌻🍒🌹🍓🍔✒✕✖✗✘✓✔🗹♏

            log("\n══════════════════════════════════════════════════════════════════════════════════════════════════");
            log("Projects:");
            foreach(p; mainProject.allProjects()) {
                log("  %s", p);
            }
            log("══════════════════════════════════════════════════════════════════════════════════════════════════");

        }catch(SyntaxError e) {
            log("%s", e.formatted());
        }catch(Exception e) {
            log("Exception: %s", e);
        }
    }
private:
    BuildProperties props;
    Project mainProject;

    void parseAllProjects(int pass) {
        log("Parse (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        foreach(p; mainProject.allProjects()) {
            logParse("  Parse %s", p);

            auto parser = new ParseProject(p);
            parser.parse();
        }
    }
    bool resolveAllProjects(int pass) {
        log("Resolve (pass %s) ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈", pass+1);
        bool allResolved = true;
        foreach(p; mainProject.allProjects()) {
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
        foreach(p; mainProject.allProjects()) {
            logCheck("  Check %s", p.name);

            auto checker = new CheckProject(p);
            allPassCheck |= checker.check();
        }
        return allPassCheck;
    }
    void emitAllProjects() {
        log("Emit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈");

        foreach(p; mainProject.allProjects()) {
            log("  Emit %s", p.name);

            auto emit = new EmitProject(p);
            emit.emit();
        }

    }
    bool link() {
        log("🕯♑ Link all projects: %s", mainProject.allProjects().map!(it=>it.name));

        // Build all Projects into object files
        foreach(p; mainProject.allProjects()) {
            auto builder = new BuildProject(p);
            if(!builder.build()) {
                return false;
            }
        }

        // Link all object files together
        return Linker.link(mainProject);
    }
}
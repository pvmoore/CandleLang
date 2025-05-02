module candle.emitandbuild.clang.CLangBuilder;

import candle.all;
import std.process : Config, execute, spawnProcess, wait;
import std.string : strip;

/**
 *  Build all Project.c files into object files
 *
 *  https://learn.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=msvc-170
 */
final class CLangBuilder {
public:
    this(Candle candle) {
        this.candle = candle;
    }
    bool buildAllModules() {
        
        foreach(m; candle.allModules()) {
            if(!build(m)) return false;
        }

        return true;
    }
private:
    Candle candle;

    bool build(Module module_) {
        auto args = [
            "cl",
            "/nologo",
            "/std:c17",

            "/Fabuild\\%s".format(module_.name),    // create asm file
            "/Fobuild\\%s".format(module_.name),    // create obj file
            "/TC",                                  // all source files are C
            "/utf-8",

            "/WX",          // warnings as errors
            "/W3",          // warning level W0 .. W4

            "/wd4101",      // warning C4101: unreferenced local variable

            "/arch:AVX2",
            "/c",           // compile only
        ];

        // Add dependency module directories
        //args ~= "/I<includedir>";

        if(candle.isDebug) {
            // debug build
            args ~= [
                "/Od",                                  // disables optimization
                "/Zi",                                  // produces a PDB file that contains all the symbolic debugging 
                "/Fdbuild\\%s".format(module_.name),    // pdb file location
                "/Zc:inline-",                          // don't remove unreferenced functions
                "/GS",                                  // check buffer security
                "/sdl",                                 // enables a superset of the baseline security checks
            ];  
        } else {
            // optimised build
            args ~= [
                "/O2",          // maximum speed
                //"/GL",          // whole program optimisation
                "/Ot",          // favour code speed
                "/Zc:inline",   // remove unreferenced functions
                "/Gw", 	        // whole-program global data optimization
                "/Oy",          // suppresses the creation of frame pointers on the call stack 
                //"/Zo",        // debugging for optimised code
            ];
        }

        //args ~= "/fp:fast",     // fast floating point
        //args ~= "/fp:precise",  // precise floating point

        args ~= "%s.c".format(module_.name);

        //log("Build command: %s", args);

        string[string] env;
        auto result = execute(
            args, 
            env, 
            Config.none, 
            size_t.max, 
            candle.targetDirectory.value);

        if(result.status!=0) {
            log("🕯 Build %s" ~ Ansi.RED_BOLD ~ "✘" ~ Ansi.RESET ~ "\n\n%s", 
                module_.name, result.output.strip);
            return false;
        } else {
            logBuild("🕯 Build %s (%s)".format(module_.name, candle.isDebug ? "DEBUG" : "RELEASE") ~ Ansi.GREEN_BOLD ~ "✔" ~ Ansi.RESET);
        }

        return true;
    }
}

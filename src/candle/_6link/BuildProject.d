module candle._6link.BuildProject;

import candle.all;
import std.process : Config, execute, spawnProcess, wait;
import std.string : strip;

/**
 *  Build the Project.c file into an object file
 *
 *  https://learn.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=msvc-170
 */
final class BuildProject {
public:
    this(Project project) {
        this.project = project;
    }
    bool build() {
        auto args = [
            "cl",
            "/nologo",
            "/std:c17",

            "/Fabuild\\%s".format(project.name),    // create asm file
            "/Fobuild\\%s".format(project.name),    // create obj file
            "/TC",                                  // all source files are C
            "/utf-8",

            "/WX",          // warnings as errors
            "/W3",          // warning level W0 .. W4

            "/wd4101",      // warning C4101: unreferenced local variable

            "/arch:AVX2",
            "/c",           // compile only
        ];

        // Add dependency project directories
        //args ~= "/I<includedir>";

        if(true) {
            // debug build
            args ~= [
                "/Od",                                  // disables optimization
                "/Zi",                                  // produces a PDB file that contains all the symbolic debugging 
                "/Fdbuild\\%s".format(project.name),    // pdb file location
                "/Zc:inline-",                          // don't remove unreferenced functions
                "/GS",                                  // check buffer security
            ];
        } else {
            // optimised build
            args ~= [
                "/O2",          // maximum speed
                "/GL",          // whole program optimisation
                "/Ot",          // favour code speed
                "/Zc:inline",   // remove unreferenced functions
                "/Gw", 	        // whole-program global data optimization
                "/Oy",          // suppresses the creation of frame pointers on the call stack 
                //"/Zo",        // debugging for optimised code
            ];
        }

        //args ~= "/fp:fast",     // fast floating point
        //args ~= "/fp:precise",  // precise floating point

        args ~= "%s.c".format(project.name);

        log("Build command: %s", args);


        string[string] env;
        auto result = execute(args, env, Config.none, size_t.max, project.targetDirectory().value);

        if(result.status!=0) {
            log("🕯 Build %s " ~ Ansi.RED_BOLD ~ "✘" ~ Ansi.RESET ~ "\n\n%s", project.name, result.output.strip);
            return false;
        } else {
            log("🕯 Build %s".format(project.name) ~ Ansi.GREEN_BOLD ~ "✔" ~ Ansi.RESET);
        }

        return true;
    }
private:
    Project project;
}
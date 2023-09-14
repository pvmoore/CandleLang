module candle._6link.Linker;

import candle.all;
import std.process : Config, execute, spawnProcess, wait;
import std.string : strip;

final class Linker {
public:
    static bool link(Project project) {

        string subsystem    = "console";
        auto buildDirectory = project.targetDirectory().add(Directory("build"));
        string targetExe    = buildDirectory.value.replace('/', '\\') ~ project.name ~ ".exe";
        string[] objects    = project.allProjects()
                                  .map!(it=>buildDirectory.value ~ it.name ~ ".obj")
                                  .map!(it=>it.replace('/', '\\'))
                                  .array;

        auto args = [
            "link",
            "/NOLOGO",
            //"/VERBOSE",
            "/MACHINE:X64",
            "/WX",              /// Treat linker warnings as errors
            "/SUBSYSTEM:" ~ subsystem
        ];

        if(true) {
            // debug build
            args ~= [
                 "/DEBUG:NONE",     /// Don't generate a PDB for now
                "/OPT:NOREF"        /// Don't remove unreferenced functions and data
            ];
        } else {
            // optimised build
            args ~= [
                "/RELEASE",
                "/OPT:REF",         /// Remove unreferenced functions and data
                //"/LTCG",          /// Link time code gen
            ];
        }

        args ~= objects;

        args ~= [
            "/OUT:" ~ targetExe
        ];

        //args ~= getCRuntime();

        //log("Link command: %s", args);


        //args ~= config.getExternalLibs();

        string[string] env;
        auto result = execute(args, env, Config.none, size_t.max, ".");

        if(result.status!=0) {
            log("🕯 Link %s " ~ Ansi.RED_BOLD ~ "✘" ~ Ansi.RESET ~ "\n\n%s", project.name, result.output.strip);
            return false;
        } else {
            log("🕯 Link %s".format(project.name) ~ Ansi.GREEN_BOLD ~ "✔" ~ Ansi.RESET);
        }

        return true;
    }
private:
    static string[] getCRuntime() {
        if(true) {
            // Dynamic runtime
            return [
                "msvcrtd.lib",
                "ucrtd.lib",
                "vcruntimed.lib"
            ];
            //string[] staticRuntime = [
            //    "libcmt.lib",
            //    "libucrt.lib",
            //    "libvcruntime.lib"
            //];
        } else {
            return [
                "msvcrt.lib",
                "ucrt.lib",
                "vcruntime.lib"
            ];
            //string[] staticRuntime = [
            //    "libcmt.lib",
            //    "libucrt.lib",
            //    "libvcruntime.lib"
            //];
        }
    }
}
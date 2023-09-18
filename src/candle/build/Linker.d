module candle.build.Linker;

import candle.all;
import std.process : Config, execute, spawnProcess, wait;
import std.string : strip;

final class Linker {
public:
    static bool link(Candle candle) {
        string targetName   = candle.mainProject.name;
        string subsystem    = candle.subsystem;
        auto buildDirectory = candle.targetDirectory.add(Directory("build"));
        string targetExe    = targetName ~ ".exe";
        string[] objects    = candle.allProjects()
                                  .map!(it=>it.name ~ ".obj")
                                  .map!(it=>it.replace('/', '\\'))
                                  .array;

        auto args = [
            "link",
            "/NOLOGO",
            //"/VERBOSE",
            "/MACHINE:X64",
            "/WX",              // Treat linker warnings as errors
            "/SUBSYSTEM:" ~ subsystem
        ];

        if(candle.isDebug) {
            // debug build
            args ~= [
                "/DEBUG:NONE",     // Don't generate a PDB for now
                "/OPT:NOREF"        // Don't remove unreferenced functions and data
            ];
        } else {
            // optimised build
            args ~= [
                "/RELEASE",
                "/OPT:REF",         /// Remove unreferenced functions and data
                "/LTCG",          /// Link time code gen
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
        auto result = execute(
            args, 
            env, 
            Config.none, 
            size_t.max, 
            buildDirectory.value);

        if(result.status!=0) {
            log("🕯 Link %s " ~ Ansi.RED_BOLD ~ "✘" ~ Ansi.RESET ~ "\n\n%s", targetName, result.output.strip);
            return false;
        } else {
            logBuild("🕯 Link %s (%s)".format(targetName, candle.isDebug ? "DEBUG" : "RELEASE") ~ Ansi.GREEN_BOLD ~ "✔" ~ Ansi.RESET);
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
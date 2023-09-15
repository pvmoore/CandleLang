module candle.Compilation;

import candle.all;

final class Compilation {
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
    
    Project[] allProjects() { return projects.values(); }

    this() {
        // Default values
        isDebug = true;
        subsystem = "console";
        mainDirectory = Directory("_./");
        targetDirectory = Directory("target/");
    }
    void load() {
        ensureDirectoryExists(targetDirectory);
        ensureDirectoryExists(targetDirectory.add(Directory("build")));

        if(dumpAst) {
            ensureDirectoryExists(targetDirectory.add(Directory("ast")));
        }
    }
private:
    void ensureDirectoryExists(Directory dir) {
        if(!dir.exists()) {
            dir.create();
        } else {
            // Clean it?
        }
    }
}
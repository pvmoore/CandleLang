module candle.BuildProperties;

import candle.all;

final class BuildProperties {
public:
    bool isDebug;
    string subsystem;
    Directory mainDirectory;
    Directory targetDirectory;
    bool dumpAst;

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
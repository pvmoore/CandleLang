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
        // Ensure the target directory exists
        if(!targetDirectory.exists()) {
            targetDirectory.create();
        } else {
            // Clean it?
        }
        if(dumpAst) {
            auto astDirectory = targetDirectory.add(Directory("ast"));
            if(!astDirectory.exists()) {
                astDirectory.create();
            }
        }
    }
private:
}
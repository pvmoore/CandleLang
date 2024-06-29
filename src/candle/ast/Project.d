module candle.ast.Project;

import candle.all;

/**
 *  Project
 *      { Unit }
 */
final class Project : Node {
public:
    Candle candle;
    string name;
    string includeName;         // usually name ~ ".h" but is configurable to avoid collisions
    Directory directory;
    bool[string] scannedTypes;  // true if isPublic
    
    override ENode enode() { return ENode.PROJECT; }
    override Type type() { return TYPE_VOID; }
    override bool isResolved() { return true; }

    this(Candle candle, Directory directory) {
        this.candle = candle;
        this.directory = directory;
        loadProjectJson5();
        addUnits();
        candle.projects[name] = this;
        dumpProperties();
    }

    Unit[] getUnits() { return children.filter!(it=>it.isA!Unit).map!(it=>it.as!Unit).array(); }
    Alias[] getAliases(Visibility v) { return getUnits().map!(it=>it.getAliases(v)).join; }
    Struct[] getStructs(Visibility v) { return getUnits().map!(it=>it.getStructs(v)).join; }
    Union[] getUnions(Visibility v) { return getUnits().map!(it=>it.getUnions(v)).join; }
    Enum[] getEnums(Visibility v) { return getUnits().map!(it=>it.getEnums(v)).join; }

    Project[] getExternalProjects() { return externalProjects.values(); }

    Project[] getUnqualifiedExternalProjects() {
        return getExternalProjects().filter!(it=>dependencies[it.name].unqualified).array;
    }

    Project getProject(string name) {
        if(auto projPtr = name in externalProjects) {
            return *projPtr;
        }
        throw new Exception("Project dependency not found '%s'".format(name));
    }
    bool isDeclaredType(string value) {
        return (value in scannedTypes) !is null;
    }

    bool isProjectName(string name) {
        return (name in externalProjects) !is null;
    }

    void dumpProperties() {
        string inc;
        foreach(e; dependencies.byKeyValue()) {
            inc ~= "    %s -> %s\n".format(e.key, e.value);
        }

        string units;
        foreach(ch; children) {
            if(auto u = ch.as!Unit) {
                units ~= "    %s\n".format(u.filename);
            }
        }

        log("Project{\n" ~
            "  name .......... %s\n".format(name) ~
            "  include-name .. %s\n".format(includeName) ~
            "  directory ..... %s\n".format(directory) ~
            "  dependencies:\n" ~
            inc ~
            "  units:\n" ~
            units ~
            "}");
    }
    void getUnresolved(ref Node[] nodes) {
        this.recurse((n) {
            if(!n.isResolved()) {
                nodes ~= n;
            }
        });
    }

    override string toString() {
        return "Project '%s', '%s'".format(name, directory);
    }
private:
    struct Dependency {
        string name;
        Directory directory;
        bool unqualified;
    }
    Dependency[string] dependencies;     // declared possible external Projects 
    Project[string] externalProjects;   // accessed external Projects

    /** 
     * {
     *   name: "test",
     *   description: "test",
     *   dependencies: {
     *     std: { 
     *       directory: "_extern/std", 
     *       include-name: "std.h",
     *       unqualified-access: true 
     *     }
     *   }
     * } 
     */
    bool loadProjectJson5() {
        auto projectFile = Filepath(directory, Filename("candle.json"));
        if(!projectFile.exists()) return false;

        auto root = JSON5.fromFile(projectFile.value);
        if(root.hasKey("name")) {
            this.name = root["name"].toString();
        }
        this.includeName = root.hasKey("include-name") ? root["include-name"].toString() : name ~ ".h";

        if(auto dependencies = root["dependencies"]) {
            foreach(k,v; dependencies.byKeyValue()) {
                auto key = k.toLower();
                auto value = v["directory"].toString();
                auto uq = v["unqualified-access"];
                auto dep = Dependency(
                    key, 
                    Directory(value),
                    uq && uq.as!J5Boolean);

                this.dependencies[key] = dep;
                loadDependencyProject(dep);    
            }
        }

        return true;
    }
    void loadDependencyProject(Dependency dep) {
        // Reuse Project if we already have it
        Project project;
        auto pptr = dep.name in candle.projects;
        if(pptr) {
            project = *pptr;
        } else {
            // Create and load this Project
            project = makeNode!Project(candle, dep.directory);
        }
        externalProjects[dep.name] = project;
    }
    string[] unitFilenames() {
        import std.file;
        auto i = directory.value.length;
        return dirEntries(directory.value, "*.can", SpanMode.depth, false)
            .map!(it=>it.name())
            .map!(it=>it[i..$])
            .array();
    }
    void addUnits() {
        // Collect all the Units and add to the Project
        string[] filenames = unitFilenames();
        //log("Project files = %s", filenames);

        foreach(filename; filenames) {
            Unit unit = makeNode!Unit(this, filename);
            this.add(unit);
        }
        //log("[%s] Declared types: %s", name, scannedTypes);
    }
}

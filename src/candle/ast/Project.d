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
    Directory directory;
    bool[string] scannedTypes; // true if isPublic
    
    override ENode enode() { return ENode.PROJECT; }
    override Type type() { return TYPE_VOID; }
    override bool isResolved() { return true; }

    this(Candle candle, Directory directory) {
        this.candle = candle;
        this.directory = directory;
        loadProjectJson5();
        addUnits();
        candle.projects[name] = this;
        //dumpProperties();
    }

    Unit[] getUnits() { return children.filter!(it=>it.isA!Unit).map!(it=>it.as!Unit).array(); }
    Alias[] getAliases(Visibility v) { return getUnits().map!(it=>it.getAliases(v)).join; }
    Struct[] getStructs(Visibility v) { return getUnits().map!(it=>it.getStructs(v)).join; }
    Union[] getUnions(Visibility v) { return getUnits().map!(it=>it.getUnions(v)).join; }
    Enum[] getEnums(Visibility v) { return getUnits().map!(it=>it.getEnums(v)).join; }

    Project[] getExternalProjects() { return externalProjects.values(); }

    Project getDependency(string name) {
        // Is it a Project we know about?
        auto dptr = name in dependencies;
        if(!dptr) {
            throw new Exception("Project dependency not found '%s'".format(name));
        }
        // Reuse Project if we already have it
        Project project;
        auto pptr = name in candle.projects;
        if(pptr) {
            project = *pptr;
        } else {
            // Create and load this Project
            project = makeNode!Project(candle, *dptr);
        }
        externalProjects[name] = project;
        return project;
    }
    bool isDeclaredType(string value) {
        return (value in scannedTypes) !is null;
    }

    bool isProjectName(string name) {
        return (name in dependencies) !is null;
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
            "  name ........ %s\n".format(name) ~
            "  directory ... %s\n".format(directory) ~
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
    Directory[string] dependencies;     // declared possible external Projects
    Project[string] externalProjects;   // accessed external Projects

    /** 
     * {
     *   name: "test",
     *   dependencies: {
     *     std: "_extern/std"
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

        if(auto dependencies = root["dependencies"]) {
            foreach(k,v; dependencies.byKeyValue()) {
                auto key = k.toLower();
                auto value = v.toString();
                this.dependencies[key] = Directory(value);
            }
        }

        return true;
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
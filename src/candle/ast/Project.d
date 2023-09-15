module candle.ast.Project;

import candle.all;

/**
 *  Project
 *      { Unit }
 */
final class Project : Node {
public:
    string name;
    Compilation comp;
    Directory directory;
    Directory[string] dependencies; // external Projects

    Directory targetDirectory() { return comp.targetDirectory; }
    bool dumpAst() { return comp.dumpAst; }

    override ENode enode() { return ENode.PROJECT; }
    override Type type() { return TYPE_VOID; }
    override bool isResolved() { return true; }

    this(Compilation comp, Directory directory) {
        this.comp = comp;
        this.directory = directory;
        loadProjectJson5();
        addUnits();
        comp.projects[name] = this;
    }

    Project getDependency(string name) {
        // Is it a Project we know about?
        auto dptr = name in dependencies;
        if(!dptr) {
            throw new Exception("Project dependency not found '%s'".format(name));
        }
        // Reuse Project if we already have it
        auto pptr = name in comp.projects;
        if(pptr) return *pptr;

        // Create and load this Project
        return makeNode!Project(comp, *dptr);
    }

    Project[] getExternalProjects() {
        return comp.allProjects().filter!(it=>it !is this).array();
    }

    bool isProjectName(string name) {
        return (name in dependencies) !is null;
    }

    Unit[] getUnits() {
        return children.filter!(it=>it.isA!Unit)
                       .map!(it=>it.as!Unit)
                       .array();
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
    override string toString() {
        return "Project '%s', '%s'".format(name, directory);
    }
private:
    /** 
     * {
     *   name: "test",
     *   dependencies: {
     *     std: "_extern/std"
     *   }
     * } 
     */
    bool loadProjectJson5() {
        auto projectFile = Filepath(directory, Filename("project.json5"));
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
        log("Project files = %s", filenames);

        foreach(filename; filenames) {
            Unit unit = makeNode!Unit(this, filename);
            this.add(unit);
        }
    }
}
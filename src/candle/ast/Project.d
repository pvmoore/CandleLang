module candle.ast.Project;

import candle.all;

/**
 *  Project
 *      { Unit }
 */
final class Project : Node {
public:
    static Project[] allProjects() { return projects.values(); }
    //──────────────────────────────────────────────────────────────────────────────────────────────
    string name;
    BuildProperties props;
    Directory directory;
    Directory[string] dependencies; // external Projects

    Directory targetDirectory() { return props.targetDirectory; }
    bool dumpAst() { return props.dumpAst; }

    override NKind nkind() { return NKind.PROJECT; }
    override Type type() { return TYPE_VOID; }
    override bool isResolved() { return true; }

    this(BuildProperties props, Directory directory) {
        this.props = props;
        this.directory = directory;
        loadProjectYml();
        addUnits();
        projects[name] = this;
    }

    Project getProject(string name) {
        auto ptr = name in projects;
        if(ptr) return *ptr;

        // Is it a Project we know about?
        auto dptr = name in dependencies;
        if(!dptr) {
            throw new Exception("Project dependency not found '%s'".format(name));
        }

        // Create and load this Project
        return makeNode!Project(props, *dptr);
    }

    Project[] getExternalProjects() {
        return allProjects().filter!(it=>it !is this).array();
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
    static Project[string] projects;

    /**
     * name: test
     * dependencies:
     *   std: "extern/std"
     */
    void loadProjectYml() {
        import dy = dyaml;

        auto projectFile = Filepath(directory, Filename("project.yml"));
        dy.Node root = dy.Loader.fromFile(projectFile.value).load();

        this.name = root["name"].as!string;

        if(root.containsKey("dependencies")) {
            foreach(dy.Node it; root["dependencies"].mappingKeys()) {
                auto key = it.as!string.toLower();
                auto value = root["dependencies"][key].as!string;

                this.dependencies[key] = Directory(value);
            }
        }
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
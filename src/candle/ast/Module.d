module candle.ast.Module;

import candle.all;

/**
 *  Module
 *      { Unit }
 */
final class Module : Node {
public:
    Candle candle;
    string name;
    string headerName;         // usually name ~ ".h" but is configurable to avoid collisions
    Directory directory;
    bool[string] scannedTypes;  // Map of struct|union|enum and alias nodes in this Module. value is true if isPublic
    
    override ENode enode() { return ENode.MODULE; }
    override Type type() { return TYPE_VOID; }
    override bool isResolved() { return true; }

    this(Candle candle, Directory directory) {
        this.candle = candle;
        this.directory = directory;
        loadModuleJson5();
        addUnits();
        candle.modules[name] = this;
        dumpProperties();
    }

    Unit[] getUnits() { return children.filter!(it=>it.isA!Unit).map!(it=>it.as!Unit).array(); }
    Alias[] getAliases(Visibility v) { return getUnits().map!(it=>it.getAliases(v)).join; }
    Struct[] getStructs(Visibility v) { return getUnits().map!(it=>it.getStructs(v)).join; }
    Union[] getUnions(Visibility v) { return getUnits().map!(it=>it.getUnions(v)).join; }
    Enum[] getEnums(Visibility v) { return getUnits().map!(it=>it.getEnums(v)).join; }

    Module[] getExternalModules() { return externalModules.values(); }

    Module[] getUnqualifiedExternalModules() {
        return getExternalModules().filter!(it=>dependencies[it.name].unqualified).array;
    }

    Module getModule(string name) {
        if(auto projPtr = name in externalModules) {
            return *projPtr;
        }
        throw new Exception("Module dependency not found '%s'".format(name));
    }
    bool isDeclaredType(string value) {
        return (value in scannedTypes) !is null;
    }
    /** Return true if 'id' is a user defined struct/union/enum or alias */
    bool isUserDefinedType(string id) { 
        if(this.isDeclaredType(id)) return true;

        // Is it a type in one of the unqualified external Modules?
        foreach(m; this.getUnqualifiedExternalModules()) {
            if(m.isDeclaredType(id)) return true;
        }
        return false;
    }

    bool isModuleName(string name) {
        return (name in externalModules) !is null;
    }

    void getUnresolved(ref Node[] nodes) {
        this.recurse((n) {
            if(!n.isResolved()) {
                nodes ~= n;
            }
        });
    }

    override string toString() {
        return "Module '%s', '%s'".format(name, directory);
    }
private:
    struct Dependency {
        string name;
        Directory directory;
        bool unqualified;
    }
    Dependency[string] dependencies;    // declared possible external Modules 
    Module[string] externalModules;     // accessed external Modules

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
    bool loadModuleJson5() {
        auto moduleFile = Filepath(directory, Filename("candle.json5"));
        if(!moduleFile.exists()) return false;

        auto root = JSON5.fromFile(moduleFile.value);
        if(root.hasKey("name")) {
            this.name = root["name"].toString();
        }
        this.headerName = root.hasKey("header-name") ? root["header-name"].toString() : name ~ ".h";

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
                loadDependencyModule(dep);    
            }
        }

        return true;
    }
    void loadDependencyModule(Dependency dep) {
        // Reuse Module if we already have it
        Module module_;
        auto pptr = dep.name in candle.modules;
        if(pptr) {
            module_ = *pptr;
        } else {
            // Create and load this Module
            module_ = makeNode!Module(candle, dep.directory);
        }
        externalModules[dep.name] = module_;
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
        // Collect all the Units and add to the Module
        string[] filenames = unitFilenames();
        //log("Module files = %s", filenames);

        foreach(filename; filenames) {
            Unit unit = makeNode!Unit(this, filename);
            add(unit);
            unit.process();
        }
        //log("[%s] Declared types: %s", name, scannedTypes);
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

        log("Module{\n" ~
            "  name .......... %s\n".format(name) ~
            "  header-name ... %s\n".format(headerName) ~
            "  directory ..... %s\n".format(directory) ~
            "  dependencies:\n" ~
            inc ~
            "  units (%s):\n".format(numChildren) ~
            units ~
            "}");
    }
}

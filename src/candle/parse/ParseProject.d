module candle.parse.ParseProject;

import candle.all;

final class ParseProject {
public:
    this(Project project) {
        this.project = project;
    }
    void parse() {
        logParse("  Parsing %s", project);
        foreach(u; project.getUnits()) {
            parseUnit(u);
        }
    }
private:
    Project project;

    void parseUnit(Unit unit) {
        if(unit.isParsed) return;

        logParse("  Parsing %s", unit);
        Tokens tokens = new Tokens(unit);
        //log("%s", tokens.toString());

        int lastPos = tokens.pos;

        while(!tokens.eof()) {

            parseStmt(unit, tokens);


            // Check that we have not stalled
            if(tokens.pos == lastPos) throw new Exception("No progress made");
            lastPos = tokens.pos;
        }
        unit.isParsed = true;
        writeAst(unit);
    }
}
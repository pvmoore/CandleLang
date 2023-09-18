module candle._4check.CheckProject;

import candle.all;

final class CheckProject {
public:
    this(Project project) {
        this.candle = project.candle;
        this.project = project;
    }
    /** 
     * Check all Stmt Nodes from the bottom up
     */
    void check() {
        foreach(u; project.getUnits()) {
            checkChildren(u);
        }
    }
private:
    Candle candle;
    Project project;

    void checkChildren(Node n) {
        foreach(ch; n.children) {
            checkChildren(ch);
        }
        if(Stmt stmt = n.as!Stmt) {
            stmt.check();
        }
    }
}
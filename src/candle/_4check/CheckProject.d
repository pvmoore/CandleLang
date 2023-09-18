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
            recurseChildren(u);
        }
    }
private:
    Candle candle;
    Project project;

    void recurseChildren(Node n) {
        foreach(ch; n.children) {
            recurseChildren(ch);
        }
        n.check();
    }
}
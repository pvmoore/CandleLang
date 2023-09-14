module candle._4check.CheckProject;

import candle.all;

final class CheckProject {
public:
    this(Project project) {
        this.project = project;
    }
    bool check() {


        return true;
    }
private:
    Project project;

    void check(Node n) {
        logCheck("check %s", n.nkind());
        switch(n.nkind()) with(ENode) {
            default: throw new Exception("check: Handle node %s".format(n.nkind()));
        }
    }
}
module candle.ast.expr.ProjectId;

import candle.all;

/**
 *  ProjectId
 */
final class ProjectId : Expr {
public:
    string name;
    Project project;

    override ENode enode() { return ENode.PROJECT_ID; }
    override Type type() { return TYPE_VOID; }
    override int precedence() { return 0; }
    override bool isResolved() { return project !is null; }
    override string toString() {
        return "ProjectId -> %s".format(project);
    }
    override void parse(Tokens t) {
        this.name = t.value(); t.next();
        this.project = getProject().getProject(name);
    }
private:
}

module candle.ast.node_builder;

import candle.all;

T makeNode(T : Node)() {
    T node = new T();
    node.id = IDS++;
    return node;
}
T makeNode(T : Project)(BuildProperties props, Directory directory) {
    T node = new Project(props, directory);
    node.id = IDS++;
    return node;
}
T makeNode(T : Unit)(Project project, string name) {
    T node = new Unit(project, name);
    node.id = IDS++;
    return node;
}
T makeNode(T : Primitive)(EType k) {
    T node = new Primitive(k);
    node.id = IDS++;
    return node;
}
T makeNode(T : NodeRef)(Node n) {
    T node = new NodeRef(n);
    node.id = IDS++;
    return node;
}
T makeNode(T : TypeRef)(string name, Type n, Project project) {
    T node = new TypeRef(name, n, project);
    node.id = IDS++;
    return node;
}
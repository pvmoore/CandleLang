module candle.ast.node_builder;

import candle.all;

T makeNode(T : Node)(FileCoord coord) {
    T node = new T();
    node.id = IDS++;
    node.coord = coord;
    return node;
}
T makeNode(T : Project)(Candle candle, Directory directory) {
    T node = new Project(candle, directory);
    node.id = IDS++;
    return node;
}
T makeNode(T : Unit)(Project project, string name) {
    T node = new Unit(project, name);
    node.id = IDS++;
    return node;
}
T makeNode(T : Primitive)(FileCoord coord, EType k) {
    T node = new Primitive(k);
    node.id = IDS++;
    node.coord = coord;
    return node;
}
T makeNode(T : Number)(FileCoord coord, bool value) {
    return makeNode!Number(coord, value ? "true" : "false");
}
T makeNode(T : Number)(FileCoord coord, string value) {
    T node = new Number();
    node.id = IDS++;
    node.coord = coord;
    node.set(value);
    return node;
}
T makeNode(T : NodeRef)(Node n) {
    T node = new NodeRef(n);
    node.id = IDS++;
    node.coord = n.coord;
    return node;
}
T makeNode(T : TypeRef)(FileCoord coord, string name, Type n, Project project) {
    T node = new TypeRef(name, n, project);
    node.id = IDS++;
    node.coord = coord;
    return node;
}
module candle.ast.node_builder;

import candle.all;

T makeNode(T : Node)(FileCoord coord) {
    T node = new T();
    node.id = IDS++;
    node.coord = coord;
    return node;
}
T makeNode(T : Module)(Candle candle, Directory directory) {
    T node = new Module(candle, directory);
    node.id = IDS++;
    return node;
}
T makeNode(T : Unit)(Module module_, string name) {
    T node = new Unit(module_, name);
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
T makeNode(T : TypeRef)(FileCoord coord, string name, Type n, Module module_) {
    T node = new TypeRef(name, n, module_);
    node.id = IDS++;
    node.coord = coord;
    return node;
}

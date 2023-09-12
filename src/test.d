module test;

import std.stdio : writefln;

import candle;
import common;

void main(string[] args) {

    auto props = new BuildProperties();
    props.isDebug = true;
    props.subsystem = "console";
    props.mainDirectory = Directory("_test/");
    props.targetDirectory = Directory("_target/");
    props.dumpAst = true;

    props.load();

    auto candle = new Candle(props);

    candle.compile();


}
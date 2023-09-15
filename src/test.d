module test;

import std.stdio : writefln;

import candle;
import common;

void main(string[] args) {

    auto comp = new Compilation();
    comp.isDebug = true;
    comp.subsystem = "console";
    comp.mainDirectory = Directory("_test/");
    comp.targetDirectory = Directory("_target/");
    comp.dumpAst = true;

    comp.load();

    auto candle = new Candle(comp);

    candle.compile();


}
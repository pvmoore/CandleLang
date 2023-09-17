module test;

import std.stdio : writefln;

import candle;
import common;

void main(string[] args) {

    auto candle = new Candle();
    candle.isDebug = true;
    candle.subsystem = "console";
    candle.mainDirectory = Directory("_test/");
    candle.targetDirectory = Directory("_target/");
    candle.dumpAst = true;

    if(!candle.compile()) {
        foreach(e; candle.errors) {
            writefln("%s", e.formatted());
        }
    }
}
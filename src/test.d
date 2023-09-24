module test;

import std.stdio : writefln;

import candle;
import common;

void main(string[] args) {

    auto candle = new Candle();
    candle.isDebug = true;
    candle.subsystem = "console";
    candle.mainDirectory = Directory("_projects/test/");
    candle.targetDirectory = Directory("_target/");
    candle.nullChecks = true;

    candle.dumpAst = true;
    candle.emitLineNumber = true;

    if(!candle.compile()) {
        foreach(e; candle.getErrors()) {
            writefln("%s", e.verbose());
        }
    }
}
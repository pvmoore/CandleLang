module test;

import std.stdio : writefln;

import candle;
import common;

void main(string[] args) {

    auto candle = new Candle();
    candle.isDebug = true;
    candle.subsystem = "console";
    candle.mainDirectory = Directory("_modules/test/");
    candle.targetDirectory = Directory("_target/");
    candle.rtChecksNullRef = true;
    candle.rtChecksOob = true;


    candle.dumpAst = true;
    candle.emitLineNumber = true;

    if(!candle.compile()) {
        foreach(e; candle.getErrors()) {
            writefln("%s", e.verbose());
        }
    }
}

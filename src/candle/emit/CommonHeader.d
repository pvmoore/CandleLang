module candle.emit.CommonHeader;

import candle.all;

final class CommonHeader {
public:
    this(Candle candle) {
        this.candle = candle;
    }
    void emit() {
        string name = "candle__common.h";
        auto path = Filepath(candle.targetDirectory, Filename(name));
        File file = File(path.value, "wb");
        file.write(HEADER_CONTENT);
        file.close();
    }
private:
    Candle candle;
    string HEADER_CONTENT = "
#ifndef CANDLE_COMMON_TYPEDEFS_H
#define CANDLE_COMMON_TYPEDEFS_H

typedef unsigned char bool;
typedef unsigned char ubyte;
typedef signed char byte;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long long ulong;

#define true 1
#define false 0
#define null 0

#include \"stdlib.h\"
#include \"stdio.h\"

static void candle__assert(int value, const char* unitName, uint line) {
    if(!value) {
        putchar(13); putchar(10);
        printf(\"!! Assertion failed: [%s] Line %u\", unitName, line);
        putchar(13); putchar(10);
        exit(-1);
    }
}

#endif
";
}
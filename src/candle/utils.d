module candle.utils;

import candle.all;

void log(A...)(string fmt, lazy A args) {
    auto s = format(fmt, args);
    logFile.write(s);
    logFile.write("\n");
    logFile.flush();
    writefln(s);
}
void logParse(A...)(string fmt, lazy A args) {
    static if(LOG_PARSE) {
        log(fmt, args);
    }
}
void logResolve(A...)(string fmt, lazy A args) {
    static if(LOG_RESOLVE) {
        log(fmt, args);
    }
}
void logCheck(A...)(string fmt, lazy A args) {
    static if(LOG_CHECK) {
        log(fmt, args);
    }
}
void logEmit(A...)(string fmt, lazy A args) {
    static if(LOG_EMIT) {
        log(fmt, args);
    }
}
void logBuild(A...)(string fmt, lazy A args) {
    static if(LOG_BUILD) {
        log(fmt, args);
    }
}

bool isDigit(char c) {
    return c >= '0' && c <= '9';
}

T minOf(T)(T a, T b) {
    return a < b ? a : b;
}

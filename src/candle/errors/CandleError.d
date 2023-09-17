module candle.errors.CandleError;

import candle.all;

interface CandleError {
    string formatted();
}

string formattedError(Unit unit, FileCoord coord, string msg) {
    uint line = coord.line;
    uint column = coord.column;
    uint length = coord.length;
    
    string s = Ansi.RED_BOLD ~ "ERROR:" ~ Ansi.RESET ~
        " %s%s.can %s:%s : %s\n".format(unit.getProject().directory, 
        unit.name, line+1, column+1, msg);

    string srcLine = getSrcLine(unit.src, line);
    string coloured;
    if(column+length < srcLine.length) {
        coloured =
            srcLine[0..column] ~
            Ansi.YELLOW_BOLD ~ srcLine[column..column+length] ~ Ansi.RESET ~
            srcLine[column+length..$];
    } else {
        coloured = srcLine;
    }

    s ~= "\n%s\n".format(coloured);

    return s;
}

string getSrcLine(string src, int line) {
    import std.string : splitLines;
    string[] lines = src.splitLines();
    return line < lines.length ? lines[line] : null;
}
module candle.errors.CandleError;

import candle.all;

interface CandleError {
    string formatted();
    bool isDuplicateOf(CandleError);
}

string formattedError(Unit unit, FileCoord coord, string msg) {
    string brief = formatBrief(unit, coord, msg);
    //string verbose = formatVerboseSingleLine(coord, getSourceLine(unit.src, coord.line));
    string verbose = formatVerboseMultiline(unit, coord);
    return brief ~ "\n" ~ verbose;
}
private:

string formatBrief(Unit unit, FileCoord coord, string msg) {
    string location = " %s%s.can %s:%s : ".format(
        unit.getProject().directory, 
        unit.name, coord.line+1, coord.column+1);
    return ansiWrap("ERROR:", Ansi.RED_BOLD) ~
        ansiWrap(location, Ansi.BOLD) ~ 
        msg ~ "\n";
}
string formatVerboseMultiline(Unit unit, FileCoord coord) {
    string[] lines = getSourceLines(unit.src);
    string output;
    int line = coord.line.as!int;
    auto start = coord.column;
    auto end = coord.column+coord.length;
    for(int i = line-1; i>=0 && i<line+2 && i<lines.length; i++) {
        string srcLine = lines[i];
        string lineStr = i==line 
            ? highlightYellow(srcLine, start, end)
            : srcLine;
        output ~= "| %s | %s\n".format(i+1, lineStr);
    }
    return output;
}
string formatVerboseSingleLine(FileCoord coord, string srcLine) {
    string coloured;
    auto start = coord.column;
    auto end = coord.column+coord.length;
    if(coord.column+coord.length <= srcLine.length) {
        coloured = highlightYellow(srcLine, start, end);
    } else {
        coloured = srcLine;
    }
    return "\n%s\n".format(coloured);
}
string highlightYellow(string text, int start, int end) {
    return text[0..start] ~
            ansiWrap(text[start..end], Ansi.YELLOW_BOLD) ~
            text[end..$];
}
string ansiWrap(string text, string ansi) {
    return ansi ~ text ~ Ansi.RESET;
}
string[] getSourceLines(string src) {
    import std.string : splitLines;
    return src.splitLines();
}
string getSourceLine(string src, int line) {
    string[] lines = getSourceLines(src);
    return line < lines.length ? lines[line] : "";
}
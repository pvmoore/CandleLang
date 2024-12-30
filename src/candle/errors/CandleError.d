module candle.errors.CandleError;

import candle.all;

abstract class CandleError {
public:
    final EError eerror() { return _eerror; }
    final FileCoord coord() { return _coord; }

    string brief();
    string verbose();
    bool isDuplicateOf(CandleError);
protected:
    EError _eerror;
    FileCoord _coord;
}

//──────────────────────────────────────────────────────────────────────────────────────────────────

// string formattedError(Unit unit, FileCoord coord, string msg) {
//     string brief = formatBrief(unit, coord, msg);
//     //string verbose = formatVerboseSingleLine(coord, getSourceLine(unit.src, coord.line));
//     string verbose = formatVerboseMultiline(unit, coord);
//     return brief ~ "\n" ~ verbose;
// }

string formatBrief(Unit unit, FileCoord coord, string msg) {
    string location = " %s%s.can %s:%s : ".format(
        unit.getModule().directory, 
        unit.name, coord.line+1, coord.column+1);
    return ansiWrap("ERROR:", Ansi.RED_BOLD) ~
        ansiWrap(location, Ansi.BOLD) ~ 
        msg ~ "\n";
}
string formatVerboseMultiline(Unit unit, FileCoord coord, string msg) {
    string[] lines = getSourceLines(unit.src);
    string output;
    int line = coord.line.as!int;
    auto start = coord.column;
    auto end = coord.column+coord.length;
    for(int i = line-1; i>=0 && i<line+2 && i<lines.length; i++) {
        string srcLine = lines[i];
        string lineStr = i==line 
            ? highlight(srcLine, start, end)
            : srcLine;
        output ~= "| %2s | %s\n".format(i+1, lineStr);
    }
    return formatBrief(unit, coord, msg) ~ "\n" ~ output;
}
string formatVerboseSingleLine(Unit unit, FileCoord coord, string msg) {
    string srcLine = getSourceLine(unit.src, coord.line);
    string coloured;
    auto start = coord.column;
    auto end = coord.column+coord.length;
    if(coord.column+coord.length <= srcLine.length) {
        coloured = highlight(srcLine, start, end);
    } else {
        coloured = srcLine;
    }
    return formatBrief(unit, coord, msg) ~ "\n%s\n".format(coloured);
}
private:

string highlight(string text, int start, int end) {
    return text[0..start] ~
            ansiWrap(text[start..end], Ansi.WHITE ~ Ansi.RED_BOLD_BG) ~
            text[end..$];
}
string[] getSourceLines(string src) {
    import std.string : splitLines;
    return src.splitLines();
}
string getSourceLine(string src, int line) {
    string[] lines = getSourceLines(src);
    return line < lines.length ? lines[line] : "";
}

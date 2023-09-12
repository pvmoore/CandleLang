module candle.errors.errors;

import candle.all;

final class SyntaxError : Exception {
public:
    this(Tokens t, string expected) {
        super("Syntax error");
        this.line = t.get().line;
        this.column = t.get().column;
        this.length = t.get().length;
        this.unit = t.unit;
        this.expected = expected;
    }
    string formatted() {
        string s = Ansi.RED_BOLD ~ "\nERROR:" ~ Ansi.RESET ~
            " %s%s.can %s:%s : %s expected\n".format(unit.getProject().directory, unit.name, line+1, column+1, expected);

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
private:
    int line;
    int column;
    int length;
    Unit unit;
    string expected;
}

void syntaxError(Tokens t, string expected) {
    throw new SyntaxError(t, expected);
}

string getSrcLine(string src, int line) {
    import std.string : splitLines;
    string[] lines = src.splitLines();
    return line < lines.length ? lines[line] : null;
}
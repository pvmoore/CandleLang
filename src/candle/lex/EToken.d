module candle.lex.EToken;

import candle.all;


enum EToken {
    NONE,
    CHAR,
    STRING,
    NUMBER,
    ID,

    ELIPSIS,    // ...
    DOT,        // .

    SLASH,      // /
    SLASH_EQ,   // /=

    LT,         // <
    LT_EQ,      // <=
    LT_LT,      // <<
    LT_LT_EQ,   // <<=

    GT,         // >
    GT_EQ,      // >=
    GT_GT,      // >>
    GT_GT_EQ,   // >>=

    EXCLAIM,    // !
    EXCLAIM_EQ, // !=

    EQ,         // =
    EQ_EQ,      // ==

    STAR,       // *
    STAR_EQ,    // *=

    PLUS,       // +
    PLUS_EQ,    // +=

    MINUS,      // -
    MINUS_EQ,   // -=

    PERCENT,    // %
    PERCENT_EQ, // %=

    AMP,        // &
    AMP_EQ,     // &=

    PIPE,       // |
    PIPE_EQ,    // |=

    HAT,        // ^
    HAT_EQ,     // ^=

    TILDE,      // ~
    QMARK,      // ?
    COMMA,      // ,
    SEMICOLON,  // ;
    COLON,      // :
    COLON_COLON,// ::
    LBRACKET,   // (
    RBRACKET,   // )
    LCURLY,     // {
    RCURLY,     // }
    LSQUARE,    // [
    RSQUARE,    // ]
    AT,         // @

    RT_ARROW,   // ->
}

string stringOf(EToken t) {
    final switch(t) with(EToken) {
        case NONE:
        case CHAR:
        case STRING:
        case NUMBER:
        case ID:
            return "%s".format(t);
        case ELIPSIS: return "...";
        case DOT: return ".";
        case SLASH: return "/";
        case SLASH_EQ: return "/=";
        case LT: return "<";
        case LT_EQ: return "<=";
        case LT_LT: return "<<";
        case LT_LT_EQ: return "<<=";
        case GT: return ">";
        case GT_EQ: return ">=";
        case GT_GT: return ">>";
        case GT_GT_EQ: return ">>=";
        case EXCLAIM: return "!";
        case EXCLAIM_EQ: return "!=";
        case EQ: return "=";
        case EQ_EQ: return "==";
        case STAR: return "*";
        case STAR_EQ: return "*=";
        case PLUS: return "+";
        case PLUS_EQ: return "+=";
        case MINUS: return "-";
        case MINUS_EQ: return "-=";
        case PERCENT: return "%";
        case PERCENT_EQ: return "%=";
        case AMP: return "&";
        case AMP_EQ: return "&=";
        case PIPE: return "|";
        case PIPE_EQ: return "|=";
        case HAT: return "^";
        case HAT_EQ: return "^=";
        case TILDE: return "~";
        case QMARK: return "?";
        case COMMA: return ",";
        case SEMICOLON: return ";";
        case COLON: return ":";
        case COLON_COLON: return "::";
        case LBRACKET: return "(";
        case RBRACKET: return ")";
        case LCURLY: return "{";
        case RCURLY: return "}";
        case LSQUARE: return "[";
        case RSQUARE: return "]";
        case AT: return "@";
        case RT_ARROW: return "->";
    }
    assert(false);
}
int lengthOf(EToken t) {
    final switch(t) with(EToken) {
        case NONE:
        case CHAR:
        case STRING:
        case NUMBER:
        case ID:
            return 0;

        case SLASH:
        case LT:
        case GT:
        case EXCLAIM:
        case EQ:
        case STAR:
        case PLUS:
        case MINUS:
        case PERCENT:
        case AMP:
        case PIPE:
        case HAT:
        case DOT:
        case TILDE:
        case QMARK:
        case COMMA:
        case SEMICOLON:
        case COLON:
        case LBRACKET:
        case RBRACKET:
        case LCURLY:
        case RCURLY:
        case LSQUARE:
        case RSQUARE:
        case AT:
            return 1;
        case SLASH_EQ:
        case LT_LT:
        case LT_EQ:
        case GT_GT:
        case GT_EQ:
        case EXCLAIM_EQ:
        case EQ_EQ:
        case STAR_EQ:
        case PLUS_EQ:
        case MINUS_EQ:
        case PERCENT_EQ:
        case AMP_EQ:
        case PIPE_EQ:
        case HAT_EQ:
        case RT_ARROW:
        case COLON_COLON:
            return 2;
        case LT_LT_EQ:
        case GT_GT_EQ:
        case ELIPSIS:
            return 3;
    }
    assert(false);
}

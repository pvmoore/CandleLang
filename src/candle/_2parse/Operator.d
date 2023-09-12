module candle._2parse.Operator;

import candle.all;

enum Operator {
    ADD,            // +
    SUB,            // -
    MUL,            // *
    DIV,            // /
    MOD,            // %
    SHL,            // <<
    SHR,            // >>
    BIT_AND,        // &
    BIT_XOR,        // ^
    BIT_OR,         // |
    BIT_NOT,        // ~
    NEG,            // -

    BOOL_NOT,       // !
    LT,             // <
    LTE,            // <=
    GT,             // >
    GTE,            // >=
    EQ,             // ==
    NEQ,            // !=
    BOOL_AND,       // &&
    BOOL_OR,        // ||

    ASSIGN,         // =
    ADD_ASSIGN,     // +=
    SUB_ASSIGN,     // -=
    MUL_ASSIGN,     // *=
    DIV_ASSIGN,     // /=
    MOD_ASSIGN,     // %=
    SHL_ASSIGN,     // <<=
    SHR_ASSIGN,     // >>=
    AND_ASSIGN,     // &=
    XOR_ASSIGN,     // ^=
    OR_ASSIGN,      // |=
}

string stringOf(Operator op) {
    final switch(op) with(Operator) {
        case ADD: return "+";
        case SUB: return "-";
        case MUL: return "*";
        case DIV: return "/";
        case MOD: return "%";
        case SHL: return "<<";
        case SHR: return ">>";
        case BIT_AND: return "&";
        case BIT_XOR: return "^";
        case BIT_OR: return "|";
        case BIT_NOT: return "~";
        case NEG: return "-";
        case BOOL_NOT: return "!";
        case LT: return "<";
        case LTE: return "<=";
        case GT: return ">";
        case GTE: return ">=";
        case EQ: return "==";
        case NEQ: return "!=";
        case BOOL_AND: return "&&";
        case BOOL_OR: return "||";
        case ASSIGN: return "=";
        case ADD_ASSIGN: return "+=";
        case SUB_ASSIGN: return "-=";
        case MUL_ASSIGN: return "*=";
        case DIV_ASSIGN: return "/=";
        case MOD_ASSIGN: return "%=";
        case SHL_ASSIGN: return "<<=";
        case SHR_ASSIGN: return ">>=";
        case AND_ASSIGN: return "&=";
        case XOR_ASSIGN: return "^=";
        case OR_ASSIGN: return "|=";
    }
}

/**
 * Higher numbers have higher precedence
 */
int precedenceOf(Operator op) {
    final switch(op) with(Operator) {

        // Dot
        // Index
        // Call
        //    return 200

        // As
        // & addressof
        // * valueof
        //    return 180

        case NEG:
        case BIT_NOT:
        case BOOL_NOT:
            return 160;
        case MUL:
        case DIV:
        case MOD:
            return 100;
        case ADD:
        case SUB:
            return 80;
        case SHL:
        case SHR:
            return 70;
        case LT:
        case LTE:
        case GT:
        case GTE:
            return 60;
        case EQ:
        case NEQ:
            return 50;
        case BIT_AND:
            return 40;
        case BIT_XOR:
            return 35;
        case BIT_OR:
            return 30;
        case BOOL_AND:
            return 25;
        case BOOL_OR:
            return 20;

        case ASSIGN:
        case ADD_ASSIGN:
        case SUB_ASSIGN:
        case MUL_ASSIGN:
        case DIV_ASSIGN:
        case MOD_ASSIGN:
        case SHL_ASSIGN:
        case SHR_ASSIGN:
        case AND_ASSIGN:
        case XOR_ASSIGN:
        case OR_ASSIGN:
            return 10;
    }
}

Operator toUnaryOperator(TKind kind) {
    switch(kind) with(Operator) {
        case TKind.MINUS: return NEG;
        case TKind.EXCLAIM: return BOOL_NOT;
        case TKind.TILDE: return BIT_NOT;

        default:
            throw new Exception("Can't convert from TKind %s to Operator".format(kind));
    }
    assert(false);
}

Operator toBinaryOperator(TKind kind) {
    switch(kind) with(Operator) {
        case TKind.STAR: return MUL;
        case TKind.SLASH: return DIV;
        case TKind.PERCENT: return MOD;
        case TKind.PLUS: return ADD;
        case TKind.MINUS: return SUB;
        case TKind.LT_LT: return SHL;
        case TKind.GT_GT: return SHR;
        case TKind.LT: return LT;
        case TKind.LT_EQ: return LTE;
        case TKind.GT: return GT;
        case TKind.GT_EQ: return GTE;
        case TKind.EQ_EQ: return EQ;
        case TKind.EXCLAIM_EQ: return NEQ;
        case TKind.AMP: return BIT_AND;
        case TKind.HAT: return BIT_XOR;
        case TKind.PIPE: return BIT_OR;
        case TKind.AMP_AMP: return BOOL_AND;
        case TKind.PIPE_PIPE: return BOOL_OR;

        case TKind.EQ: return ASSIGN;
        case TKind.PLUS_EQ: return ADD_ASSIGN;
        case TKind.MINUS_EQ: return SUB_ASSIGN;
        case TKind.STAR_EQ: return MUL_ASSIGN;
        case TKind.SLASH_EQ: return DIV_ASSIGN;
        case TKind.PERCENT_EQ: return MOD_ASSIGN;
        case TKind.LT_LT_EQ: return SHL_ASSIGN;
        case TKind.GT_GT_EQ: return SHR_ASSIGN;
        case TKind.AMP_EQ: return AND_ASSIGN;
        case TKind.HAT_EQ: return XOR_ASSIGN;
        case TKind.PIPE_EQ: return OR_ASSIGN;

        default:
            throw new Exception("Can't convert from TKind %s to Operator".format(kind));
    }
    assert(false);
}
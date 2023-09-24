module candle.Operator;

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

        // Literals and Id are 0    
    }
}

Operator toUnaryOperator(EToken kind) {
    switch(kind) with(Operator) {
        case EToken.MINUS: return NEG;
        case EToken.TILDE: return BIT_NOT;

        default:
            throw new Exception("Can't convert from EToken %s to Operator".format(kind));
    }
    assert(false);
}

Operator toBinaryOperator(EToken kind) {
    switch(kind) with(Operator) {
        case EToken.STAR: return MUL;
        case EToken.SLASH: return DIV;
        case EToken.PERCENT: return MOD;
        case EToken.PLUS: return ADD;
        case EToken.MINUS: return SUB;
        case EToken.LT_LT: return SHL;
        case EToken.GT_GT: return SHR;
        case EToken.LT: return LT;
        case EToken.LT_EQ: return LTE;
        case EToken.GT: return GT;
        case EToken.GT_EQ: return GTE;
        case EToken.EQ_EQ: return EQ;
        case EToken.EXCLAIM_EQ: return NEQ;
        case EToken.AMP: return BIT_AND;
        case EToken.HAT: return BIT_XOR;
        case EToken.PIPE: return BIT_OR;
        case EToken.AMP_AMP: return BOOL_AND;
        case EToken.PIPE_PIPE: return BOOL_OR;

        case EToken.EQ: return ASSIGN;
        case EToken.PLUS_EQ: return ADD_ASSIGN;
        case EToken.MINUS_EQ: return SUB_ASSIGN;
        case EToken.STAR_EQ: return MUL_ASSIGN;
        case EToken.SLASH_EQ: return DIV_ASSIGN;
        case EToken.PERCENT_EQ: return MOD_ASSIGN;
        case EToken.LT_LT_EQ: return SHL_ASSIGN;
        case EToken.GT_GT_EQ: return SHR_ASSIGN;
        case EToken.AMP_EQ: return AND_ASSIGN;
        case EToken.HAT_EQ: return XOR_ASSIGN;
        case EToken.PIPE_EQ: return OR_ASSIGN;

        default:
            throw new Exception("Can't convert from EToken %s to Operator".format(kind));
    }
    assert(false);
}

bool isAssign(Operator op) {
    switch(op) with(Operator) {
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
            return true;
        default: return false;
    }
}
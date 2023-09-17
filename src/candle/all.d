module candle.all;

public:

import common;
import resources.json5;

import core.atomic              : atomicLoad, atomicOp;

import std.format               : format;
import std.algorithm            : all, map, filter;
import std.range                : array;
import std.array                : replace;
import std.stdio                : File, writefln;
import std.string               : toLower;
import std.datetime.stopwatch   : StopWatch;

import candle;

import candle._1lex.EToken;
import candle._1lex.FileCoord;
import candle._1lex.Lexer;
import candle._1lex.LexerManager;
import candle._1lex.Token;
import candle._1lex.Tokens;

import candle._2parse.Operator;
import candle._2parse.parse_expr;
import candle._2parse.parse_type;
import candle._2parse.parse_stmt;
import candle._2parse.ParseProject;

import candle._3resolve.find_call_target;
import candle._3resolve.find_id_target;
import candle._3resolve.find_type;
import candle._3resolve.ResolveProject;
import candle._3resolve.Target;
import candle._3resolve.Value;

import candle._4check.CheckProject;

import candle._5emit.CommonHeader;
import candle._5emit.EmitProject;

import candle._6build.BuildProject;
import candle._6build.Linker;

import candle.statics;
import candle.utils;

import candle.ast.ENode;
import candle.ast.node_builder;
import candle.ast.Node;
import candle.ast.NodeRef;
import candle.ast.Unit;

import candle.ast.expr.Binary;
import candle.ast.expr.BuiltinFunc;
import candle.ast.expr.Call;
import candle.ast.expr.Char;
import candle.ast.expr.Dot;
import candle.ast.expr.Expr;
import candle.ast.expr.Id;
import candle.ast.expr.Null;
import candle.ast.expr.Number;
import candle.ast.expr.Parens;
import candle.ast.expr.ProjectId;
import candle.ast.expr.Scope;
import candle.ast.expr.String;
import candle.ast.expr.Unary;

import candle.ast.stmt.Return;
import candle.ast.stmt.Stmt;
import candle.ast.stmt.Var;

import candle.ast.type.Array;
import candle.ast.type.Enum;
import candle.ast.type.EType;
import candle.ast.type.Func;
import candle.ast.type.Primitive;
import candle.ast.type.Pointer;
import candle.ast.type.Struct;
import candle.ast.type.Type;
import candle.ast.type.TypeRef;
import candle.ast.type.Union;

import candle.errors.errors;
import candle.errors.ResolutionError;
import candle.errors.SyntaxError;

version(GC_STATS) {
    ///
    /// Show GC stats after program exits
    ///
    extern(C) __gshared string[] rt_options = [
        "gcopt=profile:1"
    ];
}
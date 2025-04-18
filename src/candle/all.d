module candle.all;

public:

import common;
import common.containers;
import resources.json5;

import core.sync.mutex          : Mutex;
import core.atomic              : atomicLoad, atomicOp;
import core.memory              : GC;

import std.format               : format;
import std.algorithm            : all, filter, find, each, map, maxElement, sort;
import std.range                : array;
import std.array                : replace, join;
import std.stdio                : File, writefln;
import std.string               : toLower;
import std.datetime.stopwatch   : StopWatch, AutoStart;

import candle;

import candle.lex.EToken;
import candle.lex.FileCoord;
import candle.lex.Lex;
import candle.lex.Token;
import candle.lex.Tokens;

import candle.emitandbuild.Builder;
import candle.emitandbuild.BuildModule;
import candle.emitandbuild.EmitModule;
import candle.emitandbuild.Emitter;

import candle.parse.parse_expr;
import candle.parse.parse_type;
import candle.parse.parse_stmt;
import candle.parse.Parser;

import candle.resolve.find_call_target;
import candle.resolve.find_id_target;
import candle.resolve.find_type;
import candle.resolve.Operator;
import candle.resolve.Resolver;
import candle.resolve.Rewriter;
import candle.resolve.Target;
import candle.resolve.Value;

import candle.Checker;
import candle.Lexer;
import candle.Linker;
import candle.statics;
import candle.utils;

import candle.ast.ENode;
import candle.ast.node_builder;
import candle.ast.Node;
import candle.ast.NodeRef;
import candle.ast.Unit;

import candle.ast.expr.As;
import candle.ast.expr.Binary;
import candle.ast.expr.BuiltinFunc;
import candle.ast.expr.Call;
import candle.ast.expr.Char;
import candle.ast.expr.Dot;
import candle.ast.expr.Expr;
import candle.ast.expr.Id;
import candle.ast.expr.Is;
import candle.ast.expr.LiteralStruct;
import candle.ast.expr.ModuleId;
import candle.ast.expr.Null;
import candle.ast.expr.Number;
import candle.ast.expr.Parens;
import candle.ast.expr.Scope;
import candle.ast.expr.String;
import candle.ast.expr.Unary;

import candle.ast.stmt.Return;
import candle.ast.stmt.Stmt;
import candle.ast.stmt.Var;

import candle.ast.type.Alias;
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

import candle.errors.EError;
import candle.errors.errors;
import candle.errors.ResolutionError;
import candle.errors.SemanticError;
import candle.errors.SyntaxError;


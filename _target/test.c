// Module .. test

// Dependency Module headers
#include "std.h"

#include "vulkan.h"

#include "_stdio.h"

#include "test2.h"

// Module header
#include "test.h"

typedef __s32 test__AA;	// AA = __s32;

typedef test__AA test__BB;	// BB = test__AA;

typedef __f32 test__DD;	// DD = __f32;

typedef test__DD test__CC;	// CC = test__DD;

typedef test__DD** test__EE;	// EE = test__DD**;

typedef struct test__TestStructLiterals {
  __s32 a;
  __f32 b;
} test__TestStructLiterals;

typedef struct test__Inner {
  __s64 a;
  __s64 b;
} test__Inner;

typedef struct test__Local {
  __s8 a;
  __f32 b;
  test__Inner inner;
} test__Local;

typedef struct test__Peach {
  __s32 a;
} test__Peach;

typedef struct test__MyStruct {
  __s32 a;
} test__MyStruct;


// Private functions
static void test__alias_();
static void test__arrays();
static void test__as_();
static void test__binary();
static void test__func_();
static void test__id();
static void test__is_();
static void test__literalstruct();
static void test__strings();
static void test__struct_();
__s32 main();
static void test__doSomethingElse();
static void test__variables();

//──────────────────────────────────────────────────────────────────────────────────────────────────
// alias.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__alias_() {
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// arrays.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__arrays() {
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// as.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__as_() {
  __s32 a = 10; // Line 5
  __f32 b = 3.0f; // Line 6
  __s32 c = (__s32)10.3f; // Line 8
  candle__assert(c == 10, "as.can", 8);
  __f64 d = 10.9 + (__f64)(__s32)2.9; // Line 9
  candle__assert(d == 12.9, "as.can", 9);
  __s32 e = (__s32)(10.9 + 2.9); // Line 10
  candle__assert(e == 13, "as.can", 10);
  __s32 f = (__s32)10.9 + (__s32)2.9; // Line 11
  candle__assert(f == 12, "as.can", 11);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// binary.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__binary() {
  __s32 a = 10; // Line 3
  __s32 b = 20; // Line 4
  __s32 c = a + b; // Line 6
  candle__assert(c == 30, "binary.can", 6);
  __s32 d = a - b; // Line 7
  candle__assert(d == -10, "binary.can", 7);
  __s32 e = a * b; // Line 8
  candle__assert(e == 200, "binary.can", 8);
  __s32 f = b / a; // Line 9
  candle__assert(f == 2, "binary.can", 9);
  __s32 f2 = b % 3; // Line 10
  candle__assert(f2 == 2, "binary.can", 10);
  __s32 g = a << 1; // Line 12
  candle__assert(g == 20, "binary.can", 12);
  __s32 h = a >> 1; // Line 13
  candle__assert(h == 5, "binary.can", 13);
  __s32 i = a & 2; // Line 16
  candle__assert(i == 2, "binary.can", 16);
  __s32 j = a | 1; // Line 17
  candle__assert(j == 11, "binary.can", 17);
  __s32 k = a ^ 3; // Line 18
  candle__assert(k == 9, "binary.can", 18);
  __s32 l = ~a; // Line 21
  candle__assert(l == -11, "binary.can", 21);
  __s32 m = -a; // Line 23
  candle__assert(m == -10, "binary.can", 23);
  __s32 n = a < 20; // Line 25
  candle__assert(n, "binary.can", 25);
  __s32 n2 = a <= 10; // Line 26
  candle__assert(n2, "binary.can", 26);
  __s32 o = a > 5; // Line 28
  candle__assert(o, "binary.can", 28);
  __s32 o2 = a >= 10; // Line 29
  candle__assert(o2, "binary.can", 29);
  __s32 p = a == (b - 10); // Line 31
  candle__assert(p, "binary.can", 31);
  __s32 p2 = a != 0; // Line 32
  candle__assert(p2, "binary.can", 32);
  __s32 q = a < 20 && b > a; // Line 34
  candle__assert(q, "binary.can", 34);
  __s32 q2 = a < 20 || b < a; // Line 35
  candle__assert(q2, "binary.can", 35);
  __bool q3 = false || true; // Line 37
  candle__assert(q3, "binary.can", 37);
  __bool q4 = true && false; // Line 38
  candle__assert(!q4, "binary.can", 38);
  __bool q5 = true && true; // Line 39
  candle__assert(q5, "binary.can", 39);
  a += (__s32)1; // Line 41
  candle__assert(a == 11, "binary.can", 41);
  a -= (__s32)1; // Line 42
  candle__assert(a == 10, "binary.can", 42);
  a *= (__s32)2; // Line 43
  candle__assert(a == 20, "binary.can", 43);
  a /= (__s32)2; // Line 44
  candle__assert(a == 10, "binary.can", 44);
  a %= (__s32)3; // Line 45
  candle__assert(a == 1, "binary.can", 45);
  a <<= (__s32)1; // Line 46
  candle__assert(a == 2, "binary.can", 46);
  a >>= (__s32)1; // Line 47
  candle__assert(a == 1, "binary.can", 47);
  b &= (__s32)7; // Line 50
  candle__assert(b == 4, "binary.can", 50);
  b |= (__s32)8; // Line 51
  candle__assert(b == 12, "binary.can", 51);
  b ^= (__s32)15; // Line 54
  candle__assert(b == 3, "binary.can", 54);
  __bool boo = true; // Line 56
  boo &= (__bool)false; // Line 57
  candle__assert(boo == false, "binary.can", 57);
  boo |= (__bool)true; // Line 58
  candle__assert(boo == true, "binary.can", 58);
  __s32 r = 7; // Line 60
  r = (__s32)8; // Line 61
  candle__assert(r == 8, "binary.can", 61);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// func.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__func_() {
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// id.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__id() {
  test__Apple apple = {0}; // Line 6
  test__Peach peach = {0}; // Line 7
  std__string str = {0}; // Line 8
  __s32 appleA = apple.a; // Line 10
  __s32 peachA = peach.a; // Line 11
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// is.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__is_() {
  candle__assert(1 == 1, "is.can", 3); // Line 3
  candle__assert(true == true, "is.can", 4); // Line 4
  candle__assert(true, "is.can", 5); // Line 5
  candle__assert(1 != 0, "is.can", 7); // Line 7
  candle__assert(true != false, "is.can", 8); // Line 8
  candle__assert(true, "is.can", 9); // Line 9
  __s32 a = 0; // Line 11
  __f32 b = 0.0f; // Line 12
  candle__assert(true, "is.can", 13); // Line 13
  candle__assert(true, "is.can", 14); // Line 14
  candle__assert(true, "is.can", 15); // Line 15
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// literalstruct.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__literalstruct() {
  test__TestStructLiterals tsl = {0}; // Line 8
  candle__assert(tsl.a == 0, "literalstruct.can", 9); // Line 9
  candle__assert(tsl.b == 0.0f, "literalstruct.can", 10); // Line 10
  test__TestStructLiterals tsl2 = {.a = 1}; // Line 12
  candle__assert(tsl2.a == 1, "literalstruct.can", 13); // Line 13
  candle__assert(tsl2.b == 0.0f, "literalstruct.can", 14); // Line 14
  tsl = (test__TestStructLiterals){.a = 2, .b = 1.1f}; // Line 16
  candle__assert(tsl.a == 2, "literalstruct.can", 17); // Line 17
  candle__assert(tsl.b == 1.1f, "literalstruct.can", 18); // Line 18
  tsl = (test__TestStructLiterals){.b = 1.2f}; // Line 20
  candle__assert(tsl.a == 0, "literalstruct.can", 21); // Line 21
  candle__assert(tsl.b == 1.2f, "literalstruct.can", 22); // Line 22
  tsl = (test__TestStructLiterals){.b = 1.3f, .a = 9}; // Line 24
  candle__assert(tsl.a == 9, "literalstruct.can", 25); // Line 25
  candle__assert(tsl.b == 1.3f, "literalstruct.can", 26); // Line 26
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// strings.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__strings() {
  stdio__putChar('s'); // Line 4
  __s8* a = "one"; // Line 6
  stdio__putChars(a); // Line 7
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// struct.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__struct_() {
  test__Local local = {0}; // Line 6
  test__Local local2 = {0}; // Line 7
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// test.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static __s32 wibble = 0; // Line 4
static __f32 foo = 1.0f; // Line 68
__s32 main() {
  __s32 a = 6; // Line 7
  __s32* b = null; // Line 8
  putchar('a'); // Line 11
  stdio__putChar('b'); // Line 17
  test__doSomething(null, null); // Line 19
  test__doSomethingElse(); // Line 20
  candle__assert(true, "test.can", 22); // Line 22
  test__variables(); // Line 24
  test__binary(); // Line 25
  test__as_(); // Line 26
  test__is_(); // Line 27
  test__id(); // Line 28
  test__literalstruct(); // Line 29
  test__struct_(); // Line 30
  test__func_(); // Line 31
  test__alias_(); // Line 32
  test__strings(); // Line 33
  test__arrays(); // Line 34
  return 0; // Line 36
}
static void test__doSomethingElse() {
}
void test__doSomething(__s32* a, __f32** b) {
  __bool c = !true; // Line 46
  __s32 d = 'a'; // Line 48
  __s64 e = -1LL; // Line 49
  __f32 f = foo; // Line 50
  __s32 y = 1 + 2 / 3; // Line 52
  __s32 z = 1 / 2 + 3; // Line 53
  __f32 g = 1.0f; // Line 54
  __f32 g2 = 1.3f; // Line 55
  test__Apple apple = {0}; // Line 57
  std__PlumPublic plum = {0}; // Line 59
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// var.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void test__variables() {
  __bool a1 = false; // Line 3
  candle__assert(!a1, "var.can", 3);
  __bool a2 = true; // Line 4
  candle__assert(a2, "var.can", 4);
  __s8 b1 = 0; // Line 6
  candle__assert(b1 == 0, "var.can", 6);
  __s8 b2 = 1; // Line 7
  candle__assert(b2 == 1, "var.can", 7);
  __u8 c1 = 0; // Line 9
  candle__assert((__s8)c1 == 0, "var.can", 9);
  __u8 c2 = 2u; // Line 10
  candle__assert((__s8)c2 == 2, "var.can", 10);
  __s16 d1 = 0; // Line 12
  candle__assert(d1 == 0, "var.can", 12);
  __s16 d2 = 3; // Line 13
  candle__assert(d2 == 3, "var.can", 13);
  __u16 e1 = 0; // Line 15
  candle__assert(e1 == 0u, "var.can", 15);
  __u16 e2 = 4u; // Line 16
  candle__assert(e2 == 4u, "var.can", 16);
  __s32 f1 = 0; // Line 18
  candle__assert(f1 == 0, "var.can", 18);
  __s32 f2 = 5; // Line 19
  candle__assert(f2 == 5, "var.can", 19);
  __u32 g1 = 0; // Line 21
  candle__assert(g1 == 0u, "var.can", 21);
  __u32 g2 = 6u; // Line 22
  candle__assert(g2 == 6u, "var.can", 22);
  __s64 h1 = 0; // Line 24
  candle__assert(h1 == 0LL, "var.can", 24);
  __s64 h2 = 7LL; // Line 25
  candle__assert(h2 == 7LL, "var.can", 25);
  __u64 i1 = 0; // Line 27
  candle__assert(i1 == 0LLU, "var.can", 27);
  __u64 i2 = 8LLU; // Line 28
  candle__assert(i2 == 8LLU, "var.can", 28);
  __f32 j1 = 0.0f; // Line 30
  candle__assert(j1 == 0.0f, "var.can", 30);
  __f32 j2 = 9.1f; // Line 31
  candle__assert(j2 == 9.1f, "var.can", 31);
  __f64 k1 = 0.0; // Line 33
  candle__assert(k1 == 0.0, "var.can", 33);
  __f64 k2 = 10.0; // Line 34
  candle__assert(k2 == 10.0, "var.can", 34);
  test__MyStruct l = {0}; // Line 36
  void (*fp)(__s32,__f32) = null; // Line 39
  void* (*fp2)(void) = null; // Line 40
}

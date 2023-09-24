// Project .. test

// Dependency Project headers
#include "std.h"
// Project header
#include "test.h"
// Private structs
typedef struct TestStructLiterals {
  s32 a; // Line 3
  f32 b; // Line 4
} TestStructLiterals;
typedef struct Peach {
  s32 a; // Line 71
} Peach;
typedef struct MyStruct {
  s32 a; // Line 47
} MyStruct;
// Private unions
// Private function prototypes
static void as_();
static void binary();
static void id();
static void is_();
static void literalstruct();
s32 putchar(s32);
s32 main();
static void doSomethingElse();
static void variables();

//──────────────────────────────────────────────────────────────────────────────────────────────────
// as.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void as_() {
  s32 a = 10; // Line 3
  f32 b = 3.0f; // Line 4
  s32 c = (s32)10.3f; // Line 6
  candle__assert(c == 10, "as.can", 6);
  f64 d = 10.9 + (f64)(s32)2.9; // Line 7
  candle__assert(d == 12.9, "as.can", 7);
  s32 e = (s32)(10.9 + 2.9); // Line 8
  candle__assert(e == 13, "as.can", 8);
  s32 f = (s32)10.9 + (s32)2.9; // Line 9
  candle__assert(f == 12, "as.can", 9);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// binary.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void binary() {
  s32 a = 10; // Line 3
  s32 b = 20; // Line 4
  s32 c = a + b; // Line 6
  candle__assert(c == 30, "binary.can", 6);
  s32 d = a - b; // Line 7
  candle__assert(d == -10, "binary.can", 7);
  s32 e = a * b; // Line 8
  candle__assert(e == 200, "binary.can", 8);
  s32 f = b / a; // Line 9
  candle__assert(f == 2, "binary.can", 9);
  s32 f2 = b % 3; // Line 10
  candle__assert(f2 == 2, "binary.can", 10);
  s32 g = a << 1; // Line 12
  candle__assert(g == 20, "binary.can", 12);
  s32 h = a >> 1; // Line 13
  candle__assert(h == 5, "binary.can", 13);
  s32 i = a & 2; // Line 16
  candle__assert(i == 2, "binary.can", 16);
  s32 j = a | 1; // Line 17
  candle__assert(j == 11, "binary.can", 17);
  s32 k = a ^ 3; // Line 18
  candle__assert(k == 9, "binary.can", 18);
  s32 l = ~a; // Line 21
  candle__assert(l == -11, "binary.can", 21);
  s32 m = -a; // Line 23
  candle__assert(m == -10, "binary.can", 23);
  s32 n = a < 20; // Line 25
  candle__assert(n, "binary.can", 25);
  s32 n2 = a <= 10; // Line 26
  candle__assert(n2, "binary.can", 26);
  s32 o = a > 5; // Line 28
  candle__assert(o, "binary.can", 28);
  s32 o2 = a >= 10; // Line 29
  candle__assert(o2, "binary.can", 29);
  s32 p = a == (b - 10); // Line 31
  candle__assert(p, "binary.can", 31);
  s32 p2 = a != 0; // Line 32
  candle__assert(p2, "binary.can", 32);
  s32 q = a < 20 && b > a; // Line 34
  candle__assert(q, "binary.can", 34);
  s32 q2 = a < 20 || b < a; // Line 35
  candle__assert(q2, "binary.can", 35);
  bool q3 = false || true; // Line 37
  candle__assert(q3, "binary.can", 37);
  bool q4 = true && false; // Line 38
  candle__assert(!q4, "binary.can", 38);
  bool q5 = true && true; // Line 39
  candle__assert(q5, "binary.can", 39);
  a += (s32)1; // Line 41
  candle__assert(a == 11, "binary.can", 41);
  a -= (s32)1; // Line 42
  candle__assert(a == 10, "binary.can", 42);
  a *= (s32)2; // Line 43
  candle__assert(a == 20, "binary.can", 43);
  a /= (s32)2; // Line 44
  candle__assert(a == 10, "binary.can", 44);
  a %= (s32)3; // Line 45
  candle__assert(a == 1, "binary.can", 45);
  a <<= (s32)1; // Line 46
  candle__assert(a == 2, "binary.can", 46);
  a >>= (s32)1; // Line 47
  candle__assert(a == 1, "binary.can", 47);
  b &= (s32)7; // Line 50
  candle__assert(b == 4, "binary.can", 50);
  b |= (s32)8; // Line 51
  candle__assert(b == 12, "binary.can", 51);
  b ^= (s32)15; // Line 54
  candle__assert(b == 3, "binary.can", 54);
  bool boo = true; // Line 56
  boo &= (bool)false; // Line 57
  candle__assert(boo == false, "binary.can", 57);
  boo |= (bool)true; // Line 58
  candle__assert(boo == true, "binary.can", 58);
  s32 r = 7; // Line 60
  r = (s32)8; // Line 61
  candle__assert(r == 8, "binary.can", 61);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// id.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void id() {
  test__Apple apple = {0}; // Line 6
  Peach peach = {0}; // Line 7
  std__string str = {0}; // Line 8
  s32 appleA = apple.a; // Line 10
  s32 peachA = peach.a; // Line 11
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// is.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void is_() {
  candle__assert(1 == 1, "is.can", 3); // Line 3
  candle__assert(true == true, "is.can", 4); // Line 4
  candle__assert(true, "is.can", 5); // Line 5
  candle__assert(1 != 0, "is.can", 7); // Line 7
  candle__assert(true != false, "is.can", 8); // Line 8
  candle__assert(true, "is.can", 9); // Line 9
  s32 a = 0; // Line 11
  f32 b = 0.0f; // Line 12
  candle__assert(true, "is.can", 13); // Line 13
  candle__assert(true, "is.can", 14); // Line 14
  candle__assert(true, "is.can", 15); // Line 15
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// literalstruct.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void literalstruct() {
  TestStructLiterals tsl = {0}; // Line 8
  candle__assert(tsl.a == 0, "literalstruct.can", 9); // Line 9
  candle__assert(tsl.b == 0.0f, "literalstruct.can", 10); // Line 10
  TestStructLiterals tsl2 = {.a = 1}; // Line 12
  candle__assert(tsl2.a == 1, "literalstruct.can", 13); // Line 13
  candle__assert(tsl2.b == 0.0f, "literalstruct.can", 14); // Line 14
  tsl = (TestStructLiterals){.a = 2, .b = 1.1f}; // Line 16
  candle__assert(tsl.a == 2, "literalstruct.can", 17); // Line 17
  candle__assert(tsl.b == 1.1f, "literalstruct.can", 18); // Line 18
  tsl = (TestStructLiterals){.b = 1.2f}; // Line 20
  candle__assert(tsl.a == 0, "literalstruct.can", 21); // Line 21
  candle__assert(tsl.b == 1.2f, "literalstruct.can", 22); // Line 22
  tsl = (TestStructLiterals){.b = 1.3f, .a = 9}; // Line 24
  candle__assert(tsl.a == 9, "literalstruct.can", 25); // Line 25
  candle__assert(tsl.b == 1.3f, "literalstruct.can", 26); // Line 26
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// test.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static s32 wibble = 0; // Line 5
static f32 foo = 1.0f; // Line 62
s32 main() {
  s32 a = 6; // Line 8
  s32* b = null; // Line 10
  putchar('a'); // Line 13
  std__putChar('b'); // Line 16
  test__doSomething(null, null); // Line 18
  doSomethingElse(); // Line 19
  candle__assert(true, "test.can", 21); // Line 21
  variables(); // Line 23
  binary(); // Line 24
  as_(); // Line 25
  is_(); // Line 26
  id(); // Line 27
  literalstruct(); // Line 28
  return 0; // Line 30
}
static void doSomethingElse() {
}
void test__doSomething(s32* a, f32** b) {
  bool c = !true; // Line 40
  s32 d = 'a'; // Line 42
  s64 e = -1LL; // Line 43
  f32 f = foo; // Line 44
  s32 y = 1 + 2 / 3; // Line 46
  s32 z = 1 / 2 + 3; // Line 47
  f32 g = 1.0f; // Line 48
  f32 g2 = 1.3f; // Line 49
  test__Apple apple = {0}; // Line 51
  std__PlumPublic plum = {0}; // Line 53
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// vars.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void variables() {
  bool a1 = false; // Line 3
  candle__assert(!a1, "vars.can", 3);
  bool a2 = true; // Line 4
  candle__assert(a2, "vars.can", 4);
  s8 b1 = 0; // Line 6
  candle__assert(b1 == 0, "vars.can", 6);
  s8 b2 = 1; // Line 7
  candle__assert(b2 == 1, "vars.can", 7);
  u8 c1 = 0; // Line 9
  candle__assert((s8)c1 == 0, "vars.can", 9);
  u8 c2 = 2u; // Line 10
  candle__assert((s8)c2 == 2, "vars.can", 10);
  s16 d1 = 0; // Line 12
  candle__assert(d1 == 0, "vars.can", 12);
  s16 d2 = 3; // Line 13
  candle__assert(d2 == 3, "vars.can", 13);
  u16 e1 = 0; // Line 15
  candle__assert(e1 == 0u, "vars.can", 15);
  u16 e2 = 4u; // Line 16
  candle__assert(e2 == 4u, "vars.can", 16);
  s32 f1 = 0; // Line 18
  candle__assert(f1 == 0, "vars.can", 18);
  s32 f2 = 5; // Line 19
  candle__assert(f2 == 5, "vars.can", 19);
  u32 g1 = 0; // Line 21
  candle__assert(g1 == 0u, "vars.can", 21);
  u32 g2 = 6u; // Line 22
  candle__assert(g2 == 6u, "vars.can", 22);
  s64 h1 = 0; // Line 24
  candle__assert(h1 == 0LL, "vars.can", 24);
  s64 h2 = 7LL; // Line 25
  candle__assert(h2 == 7LL, "vars.can", 25);
  u64 i1 = 0; // Line 27
  candle__assert(i1 == 0LLU, "vars.can", 27);
  u64 i2 = 8LLU; // Line 28
  candle__assert(i2 == 8LLU, "vars.can", 28);
  f32 j1 = 0.0f; // Line 30
  candle__assert(j1 == 0.0f, "vars.can", 30);
  f32 j2 = 9.1f; // Line 31
  candle__assert(j2 == 9.1f, "vars.can", 31);
  f64 k1 = 0.0; // Line 33
  candle__assert(k1 == 0.0, "vars.can", 33);
  f64 k2 = 10.0; // Line 34
  candle__assert(k2 == 10.0, "vars.can", 34);
  MyStruct l = {0}; // Line 36
  void (*fp)(s32,f32) = null; // Line 40
  void* (*fp2)(void) = null; // Line 41
}

// Project .. test

#include "std.h"
#include "test.h"
// Prototypes
static void as_();
static void binary();
s32 putchar(s32);
s32 main();
static void doSomethingElse();
void test__doSomething(s32* a, f32** b);
static void variables();

//──────────────────────────────────────────────────────────────────────────────────────────────────
// as.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void as_() {
  s32 a = 10;
  f32 b = 3.0f;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// binary.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
static void binary() {
  s32 a = 10;
  s32 b = 20;
  s32 c = a + b;
  candle__assert(c == 30, "binary.can", 6);
  s32 d = a - b;
  candle__assert(d == -10, "binary.can", 7);
  s32 e = a * b;
  candle__assert(e == 200, "binary.can", 8);
  s32 f = b / a;
  candle__assert(f == 2, "binary.can", 9);
  s32 f2 = b % 3;
  candle__assert(f2 == 2, "binary.can", 10);
  s32 g = a << 1;
  candle__assert(g == 20, "binary.can", 12);
  s32 h = a >> 1;
  candle__assert(h == 5, "binary.can", 13);
  s32 i = a & 2;
  candle__assert(i == 2, "binary.can", 16);
  s32 j = a | 1;
  candle__assert(j == 11, "binary.can", 17);
  s32 k = a ^ 3u;
  candle__assert(k == 9, "binary.can", 18);
  s32 l = ~a;
  candle__assert(l == -11, "binary.can", 21);
  s32 m = -a;
  candle__assert(m == -10, "binary.can", 23);
  s32 n = a < 20;
  candle__assert(n, "binary.can", 25);
  s32 n2 = a <= 10;
  candle__assert(n2, "binary.can", 26);
  s32 o = a > 5;
  candle__assert(o, "binary.can", 28);
  s32 o2 = a >= 10;
  candle__assert(o2, "binary.can", 29);
  s32 p = a == (b - 10);
  candle__assert(p, "binary.can", 31);
  s32 p2 = a != 0;
  candle__assert(p2, "binary.can", 32);
  s32 q = a < 20 && b > a;
  candle__assert(q, "binary.can", 34);
  s32 q2 = a < 20 || b < a;
  candle__assert(q2, "binary.can", 35);
  a += 1;
  candle__assert(a == 11, "binary.can", 37);
  a -= 1;
  candle__assert(a == 10, "binary.can", 38);
  a *= 2;
  candle__assert(a == 20, "binary.can", 39);
  a /= 2;
  candle__assert(a == 10, "binary.can", 40);
  a %= 3;
  candle__assert(a == 1, "binary.can", 41);
  a <<= 1;
  candle__assert(a == 2, "binary.can", 42);
  a >>= 1;
  candle__assert(a == 1, "binary.can", 43);
  b &= 7u;
  candle__assert(b == 4, "binary.can", 46);
  b |= 8u;
  candle__assert(b == 12, "binary.can", 47);
  b ^= 15u;
  candle__assert(b == 3u, "binary.can", 50);
  bool boo = true;
  boo &= false;
  candle__assert(boo == false, "binary.can", 53);
  boo |= true;
  candle__assert(boo == true, "binary.can", 54);
  s32 r = 7;
  r = 8;
  candle__assert(r == 8, "binary.can", 57);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// test.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
typedef struct Peach {
s32 a;
} Peach;

static s32 wibble = 0;
static f32 foo = 1.0f;
s32 main() {
  s32 a = 6;
  s32* b = null;
  putchar('a');
  std__putChar('b');
  test__doSomething(null, null);
  doSomethingElse();
  candle__assert(true, "test.can", 21);
  variables();
  binary();
  as_();
  return 0;
}
static void doSomethingElse() {
}
void test__doSomething(s32* a, f32** b) {
  bool c = !true;
  s32 d = 'a';
  s64 e = -1LL;
  f32 f = foo;
  s32 y = 1 + 2 / 3;
  s32 z = 1 / 2 + 3;
  f32 g = 1.0f;
  f32 g2 = 1.3f;
  test__Apple apple;
  std__PlumPublic plum;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// vars.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
typedef struct MyStruct {
s32 a;
} MyStruct;

static void variables() {
  bool a1 = false;
  candle__assert(!a1, "vars.can", 3);
  bool a2 = true;
  candle__assert(a2, "vars.can", 4);
  s8 b1 = 0;
  candle__assert(b1 == 0, "vars.can", 6);
  s8 b2 = 1;
  candle__assert(b2 == 1, "vars.can", 7);
  u8 c1 = 0;
  candle__assert(c1 == 0, "vars.can", 9);
  u8 c2 = 2u;
  candle__assert(c2 == 2, "vars.can", 10);
  s16 d1 = 0;
  candle__assert(d1 == 0, "vars.can", 12);
  s16 d2 = 3;
  candle__assert(d2 == 3, "vars.can", 13);
  u16 e1 = 0;
  candle__assert(e1 == 0, "vars.can", 15);
  u16 e2 = 4u;
  candle__assert(e2 == 4, "vars.can", 16);
  s32 f1 = 0;
  candle__assert(f1 == 0, "vars.can", 18);
  s32 f2 = 5;
  candle__assert(f2 == 5, "vars.can", 19);
  u32 g1 = 0;
  candle__assert(g1 == 0, "vars.can", 21);
  u32 g2 = 6u;
  candle__assert(g2 == 6, "vars.can", 22);
  s64 h1 = 0;
  candle__assert(h1 == 0, "vars.can", 24);
  s64 h2 = 7LL;
  candle__assert(h2 == 7, "vars.can", 25);
  u64 i1 = 0;
  candle__assert(i1 == 0, "vars.can", 27);
  u64 i2 = 8LLU;
  candle__assert(i2 == 8, "vars.can", 28);
  f32 j1 = 0.0f;
  candle__assert(j1 == 0.0f, "vars.can", 30);
  f32 j2 = 9.1f;
  candle__assert(j2 == 9.1f, "vars.can", 31);
  f64 k1 = 0.0;
  candle__assert(k1 == 0.0, "vars.can", 33);
  f64 k2 = 10.0;
  candle__assert(k2 == 10.0, "vars.can", 34);
  MyStruct l;
  void (*fp)(s32,f32) = null;
  void* (*fp2)(void) = null;
}

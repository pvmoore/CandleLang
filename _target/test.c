// Project .. test

#include "std.h"
#include "test.h"
// Prototypes
s32 putchar(s32);
s32 main();
static void doSomethingElse();
void test__doSomething(s32* a, f32** b);
static void variables();

//──────────────────────────────────────────────────────────────────────────────────────────────────
// Unit test
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
  return 0;
}
static void doSomethingElse() {
}
void test__doSomething(s32* a, f32** b) {
  bool c = !true;
  s32 d = 'a';
  s64 e = 255LL;
  f32 f = foo;
  s32 y = 1 + 2 / 3;
  s32 z = 1 / 2 + 3;
  f32 g = 1.0f;
  f32 g2 = 1.3f;
  test__Apple apple;
  std__PlumPublic plum;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// Unit vars
//──────────────────────────────────────────────────────────────────────────────────────────────────
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
}

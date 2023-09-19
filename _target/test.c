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

static f32 foo = 1.0f;
s32 main() {
  s32 a = 6;
  s32* b = null;
  putchar('a');
  std__putChar('b');
  test__doSomething(null, null);
  doSomethingElse();
  candle__assert(true, "test.can", 18);
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
  bool a1;
  bool a2 = true;
  candle__assert(a2, "vars.can", 4);
  s8 b1;
  s8 b2 = 1;
  u8 c1;
  u8 c2 = 2u;
  s16 d1;
  s16 d2 = 3;
  u16 e1;
  u16 e2 = 4u;
  s32 f1;
  s32 f2 = 5;
  u32 g1;
  u32 g2 = 6u;
  s64 h1;
  s64 h2 = 7LL;
  u64 i1;
  u64 i2 = 8LLU;
  f32 j1;
  f32 j2 = 9.1f;
  f64 k1;
  f64 k2 = 10.0;
}

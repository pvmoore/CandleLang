// Project .. test

#include "std.h"
#include "test.h"
// Prototypes
int putchar(int);
int main();
void doSomethingElse();
void test__doSomething(int* a, float** b);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// Unit test
//──────────────────────────────────────────────────────────────────────────────────────────────────
typedef struct Peach {
  int a;
} Peach;

float foo = 1;
int main() {
  int a = 6;
  int* b = null;
  putchar('a');
  std__putChar('b');
  test__doSomething(null, null);
  doSomethingElse();
  candle__assert(false, "test.can", 19);
  return 0;
}
void doSomethingElse() {
}
void test__doSomething(int* a, float** b) {
  bool c = !true;
  int d = 'a';
  long long e = 255LL;
  float f = foo;
  int y = 1 + 2 / 3;
  int z = 1 / 2 + 3;
  float g = 1;
  float g2 = 1.3f;
  test__Apple apple;
  std__PlumPublic plum;
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// Unit test_var
//──────────────────────────────────────────────────────────────────────────────────────────────────

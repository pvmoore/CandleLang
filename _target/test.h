#ifndef test_H
#define test_H

#include "candle__common.h"

typedef s32* test__PA2;	// PA2 = s32*;

typedef test__PA2 test__PA1;	// PA1 = test__PA2;

typedef struct test__Apple {
  s32 a;
} test__Apple;

void test__doSomething(s32* a, f32** b);

#endif // test_H

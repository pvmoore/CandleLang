#ifndef test_H
#define test_H

#include "candle__common.h"

typedef __s32* test__PA2;	// PA2 = __s32*;

typedef test__PA2 test__PA1;	// PA1 = test__PA2;

typedef struct test__Apple {
  __s32 a;
} test__Apple;

void test__doSomething(__s32* a, __f32** b);

#endif // test_H

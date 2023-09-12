#ifndef test_H
#define test_H

// ============== Common typedefs
#ifndef CANDLE_COMMON_TYPEDEFS_H
#define CANDLE_COMMON_TYPEDEFS_H

typedef unsigned char bool;
typedef unsigned char ubyte;
typedef signed char byte;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long long ulong;
#define true 1
#define false 0
#define null 0

#endif // CANDLE_COMMON_TYPEDEFS_H

// ============== Publics

typedef struct test_Apple {
  int a;
} test_Apple;

void test_doSomething(int* a, float** b);

#endif // test_H

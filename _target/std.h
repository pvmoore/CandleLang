#ifndef std_H
#define std_H

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

typedef struct std_PlumPublic {
  int a;
} std_PlumPublic;

void std_putChar(int ch);

#endif // std_H

#ifndef std_H
#define std_H

#include "candle__common.h"

typedef struct std__PlumPublic {
  __s32 a;
} std__PlumPublic;

typedef struct std__string {
  __u8* ptr;
  __u64 length;
} std__string;

void std__putChar(__s32 ch);
void std__putChars(__s8* ch);

#endif // std_H

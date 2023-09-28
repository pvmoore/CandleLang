#ifndef std_H
#define std_H

#include "candle__common.h"

typedef struct std__PlumPublic {
  s32 a;
} std__PlumPublic;

typedef struct std__string {
  u8* ptr;
  u64 length;
} std__string;

void std__putChar(s32 ch);

#endif // std_H

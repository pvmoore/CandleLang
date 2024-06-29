#ifndef std__H
#define std__H

#include "candle__common.h"

typedef struct std__PlumPublic {
  __s32 a;
} std__PlumPublic;

typedef struct std__string {
  __u8* ptr;
  __u64 length;
} std__string;


#endif // std__H

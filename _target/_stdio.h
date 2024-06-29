#ifndef stdio__H
#define stdio__H

#include "candle__common.h"

__s32 putchar(__s32);
__s32 puts(const __s8*);
void stdio__putChar(__s32 ch);
void stdio__putChars(__s8* ch);

#endif // stdio__H

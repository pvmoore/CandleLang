#ifndef stdio__H
#define stdio__H

#include "candle__common.h"

struct FILE;

__s32 putchar(__s32);
__s32 puts(const __s8*);
void stdio__putChar(__s32 ch);
void stdio__putChars(__s8* ch);
FILE* fopen(const __s8* filename, const __s8* mode);

#endif // stdio__H

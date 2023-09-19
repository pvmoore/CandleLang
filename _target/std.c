// Project .. std

#include "std.h"
// Prototypes
s32 putchar(s32);
void std__putChar(s32 ch);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// std.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
typedef struct PlumPrivate {
  s32 a;
} PlumPrivate;

void std__putChar(s32 ch) {
  putchar(ch);
}

// Project .. std

// Dependency Project headers
// Project header
#include "std.h"

typedef struct PlumPrivate {
  s32 a;
} PlumPrivate;


// Private functions
s32 putchar(s32);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// std.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
void std__putChar(s32 ch) {
  putchar(ch); // Line 6
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// string.can
//──────────────────────────────────────────────────────────────────────────────────────────────────

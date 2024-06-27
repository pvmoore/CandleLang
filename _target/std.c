// Project .. std

// Dependency Project headers
// Project header
#include "std.h"

typedef struct PlumPrivate {
  __s32 a;
} PlumPrivate;


// Private functions
__s32 putchar(__s32);
__s32 puts(const __s8*);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// std.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
void std__putChar(__s32 ch) {
  putchar(ch); // Line 8
}
void std__putChars(__s8* ch) {
  puts(ch); // Line 11
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// string.can
//──────────────────────────────────────────────────────────────────────────────────────────────────

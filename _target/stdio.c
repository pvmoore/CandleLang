// Project .. stdio

// Dependency Project headers
// Project header
#include "_stdio.h"


// Private functions

//──────────────────────────────────────────────────────────────────────────────────────────────────
// stdio.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
void stdio__putChar(__s32 ch) {
  putchar(ch); // Line 6
}
void stdio__putChars(__s8* ch) {
  puts(ch); // Line 9
}

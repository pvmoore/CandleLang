// Project .. stdio

// Dependency Project headers
// Project header
#include "_stdio.h"


// Private functions
__s32 putchar(__s32);
__s32 puts(const __s8*);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// stdio.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
void stdio__putChar(__s32 ch) {
  putchar(ch); // Line 6
}
void stdio__putChars(__s8* ch) {
  puts(ch); // Line 9
}

// Project .. std

// Dependency Project headers
// Project header
#include "std.h"
// Private structs
typedef struct PlumPrivate {
  s32 a;
} PlumPrivate;
// Private unions
// Private function prototypes
s32 putchar(s32);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// std.can
//──────────────────────────────────────────────────────────────────────────────────────────────────
void std__putChar(s32 ch) {
  putchar(ch);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
// string.can
//──────────────────────────────────────────────────────────────────────────────────────────────────

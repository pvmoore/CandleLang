// Project .. std

#include "std.h"
// Prototypes
int putchar(int);
void std__putChar(int ch);

//──────────────────────────────────────────────────────────────────────────────────────────────────
// Unit std
//──────────────────────────────────────────────────────────────────────────────────────────────────
typedef struct PlumPrivate {
  int a;
} PlumPrivate;

void std__putChar(int ch) {
  putchar(ch);
}

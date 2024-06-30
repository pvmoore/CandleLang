
#ifndef CANDLE_COMMON_TYPEDEFS_H
#define CANDLE_COMMON_TYPEDEFS_H

#define _CRT_SECURE_NO_WARNINGS

typedef unsigned char __bool;
typedef unsigned char __u8;
typedef signed char __s8;
typedef unsigned short __u16;
typedef signed short __s16;
typedef unsigned int __u32;
typedef signed int __s32;
typedef signed long long __s64;
typedef unsigned long long __u64;
typedef float __f32;
typedef double __f64;

#define true 1
#define false 0
#define null 0

#include "stdlib.h"
#include "stdio.h"

static void candle__assert(__s32 value, const char* unitName, __u32 line) {
    if(value == 0) {
        putchar(13); putchar(10);
        printf("!! Assertion failed: [%s] Line %u", unitName, line);
        putchar(13); putchar(10);
        exit(-1);
    } 
}

#endif

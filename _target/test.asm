; Listing generated by Microsoft (R) Optimizing Compiler Version 19.37.32822.0 

include listing.inc

INCLUDELIB LIBCMT
INCLUDELIB OLDNAMES

PUBLIC	foo
_DATA	SEGMENT
foo	DD	03f800000r			; 1
_DATA	ENDS
PUBLIC	test_doSomething
PUBLIC	main
PUBLIC	doSomethingElse
PUBLIC	__real@3f800000
PUBLIC	__real@3fa66666
EXTRN	std_putChar:PROC
EXTRN	putchar:PROC
EXTRN	_fltused:DWORD
pdata	SEGMENT
$pdata$test_doSomething DD imagerel $LN3
	DD	imagerel $LN3+98
	DD	imagerel $unwind$test_doSomething
$pdata$main DD	imagerel $LN3
	DD	imagerel $LN3+62
	DD	imagerel $unwind$main
pdata	ENDS
;	COMDAT __real@3fa66666
CONST	SEGMENT
__real@3fa66666 DD 03fa66666r			; 1.3
CONST	ENDS
;	COMDAT __real@3f800000
CONST	SEGMENT
__real@3f800000 DD 03f800000r			; 1
CONST	ENDS
xdata	SEGMENT
$unwind$test_doSomething DD 010e01H
	DD	0620eH
$unwind$main DD	010401H
	DD	06204H
xdata	ENDS
; Function compile flags: /Odtp
_TEXT	SEGMENT
doSomethingElse PROC
; File C:\pvmoore\d\apps\CandleLang\_target\test.c
; Line 29
	ret	0
doSomethingElse ENDP
_TEXT	ENDS
; Function compile flags: /Odtp
_TEXT	SEGMENT
a$ = 32
b$ = 40
main	PROC
; File C:\pvmoore\d\apps\CandleLang\_target\test.c
; Line 19
$LN3:
	sub	rsp, 56					; 00000038H
; Line 20
	mov	DWORD PTR a$[rsp], 6
; Line 21
	mov	QWORD PTR b$[rsp], 0
; Line 22
	mov	ecx, 97					; 00000061H
	call	putchar
; Line 23
	mov	ecx, 98					; 00000062H
	call	std_putChar
; Line 24
	xor	edx, edx
	xor	ecx, ecx
	call	test_doSomething
; Line 25
	call	doSomethingElse
; Line 26
	xor	eax, eax
; Line 27
	add	rsp, 56					; 00000038H
	ret	0
main	ENDP
_TEXT	ENDS
; Function compile flags: /Odtp
_TEXT	SEGMENT
c$ = 0
d$ = 4
f$ = 8
y$ = 12
z$ = 16
g$ = 20
g2$ = 24
e$ = 32
a$ = 64
b$ = 72
test_doSomething PROC
; File C:\pvmoore\d\apps\CandleLang\_target\test.c
; Line 30
$LN3:
	mov	QWORD PTR [rsp+16], rdx
	mov	QWORD PTR [rsp+8], rcx
	sub	rsp, 56					; 00000038H
; Line 31
	mov	BYTE PTR c$[rsp], 0
; Line 32
	mov	DWORD PTR d$[rsp], 97			; 00000061H
; Line 33
	mov	QWORD PTR e$[rsp], 255			; 000000ffH
; Line 34
	vmovss	xmm0, DWORD PTR foo
	vmovss	DWORD PTR f$[rsp], xmm0
; Line 35
	mov	DWORD PTR y$[rsp], 1
; Line 36
	mov	DWORD PTR z$[rsp], 3
; Line 37
	vmovss	xmm0, DWORD PTR __real@3f800000
	vmovss	DWORD PTR g$[rsp], xmm0
; Line 38
	vmovss	xmm0, DWORD PTR __real@3fa66666
	vmovss	DWORD PTR g2$[rsp], xmm0
; Line 41
	add	rsp, 56					; 00000038H
	ret	0
test_doSomething ENDP
_TEXT	ENDS
END

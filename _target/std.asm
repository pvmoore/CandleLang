; Listing generated by Microsoft (R) Optimizing Compiler Version 19.37.32822.0 

include listing.inc

INCLUDELIB LIBCMT
INCLUDELIB OLDNAMES

PUBLIC	std_putChar
EXTRN	putchar:PROC
pdata	SEGMENT
$pdata$std_putChar DD imagerel $LN3
	DD	imagerel $LN3+22
	DD	imagerel $unwind$std_putChar
pdata	ENDS
xdata	SEGMENT
$unwind$std_putChar DD 010801H
	DD	04208H
xdata	ENDS
; Function compile flags: /Odtp
_TEXT	SEGMENT
ch$ = 48
std_putChar PROC
; File C:\pvmoore\d\apps\CandleLang\_target\std.c
; Line 16
$LN3:
	mov	DWORD PTR [rsp+8], ecx
	sub	rsp, 40					; 00000028H
; Line 17
	mov	ecx, DWORD PTR ch$[rsp]
	call	putchar
; Line 18
	add	rsp, 40					; 00000028H
	ret	0
std_putChar ENDP
_TEXT	ENDS
END

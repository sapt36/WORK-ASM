.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	msg1 BYTE "請輸入第一個數字(2~12):",0
	inval1 DWORD ?
	msg2 BYTE "請輸入第二個數字(2~12):",0
	inval2 DWORD ?
	msg3 BYTE	" != ",0
	msg4 BYTE	"C(n,k) = ",0
	msg5 BYTE	"H(n,k) = ",0
	msg6 BYTE	"請輸入河內塔的數量:",0
	msg7 BYTE	"->",0
	msg8 BYTE	"  |  ",0
	nplate DWORD ?

	Combination PROTO nval1:DWORD ,nval2:DWORD
	Factorial PROTO nval:DWORD
	Hanoi PROTO plate:DWORD , pole1:BYTE, pole2:BYTE, pole3:BYTE

.code
main proc

	mov edx,OFFSET msg1
	call	WriteString
	call	ReadDec
	mov inval1,eax
	mov edx,OFFSET msg2
	call	WriteString
	call	ReadDec
	mov inval2,eax
	mov eax,inval1
	call WriteDec
	mov edx,OFFSET msg3
	call	WriteString
	INVOKE Factorial , inval1
	call WriteDec
	call Crlf
	mov eax,inval2
	call WriteDec
	mov edx,OFFSET msg3
	call	WriteString
	INVOKE Factorial,inval2
	call WriteDec
	call Crlf
	mov eax,inval1
	.IF inval2>eax
		xchg eax,inval2
		mov inval1,eax
	.ENDIF
	mov eax,0
	INVOKE Combination,inval1,inval2
	mov edx,OFFSET msg4
	call	WriteString
	call WriteDec
	call Crlf
	mov ebx,inval1
	add ebx,inval2
	dec ebx
	mov eax,0
	INVOKE Combination ,ebx ,inval2
	mov edx,OFFSET msg5
	call	WriteString
	call WriteDec
	call Crlf
	call WaitMsg
	call Crlf
	call Crlf
	mov edx,OFFSET msg6
	call	WriteString
	call ReadDec
	mov nplate ,eax
	INVOKE Hanoi,nplate,'A','B','C'

	call Crlf
	call WaitMsg
	invoke ExitProcess,0
main endp

Combination PROC uses ebx,nval1:DWORD,nval2:DWORD

	mov ebx,nval1
	.IF (ebx== nval2) || (nval2 == 0)
		add eax,1
	.ELSE 
		dec nval1
		INVOKE Combination,nval1,nval2
		dec nval2
		INVOKE Combination,nval1,nval2
	.ENDIF
		ret
Combination ENDP

Factorial PROC,nval:DWORD
	.IF nval == 1
		mov eax,1
	.ELSE 
		push nval
		dec nval 
		INVOKE Factorial,nval
		pop nval 
		mul nval
	.ENDIF
	ret
Factorial ENDP

Hanoi PROC ,plate:DWORD,pole1:BYTE,pole2:BYTE,pole3:BYTE
	.IF plate !=0
		dec plate 
		INVOKE Hanoi,plate ,pole1,pole3,pole2
		mov eax,plate
		inc eax
		call WriteDec
		mov al,':'
		call WriteChar
		mov al,pole1
		call WriteChar
		mov edx,OFFSET msg7
		call WriteString
		mov al,pole3
		call WriteChar
		mov edx,OFFSET msg8
		call WriteString
		INVOKE Hanoi,plate,pole2,pole1,pole3
	.ENDIF
	ret
Hanoi ENDP
end main

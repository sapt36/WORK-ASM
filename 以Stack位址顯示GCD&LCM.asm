.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	msg1 BYTE "請輸入第一個數字:",0
	inval1 DWORD ?
	msg2 BYTE "請輸入第二個數字:",0
	inval2 DWORD ?
	str1 BYTE "Address ",0
	str2 BYTE " = ",0
	str3 BYTE "Stack parameters: ",0dh,0ah
		 BYTE "---------------------",0dh,0ah,0
	CalcGcd PROTO,int1:DWORD,int2:DWORD
	MySample PROTO first:DWORD,second:DWORD,third:DWORD
	ShowParams PROTO numParams:DWORD
	WriteStackFrame PROTO,
		numParam:DWORD,
		numLocalVal:DWORD,
		numSavedReg:DWORD
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

	INVOKE CalcGcd,inval1,inval2

	mov ebx,12345678h
	mov ebp,99999999h

	INVOKE MySample,eax,inval2,inval1

	call Crlf
	call WaitMsg
	invoke ExitProcess,0
main endp

MySample PROC uses eax ebx,
		first:DWORD, second:DWORD, third:DWORD
		local sum:DWORD

		mov eax,third
		mov ebx,second
		mul ebx
		mov ebx,first
		div ebx
		mov sum,eax

		PARAMS = 3
		LOCALS = 1
		SAVED_REGS = 2
		INVOKE WriteStackFrame,PARAMS,LOCALS,SAVED_REGS

		FrameSize = 8

		INVOKE ShowParams,FrameSize

		ret
MySample ENDP

ShowParams PROC, numParams:DWORD

	mov edx,OFFSET str3
	call WriteString

	mov eax,numParams
	add eax,3
	mov ecx ,eax
	dec eax
	mov esi,TYPE DWORD
	mul esi
	mov esi,esp
	add esi,eax

L1: mov edx ,OFFSET str1
	call WriteString

	mov eax,esi
	call WriteHex
	mov edx ,OFFSET str2
	call WriteString
	mov eax,[esi]
	call WriteHex
	call Crlf

	sub esi,4
	loop L1

	ret
ShowParams ENDP

CalcGcd PROC,
	int1:DWORD,int2:DWORD
	mov eax,int1
	mov ebx,int2
	mov edx,0
	div ebx
	cmp edx,0
	je L2
	INVOKE CalcGcd,ebx,edx
L2: mov eax,ebx
ret
calcGcd ENDP
end main

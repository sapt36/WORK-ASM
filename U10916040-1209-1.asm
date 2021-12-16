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
		WIA:
			mov eax,[esi]
			call WriteInt
			mov al,','
			call WriteChar
			mov al,' '
			call WriteChar
			add esi,4
			cmp esi,edi
			jle WIA
			ret
	WriteIntegerArray ENDP
	
	SelectionSort PROC
		mov ebx,esi
	SSL1:
		push esi
		push edi
		call WriteIntegerArray
		pop edi
		pop esi
		call ReadChar
		call Crlf
		mov eax,[ebx]
		push ebx
	SSL2:
		add ebx,4
		cmp eax,[ebx]
		jle SSL3		;change to jge to decrease progressively
		xchg eax,[ebx]
	SSL3:
		cmp ebx,edi
		jl SSL2
		pop ebx
		mov [ebx],eax
		add ebx,4
		cmp ebx,edi
		jl SSL1
		ret
	SelectionSort ENDP

	QuickSort PROC
		push esi
		push edi
		mov esi,OFFSET targetArray
		mov edi,esi
		add edi,gap
		call WriteIntegerArray
		pop edi
		pop esi
		call ReadChar
		call Crlf
		cmp esi,edi
		jae QSL1
		push esi
		mov eax,[edi]
		mov ebx,esi
		sub esi,4
	QSL2:
		cmp eax,[ebx]
		jle QSL3		;change to jge to decrease progressively
		add esi,4
		mov edx,[esi]
		xchg edx,[ebx]
		mov [esi],edx
	QSL3:
		add ebx,4
		cmp ebx,edi
		jnz QSL2
		add esi,4
		mov edx,[esi]
		xchg edx,[edi]
		mov [esi],edx
		push esi 
		add esi,4
		call QuickSort
		pop edi
		pop esi
		sub edi,4
		call QuickSort
	QSL1:
		ret
	QuickSort ENDP

	InsertionSort PROC
		mov ebx,esi
	ISL1:
		push esi
		push edi
		call WriteIntegerArray
		pop edi
		pop esi
		call ReadChar
		call Crlf
		mov eax,ebx
		cmp eax,edi
		ja ISL2
		mov eax,[ebx]
		push ebx
		mov edx,ebx
		sub edx,4
	ISL4:
		cmp edx,esi
		jb ISL3
		cmp eax,[edx]
		jae ISL3		;change to jbe to decrease progressively
		push eax
		mov eax,[edx]
		mov [ebx],eax
		pop eax
		sub ebx,4
		sub edx,4
		jmp ISL4
	ISL3:
		mov [ebx],eax
		pop ebx
		add ebx,4
		jmp ISL1
	ISL2:
		ret
	InsertionSort ENDP

	BubbleSort PROC 
		mov ecx,count
		dec ecx
	BSL1: 
		push ecx
		push esi
		push edi
		call WriteIntegerArray
		pop edi
		pop esi
		call ReadChar
		call Crlf
		mov esi,pArray
	BSL2: 
		mov eax,[esi]
		cmp [esi+4],eax
		jg BSL3			;change to jl to decrease progressively
		xchg eax,[esi+4]
		mov [esi],eax
	BSL3: 
		add esi,4
		loop BSL2

		pop ecx
		loop BSL1
	BSL4: ret 
	BubbleSort ENDP
end main
; Program Sort (U10916040-1209-1.asm)
; Program Description: range number sorting
; Author: Andrew Chen
; Creation Date: 12/06
; Date: 12/09 Modified by: Author

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	buffer1 BYTE "我是U10916040陳冠廷1",0
	buffer2 BYTE "請輸入random number的數量(<50):",0
	buffer5 BYTE "請輸入選擇(B)selectsort(C)quicksort(D)bubblesort(E)QUIT: ",0
	buffer6 BYTE "ERROR! 請重新輸入...",0
	randArray DWORD 51 DUP(0)
	targetArray DWORD 51 DUP(0)
	pArray DWORD targetArray
	itemcount DWORD ?
	count DWORD ?
	lowerbound DWORD ?
	upperbound DWORD ?
	gap DWORD ?
	choice BYTE ?
.code
main proc

	mov edx,OFFSET buffer1
	call	WriteString
	call	Crlf
	mov edx,OFFSET buffer2
	call	WriteString
	call	ReadInt
	mov itemcount,eax
	mov count,eax
	call	Crlf
	mov eax,132
	mov	lowerbound,eax
	call	Crlf
	mov eax,887
	mov	upperbound,eax
	call Crlf

	call Randomize
	mov ecx,itemcount
	mov esi,0
L1:
	mov ebx,lowerbound
	mov eax,upperbound
	call BetterRandomRange
	mov randArray[esi],eax
	add esi,TYPE randArray
	loop L1

	sub esi,4
	mov gap,esi
L3:
	call Clrscr
	mov esi,OFFSET randArray
	mov edi,esi
	add edi,gap
	call WriteIntegerArray

	call Crlf
	mov edx,OFFSET buffer5
	call	WriteString
	call	ReadChar
	mov choice,al
	call Crlf

	cmp al,'E'
	jz L4

	mov ecx,itemcount
	mov esi,OFFSET randArray
	mov edi,OFFSET targetArray

L2:
	mov eax,[esi]
	mov [edi],eax
	add esi,4
	add edi,4
	loop L2

	mov al,choice
	cmp al,'B'
	jz no1

	cmp al,'C'
	jz no3
	cmp al,'D'
	jz no4
	mov edx,OFFSET buffer6
	call WriteString
	call Crlf
	call WaitMsg
	jmp L3

no1:
	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call SelectionSort

	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call WriteIntegerArray
	call Crlf
	call WaitMsg
	jmp L3

no3:
	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call QuickSort

	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call WriteIntegerArray
	call Crlf
	call WaitMsg
	jmp L3
no4:
	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call BubbleSort

	mov esi,OFFSET targetArray
	mov edi,esi
	add edi,gap
	call WriteIntegerArray
	call Crlf
	call waitMsg
	jmp L3
L4:
	call Crlf
	call WaitMsg
	invoke ExitProcess,0
	main endp

	BetterRandomRange PROC
		sub eax,ebx
		call RandomRange
		add eax,ebx

		ret
	BetterRandomRange ENDP

	WriteIntegerArray PROC
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

ExitProcess proto
ReadInt64   proto
WriteInt64  proto
WriteString proto
Crlf        proto
Randomize   proto
RandomRange proto

.data
	buffer1		BYTE "我是U10916040陳冠廷1", 0
	buffer2		BYTE "請輸入Random Number的數量(少於50):", 0
	buffer3		BYTE "請輸入Random Number的lowerbound:", 0
	buffer4		BYTE "請輸入Random Number的upperbound:", 0
	buffer5		BYTE "請輸入選擇 (1)SelectionSort (2)InsertionSort (3)QuickSort (4)quit.....", 0
	buffer6		BYTE "不恰當的選擇，請重新輸入選擇.....", 0
	buffer7		BYTE ",", 0
	buffer8		BYTE " ", 0
	randArray   QWORD 51 DUP(0) 
	targetArray QWORD 51 DUP(0)
	itemcount   QWORD ?
	lowerbound  QWORD ?
	upperbound  QWORD ?
	gap			QWORD ?
	choice		QWORD ?

.code
main proc
	mov	 RDX, OFFSET buffer1
	call WriteString
	call Crlf

	mov  RDX, OFFSET buffer2
	call WriteString
	call ReadInt64
	mov  itemcount, RAX
	call Crlf

	mov  RDX, OFFSET buffer3
	call WriteString
	call ReadInt64
	mov  lowerbound, RAX
	call Crlf
	
	mov  RDX, OFFSET buffer4
	call WriteString
	call ReadInt64
	mov  upperbound, RAX
	call Crlf

	call Randomize
	mov  RCX, itemcount
	mov  RSI, 0
L1:
	mov  RBX, lowerbound
	mov  RAX, upperbound
	call BetterRandomRange
	mov  randArray[RSI], RAX
	add  RSI, TYPE randArray
	loop L1

	sub	 RSI, 8
	mov  gap, RSI
L3:
	mov  RCX, itemcount
	mov  RSI, OFFSET randArray
	mov  RDI, RSI
	add  RDI, gap
	call WriteIntegerArray
	call Crlf
	
	mov  RDX, OFFSET buffer5
	call WriteString
	call ReadInt64
	mov  choice, RAX
	call Crlf
	
	cmp  RAX, 4
	jz	 L4
	
	mov  RCX, itemcount
	mov	 RSI, OFFSET randArray
	mov  RDI, OFFSET targetArray
L2:
	mov  RAX, [RSI]
	mov  [RDI],RAX
	add  RSI, 8
	add  RDI, 8
	loop L2
	
	mov  RCX, itemcount
	mov  RAX, choice
	cmp  RAX, 1
	jz   no1
	cmp  RAX, 2
	jz   no2
	cmp  RAX, 3
	jz   no3
	mov  RDX, OFFSET buffer6
	call WriteString
	call Crlf
	call ReadInt64
	jmp  L3
	
no1:
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call SelectionSort
	
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call WriteIntegerArray
	call Crlf
	call ReadInt64
	jmp  L3
no2:
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call InsertionSort
	
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call WriteIntegerArray
	call Crlf
	call ReadInt64
	jmp  L3
no3:
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call QuickSort
	
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call WriteIntegerArray
	call Crlf
	call ReadInt64
	jmp  L3
L4:
	call Crlf
	call ReadInt64
	mov  RCX, 0
	call ExitProcess
main endp

BetterRandomRange PROC
	sub  RAX, RBX
	call RandomRange
	add  RAX, RBX
	ret
BetterRandomRange ENDP

WriteIntegerArray PROC uses RSI RCX RAX
WIA:
	mov  RAX,[RSI]
	call WriteInt64
	mov  RDX, OFFSET buffer7
	call WriteString
	mov  RDX, OFFSET buffer8
	call WriteString
	add  RSI, 8
	loop WIA
	ret
WriteIntegerArray ENDP

SelectionSort PROC
	mov  RBX,RSI
BSL1:
	push RSI
	push RDI
	call WriteIntegerArray
	pop  RDI
	pop  RSI
	call ReadInt64
	call Crlf
	mov  RAX, [RBX]
	push RBX
BSL2:
	add  RBX, 8
	cmp  RAX, [RBX]
	jle  BSL3
	xchg RAX, [RBX]
BSL3:
	cmp  RBX, RDI
	jl   BSL2
	pop  RBX
	mov  [RBX], RAX
	add  RBX, 8
	cmp  RBX, RDI
	jl   BSL1
	ret
SelectionSort ENDP

InsertionSort PROC
	mov  RBX, RSI
ISL1:
	push RSI
	push RDI
	call WriteIntegerArray
	pop  RDI
	pop  RSI
	call ReadInt64
	call Crlf
	mov  RAX, RBX
	cmp  RAX, RDI
	ja   ISL2
	mov  RAX, [RBX]
	push RBX
	mov  RDX, RBX
	sub  RDX, 8
ISL4:
	cmp  RDX, RSI
	jb   ISL3
	cmp  RAX, [RDX]
	jae  ISL3
	push RAX
	mov  RAX, [RDX]
	mov  [RBX], RAX
	pop  RAX
	sub  RBX, 8
	sub  RDX, 8
	jmp  ISL4
ISL3:
	mov  [RBX], RAX
	pop  RBX
	add  RBX, 8
	jmp  ISL1
ISL2:
	ret
InsertionSort ENDP

QuickSort PROC
	push RSI
	push RDI
	mov  RSI, OFFSET targetArray
	mov  RDI, RSI
	add  RDI, gap
	call WriteIntegerArray
	pop  RDI
	pop  RSI
	call ReadInt64
	call Crlf
	cmp  RSI, RDI
	jae  QSL1
	push RSI
	mov  RAX, [RDI]
	mov  RBX, RSI
	sub  RSI, 8
QSL2:
	cmp  RAX, [RBX]
	jle  QSL3
	add  RSI, 8
	mov  RDX, [RSI]
	xchg RDX, [RBX]
	mov  [RSI], RDX
QSL3:
	add  RBX, 8
	cmp  RBX, RDI
	jnz  QSL2
	add  RSI, 8
	mov  RDX, [RSI]
	xchg RDX, [RDI]
	mov  [RSI], RDX
	push RSI
	add  RSI, 8
	call QuickSort
	pop  RDI
	pop  RSI
	sub  RDI, 8
	call QuickSort
QSL1:
	ret
QuickSort ENDP

ReverseIntegerArray PROC
	push QWORD ptr[RSI]
	add  RSI, 8
	loop RIA
	pop  QWORD ptr [RDI]
	add  RDI, 8
	ret
RIA: call ReverseIntegerArray
	pop  QWORD ptr [RDI]
	add  RDI, 8
	ret
ReverseIntegerArray ENDP
end

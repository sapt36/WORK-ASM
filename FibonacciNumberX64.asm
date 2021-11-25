ExitProcess proto
ReadInt64 proto
WriteInt64 proto
WriteString proto
Crlf proto

.data
	buffer1		BYTE "我是U10916040陳冠廷1"
	buffer2		BYTE "請輸入Fibonacci Number的數量(<93):",0
	buffer3     BYTE ",",0
	fibArray	QWORD 100 DUP(0)
	itemno		QWORD ?
.code
main proc
	mov		RDX,OFFSET buffer1
	call	WriteString
	call	Crlf
	mov		RDX,OFFSET buffer2
	call	WriteString
	call	ReadInt64
	mov		itemno,RAX
	call	Crlf
	mov		RBX,0
	mov		RDX,1
	mov		fibArray,RDX

	mov		RCX,itemno
	dec		RCX
	mov		RSI,TYPE fibArray

L1:
	mov		RAX,RBX
	add		RAX,RDX
	mov		fibArray[RSI],RAX
	mov		RBX,RDX
	mov		RDX,RAX
	add		RSI,TYPE fibArray
	loop l1

	mov		RCX,itemno
	mov		RSI,0

L2:
	mov		RAX,fibArray[RSI]
	call	WriteInt64
	add		RSI,TYPE fibArray
	mov		RDX, OFFSET buffer3
	call	WriteString 
	loop l2

	call	Crlf
	mov     RCX,0
	call	ExitProcess
main endp
end 

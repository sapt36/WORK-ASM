ExitProcess proto
ReadInt64 proto
WriteInt64 proto
WriteString proto
Crlf proto
Random64 proto
ReadString proto
RandomRange proto
.data
	buffer1 BYTE "我是U10916040陳冠廷1",0
	buffer2 BYTE "請輸入random number的數量:",0
	buffer3 BYTE "請輸入random number的lowerbound:",0
	buffer4 BYTE "請輸入random number的upperbound:",0
	randArray QWORD 51 DUP(0)
	targetArray QWORD 51 DUP(0)
	itemcount QWORD ?
	lowerbound QWORD ?
	upperbound QWORD ?
	temp BYTE 100 DUP(0)
.code
main proc

	mov RDX,OFFSET buffer1
	call	WriteString
	call	Crlf
	mov RDX,OFFSET buffer2
	call	WriteString
	call	ReadInt64
	mov itemcount,RAX
	call	Crlf
	mov RDX,OFFSET buffer3
	call	WriteString
	call	ReadInt64
	mov	lowerbound,RAX
	call	Crlf
	mov RDX,OFFSET buffer4
	call	WriteString
	call	ReadInt64
	mov	upperbound,RAX
	call Crlf

	call RandomRange
	mov RCX,itemcount
	mov RSI,0
L1:
	mov RBX,lowerbound
	mov RAX,upperbound
	call BetterRandomRange
	mov randArray[RSI],RAX
	add RSI,TYPE randArray
	loop L1

	mov RSI,OFFSET randArray
	mov RCX,itemcount
	call WriteIntegerArray

	call Crlf
	mov RDX,OFFSET temp
	mov RCX,99
	call ReadString
	call Crlf
	call Crlf

	mov RSI,OFFSET randArray
	mov RDI,OFFSET targetArray
	mov RCX,itemcount
	call ReverseIntegerArray

	mov RSI,OFFSET targetArray
	mov RCX,itemcount
	call WriteIntegerArray 

	call Crlf
	mov RDX,OFFSET temp
	mov RCX,99
	call ReadString
	mov RCX,0
	call	ExitProcess
main endp

	BetterRandomRange PROC
		sub RAX,RBX
		call RandomRange
		add RAX,RBX

		ret
	BetterRandomRange ENDP

	WriteIntegerArray PROC
		WIA:
			mov RAX,[RSI]
			call WriteInt64
			call Crlf
			add RSI,8
			loop WIA
			ret
	WriteIntegerArray ENDP

	ReverseIntegerArray PROC
		push QWORD ptr [RSI]
		add RSI,8
		loop RIA
		pop QWORD ptr [RDI]
		add RDI,8
		ret

		RIA:call ReverseIntegerArray
		pop QWORD ptr [RDI]
		add RDI,8
		ret
	ReverseIntegerArray ENDP
end

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	buffer1 BYTE "我是U10916040陳冠廷1",0
	buffer2 BYTE "請輸入選擇(1)產生亂數(2)QUIT: ",0
	buffer3 BYTE "........產生序號 : ",0
.code
main proc

	mov edx,OFFSET buffer1
	call	WriteString
	call	Crlf
	mov ebx,1
	call Randomize
L3:
	mov edx,OFFSET buffer2
	call	WriteString
	call	ReadChar
	call	Crlf
	cmp al,'2'
	jz L4
	cmp al,'1'
	mov eax,10000
	call randomRange
	call WriteDec
	mov edx,OFFSET buffer3
	call	WriteString
	push eax
	mov eax,ebx
	call	WriteDec
	pop eax
	inc ebx
	call	Crlf
	jmp L3

L4:
	call Crlf
	call WaitMsg
	invoke ExitProcess,0
main endp
end main

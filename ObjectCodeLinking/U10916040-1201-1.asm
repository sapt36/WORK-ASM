.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE test.inc
.data
	msg1 BYTE "請輸入數字(0~32760):",0
	inval DWORD ?
	msg2 BYTE "請輸入基底(2~36或-2~-36)",0
	base SDWORD ?
	msg3 BYTE 17 DUP(0)
	msg4 BYTE "錯誤請重新輸入......",0
	temp DWORD ?
.code
main proc
L0:
	mov edx,OFFSET msg1
	call	WriteString
	call	ReadDec
	mov inval,eax
	.IF eax<1 || eax>32670
		call Crlf
		mov edx,OFFSET msg4
		call	WriteString
		call	Crlf
		jmp L2
	.ENDIF
L2:
	mov edx,OFFSET msg2
		call	WriteString
		call	ReadInt
		mov base,eax
		cmp eax,-36
		jge L4
L3:
	call Crlf
		mov edx,OFFSET msg4
		call	WriteString
		call	Crlf
		jmp L2
L4:
	cmp eax,36

	jg L3
	.IF eax == 0 || eax == 1
		jmp L3
	.ENDIF

	and eax,eax
	.IF SIGN?
		neg eax
	.ENDIF 
	mov temp,eax

	mov eax,inval
	mov ebx,base
	mov esi,OFFSET msg3
	.WHILE eax <1 || eax >= temp
		cdq
		idiv ebx
		and edx,edx
		.IF SIGN?
			add edx,temp
			inc eax
		.ENDIF
		.IF edx > 9
			add edx,55
		.ELSE
			add edx,48
		.ENDIF
		mov [esi],dl
		inc esi
	.ENDW
	.IF eax >9
		add eax,55
	.ELSE
		add eax,48
	.ENDIF
		mov [esi],al

	mov esi,OFFSET msg3
	mov ecx,0
	mov ah,0
	mov al,[esi]
	.WHILE al != 0
		push ax
		inc ecx
		inc esi
		mov al,[esi]
	.ENDW
	sub esi,ecx
L5:
	pop ax
	mov [esi],al
	inc esi
	loop L5
	mov edx,OFFSET msg3
	call	WriteString

	call Crlf
	call WaitMsg
	invoke ExitProcess,0
main endp
end main
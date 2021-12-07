.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	msg1 BYTE "我是U10916040陳冠廷1",0
	msg2 BYTE "請輸入被乘數: ",0
	msg3 BYTE "請輸入乘數: ",0
	msg4 BYTE " * 65536 * 65536",0
	msg5 BYTE " + ",0
	multiplicand QWORD 0
 	multiplier DWORD ?
.code
main proc

	mov edx,OFFSET msg1
	call	WriteString
	call	Crlf
	mov edx,OFFSET msg2
	call	WriteString
	call	ReadDec
	mov DWORD ptr [multiplicand],eax
	call	Crlf
	mov edx,OFFSET msg3
	call	WriteString
	call	ReadDec
	mov multiplier,eax
	call	Crlf
	call multiply

	call WriteDec
	push edx
	mov edx,OFFSET msg5
	call	WriteString
	pop edx
	mov eax,edx
	call WriteDec
	mov edx,OFFSET msg4
	call	WriteString
	call	Crlf

	call WaitMsg
	invoke ExitProcess,0
main endp

	multiply PROC 
		mov eax,0
		mov edx,0
 L0:
	push eax
	mov eax,0
		mov ebx,multiplier
		shrd ebx,eax,1
	pop eax
		pushfd
		mov multiplier,ebx
		.IF CARRY?
			add eax,DWORD ptr [multiplicand]
			adc edx,DWORD ptr [multiplicand+4]
		.ENDIF
		popfd
		.IF ZERO?
			jmp L1
		.ENDIF
		
		shl DWORD ptr [multiplicand+4],1
		shl DWORD ptr [multiplicand],1
		adc DWORD ptr [multiplicand+4],0
		jmp L0
	L1:
		ret
	multiply ENDP
end main
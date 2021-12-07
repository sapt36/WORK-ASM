.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	msg1 BYTE "我是U10916040陳冠廷1",0
	msg2 BYTE "請輸入一個小於1000000的數: ",0
	msg3 BYTE "質數數量為: ",0
	inumber DWORD ?
	sieve BYTE 1000000 DUP(1)
	prime DWORD 80000 DUP(0)
	noofprime DWORD ?
.code
main proc

	mov edx,OFFSET msg1
	call	WriteString
	call	Crlf
	mov edx,OFFSET msg2
	call	WriteString
	call	ReadInt
	mov inumber,eax
	call	Crlf
	call marknotprime
	call printprime
	call factorization
	call WaitMsg
	invoke ExitProcess,0
main endp

	marknotprime PROC uses eax edi
		mov sieve[0],0
		mov sieve[1],0
		mov edi,2
		.REPEAT
			.IF sieve[edi]==1
				mov eax,edi
				.REPEAT
					add eax,edi
					mov sieve[eax],0
				.UNTIL eax>inumber
			.ENDIF
			inc edi
			mov eax,edi
			mul edi
		.UNTIL eax>inumber
		ret
	marknotprime ENDP

	printprime PROC uses esi edi eax ecx
		mov esi,0
		mov edi,0
		.WHILE esi<=inumber
			.IF sieve[esi]==1
				mov prime[edi],esi
				add edi,4
				mov eax,esi
				call WriteDec
				mov al,','
				call WriteChar
				mov al,' '
				call WriteChar
			.ENDIF
			inc esi
		.ENDW
		call Crlf
		mov edx,OFFSET msg3
		call	WriteString
		mov eax,edi
		mov edx,0
		mov ecx,4
		div ecx
		mov noofprime,eax
		call WriteDec
		call Crlf
		ret
	printprime ENDP
	
	factorization PROC uses esi edi edx eax
		mov esi,0
		mov ebx,prime[esi]
		.WHILE ebx<= inumber
			mov edx,0
			mov eax,inumber
		div ebx
		.IF edx==0
			mov inumber,eax
			mov eax,prime[esi]
			call WriteDec
			mov al,' '
			call WriteChar
		.ELSE
			add esi,4
		.ENDIF
		mov ebx,prime[esi]
	.ENDW
	call Crlf
	ret
	factorization ENDP
end main
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
.data
	buffer1 BYTE "我是U10916040陳冠廷1",0
	buffer2 BYTE "請輸入選擇(1)Hamming code Generation(2)Hamming code verification(3)QUIT: ",0
	buffer3 BYTE "ERROR! 請重新輸入...",0
	buffer4 BYTE "輸入欲編碼之Binary data string(5~前57位元)",0
	buffer5 BYTE "錯誤的位元在位置",0
	buffer6 BYTE "輸入欲處理之Hamming code Binary string(5~前63位元)",0
	buffer7 BYTE "正確",0
	CodedArray BYTE 64 DUP(0)
	CodedLength DWORD ?
	DataArray BYTE 58 DUP(0)
	DataLength DWORD ?
	HCLength DWORD ?
	choice BYTE ?
	choiceTable BYTE '1'
				DWORD GenerateHamming
	EntrySize = ($ - choiceTable)
				BYTE '2'
				DWORD VerifyHamming
	NumberOfEntries = ($ - choiceTable)
.code
main proc
L0:
	call Clrscr
	mov edx,OFFSET buffer1
	call	WriteString
	call	Crlf
	mov edx,OFFSET buffer2
	call	WriteString
	call	ReadChar
	mov choice,al
	call	Crlf

	mov ebx,OFFSET choiceTable	
 	mov ecx,NumberOfEntries
L1:
	cmp al,[ebx]
	jne L2
	call NEAR PTR [ebx+1]
	call WaitMsg
	jmp L0
L2:
	add ebx,EntrySize
	loop L1
L3:
	cmp al,'3'
	je L4
	mov edx,OFFSET buffer3
	call	WriteString
	call	Crlf
	call WaitMsg
	jmp L0
L4:
	call	Crlf
	call WaitMsg
	invoke ExitProcess,0
main endp

	VerifyHamming PROC
	VH1:
	mov edx,OFFSET buffer6
	call	WriteString
	call	Crlf
	mov edx,OFFSET CodedArray
	mov ecx,SIZEOF CodedArray
	call ReadString
	mov CodedLength,eax
	call Crlf
	.IF CodedLength<5
		mov edx,OFFSET buffer3
		call	WriteString
		call	Crlf
		jmp VH1
	.ELSEIF CodedLength<=7
		mov HCLength,3
	.ELSEIF CodedLength<=15
		mov HCLength,4
	.ELSEIF CodedLength<=31
		mov HCLength,5
	.ELSE
		mov HCLength,6
	.ENDIF
	mov esi,0
	.REPEAT
		mov al,CodedArray[esi]
		.IF !(al==30h || al==31h)
			.BREAK
		.ENDIF
		inc esi
	.UNTIL esi==CodedLength
	.IF esi!=CodedLength
		mov edx,OFFSET buffer3
		call	WriteString
		call	Crlf
		jmp VH1
	.ENDIF
	mov eax,0
	mov ecx,0
	.REPEAT
		mov bl,CodedArray[ecx]
		inc ecx
		.IF bl==31h
			xor eax,ecx
		.ENDIF
	.UNTIL ecx==CodedLength
	.IF eax==0
		mov edx,OFFSET buffer7
		call	WriteString
	.ELSE
		mov edx,OFFSET buffer5
		call	WriteString
		call    WriteDec
	.ENDIF
	call Crlf
	ret
	VerifyHamming ENDP

	GenerateHamming PROC
	GH1:
		mov edx,OFFSET buffer4
		call	WriteString
		call	Crlf
		mov edx,OFFSET DataArray
		mov ecx,SIZEOF DataArray
		call ReadString
		mov DataLength,eax
		call Crlf
		.IF DataLength<2
		mov edx,OFFSET buffer3
		call	WriteString
		call	Crlf
		jmp GH1
		.ELSEIF DataLength<=4
			mov HCLength,3
		.ELSEIF DataLength<=11
			mov HCLength,4
		.ELSEIF DataLength<=26
			mov HCLength,5
		.ELSE
			mov HCLength,6
		.ENDIF
		mov esi,0
		.REPEAT
			mov al,DataArray[esi]
			.IF !(al==30h||al==31h)
				.BREAK
			.ENDIF
			inc esi
		.UNTIL esi==DataLength
		.IF esi!=DataLength
		mov edx,OFFSET buffer3
		call	WriteString
		call	Crlf
		jmp	GH1
		.ENDIF
		mov esi,0
		mov edi,0
		mov CodedArray[edi],30h
		inc edi
		mov CodedArray[edi],30h
		inc edi
		.REPEAT
			.IF DataArray[esi]==30h
				mov CodedArray[edi],30h
			.ELSE 
				mov CodedArray[edi],31h
			.ENDIF
			inc esi
			inc edi
			.IF edi==3 || edi ==7 || edi==15 || edi==31
				mov CodedArray[edi],30h
				inc edi
			.ENDIF
		.UNTIL esi==DataLength
		mov  CodedArray[edi],0
		mov eax,DataLength
		add eax,HCLength
		mov CodedLength,eax
		mov eax,0
		mov ecx,0
		.REPEAT
			mov bl,CodedArray[ecx]
			inc ecx
			.IF bl==31h
				xor eax,ecx
			.ENDIF
		.UNTIl ecx==CodedLength
		call WriteBin
		call Crlf
		mov ecx,0
		.REPEAT
			bt eax,ecx
			pushfd
			inc ecx
			.IF ecx==1
				popfd
				.If CARRY?
					mov CodedArray[0],31h
				.ELSE 
					mov CodedArray[0],30h
				.ENDIF
			.ELSEIF ecx==2
				popfd
				.If CARRY?
					mov CodedArray[1],31h
				.ELSE 
					mov CodedArray[1],30h
				.ENDIF
			.ELSEIF ecx==3
				popfd
				.If CARRY?
					mov CodedArray[3],31h
				.ELSE 
					mov CodedArray[3],30h
				.ENDIF
			.ELSEIF ecx==4
				popfd
				.If CARRY?
					mov CodedArray[7],31h
				.ELSE 
					mov CodedArray[7],30h
				.ENDIF
			.ELSEIF ecx==5
				popfd
				.If CARRY?
					mov CodedArray[15],31h
				.ELSE 
					mov CodedArray[15],30h
				.ENDIF
			.ELSE
				popfd
				.If CARRY?
					mov CodedArray[31],31h
				.ELSE 
					mov CodedArray[31],30h
				.ENDIF
			.ENDIF
			.UNTIL ecx==HCLength
			call PrintHammingArray
			ret
	GenerateHamming ENDP

	PrintHammingArray PROC
		mov ecx,0
		mov ebx,0
		.REPEAT
		mov al,CodedArray[ecx]
		call WriteChar
		inc ecx
		inc ebx
		.IF ebx==4
			mov ebx,0
			mov al,' '
			call WriteChar
		.ENDIF
	.UNTIL ecx==CodedLength
	call Crlf
	ret
	PrintHammingArray ENDP
end main

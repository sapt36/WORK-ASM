.386
.model flat, stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc

GenerateString PROTO
CopyString PROTO, source:PTR BYTE, destination: PTR BYTE, nchar:DWORD
SearchChar PROTO, targetarray:PTR BYTE, found: PTR DWORD, nchar: DWORD, key:BYTE
SetCursor PROTO, xpos:BYTE, ypos:BYTE
SearchString PROTO, targetarray:PTR BYTE, pattern:PTR BYTE, nchar:DWORD
CaseChange PROTO, targetarray:PTR BYTE

.data
message1 BYTE "請輸入字串處理選項(1)產生(2)複製(3)字元搜索(4)字串搜索(5)大小寫轉換(6)結束",0
message2 BYTE "1234567890",0
message3 BYTE 70 DUP(32),0
message4 BYTE 70 DUP(32),0
message5 BYTE "請輸入要搜索的字",0
message6 BYTE "沒找到...",0
message7 BYTE "搜索的字串在: ",0
message8 BYTE 11 DUP(0),0
message9 BYTE "請輸入要搜索的字串(最多10字): ",0
messageFail BYTE "錯誤! 請重新輸入......",0
blankln BYTE 80 DUP(32), 0
choice BYTE ?
nbyte DWORD ?
result DWORD ?

.code
main PROC
TOP:
	INVOKE SetCursor, 0, 0
	mov edx, offset message1
	call WriteString
	call ReadChar
	call Crlf
	.IF al < 49 || al > 54
		mov edx, offset messageFail
		call WriteString
		jmp TOP
	.ENDIF

	mov edx, offset blankln
	call WriteString 
	sub al,48
	mov choice, al
	.IF al == 6
		jmp FINISH
	.ELSEIF al == 5
		INVOKE CaseChange, ADDR message4
		mov dh, 19
		mov dl, 0
		call Gotoxy
		mov edx, offset message4
		call WriteString
	.ELSEIF al == 4
		INVOKE SetCursor, 0, 2
		mov edx, offset blankln
		call WriteString
		INVOKE SetCursor, 0, 2
		mov edx, offset message9
		call WriteString
		mov edx, offset message8
		mov ecx, SIZEOF message8
		call ReadString
		mov nbyte, eax
		INVOKE SearchString, ADDR message4, ADDR message8, nbyte
	.ELSEIF al == 3
		INVOKE SetCursor, 0, 2
		mov edx, offset message5
		call WriteString
		call ReadChar
		call Crlf
		INVOKE SetCursor, 0, 3
		mov edx, offset blankln
		call WriteString
		INVOKE SearchChar, ADDR message4, ADDR result, 70, al
		INVOKE SetCursor, 0, 2
		mov edx, offset blankln
		call WriteString
		.IF result > 70
			mov edx, offset message6
			call WriteString
		.ELSE
			mov edx, offset message7
			call WriteString
			mov eax, result
			inc eax
			call WriteDec
		.ENDIF
	.ELSEIF al == 2
		INVOKE CopyString, ADDR message3, ADDR message4, 70
	.ELSE
		INVOKE GenerateString
	.ENDIF
	jmp TOP

FINISH:
	call Crlf
	call WaitMsg
	INVOKE ExitProcess, 0
main ENDP


SetCursor proc uses edx, xpos:BYTE, ypos:BYTE
	mov dh, ypos
	mov dl, xpos
	call Gotoxy
	ret
SetCursor endp

GenerateString proc uses edx ecx esi eax
	mov dh, 20
	mov dl, 0
	call Gotoxy
	mov edx, offset message2
	mov ecx, 7
L0:
	call WriteString
	loop L0
	call Crlf
	mov esi, offset message3
	mov ecx, 70
	call Randomize
L1:
	mov eax, 60
	call RandomRange
	.IF eax < 26
		add al, 65
	.ELSEIF eax < 34
		mov al, 32
	.ELSE
		add al, 63
	.ENDIF
	mov [esi], al
	inc esi
	loop L1
	mov edx, offset message3
	call WriteString

	ret
GenerateString endp

CopyString proc uses esi edi ecx edx, source:PTR BYTE, destination:PTR BYTE, nchar:DWORD
	cld
	mov esi, source
	mov edi, destination
	mov ecx, nchar
	rep movsb
	mov dh, 19
	mov dl, 0
	call Gotoxy
	mov edx, destination
	call WriteString

	ret
CopyString endp

CaseChange Proc uses esi edi ecx eax, targetarray: PTR BYTE
	cld
	mov esi, targetarray
	mov edi, targetarray
	mov ecx, 70
CC1:
	lodsb
	.IF al >= 65 && al <= 90
		add al, 32
	.ELSEIF al >= 97 && al <= 122
		sub al, 32
	.ENDIF
	stosb
	loop CC1

	ret
CaseChange endp

SearchChar proc uses edi esi ecx eax, targetarray: PTR BYTE, found: PTR DWORD, nchar:DWORD, key:BYTE
	mov esi, found
	mov DWORD PTR [esi], 0FFFFFFFFh
	mov edi, targetarray
	mov ecx, nchar
	mov al, key
	cld
	repne scasb
	jnz QUIT
	dec edi
	sub edi, targetarray
	mov DWORD PTR [esi], edi
QUIT:
	ret
SearchChar endp

SearchString proc uses esi edi ecx ebx edx,
				targetarray:PTR BYTE, pattern:PTR BYTE, nchar:DWORD
				LOCAL temp1:DWORD, temp2:DWORD, tempaddr:DWORD
	INVOKE SetCursor, 0, 3
	mov edx, offset blankln
	call WriteString
	INVOKE SetCursor, 0 , 3
	cld
	mov temp2, 70
	mov esi, pattern
	mov edi, targetarray
SS3:
	INVOKE SearchChar, edi, ADDR temp1, temp2, BYTE PTR[esi]
	.IF temp1 > 70
		jmp SS2
	.ELSE
		mov ecx, nchar
		add edi, temp1
		mov tempaddr, edi
		mov ebx, temp1
		sub temp2, ebx
		repe cmpsb
		.IF ZERO?
			sub edi, targetarray
			mov edx, offset message7
			call WriteString
			mov eax, edi
			inc eax
			sub eax, nchar
			call WriteDec
			jmp SS1
		.ELSE
			mov edi, tempaddr
			inc edi
			dec temp2
			mov esi, pattern
			jmp SS3
		.ENDIF
	.ENDIF
SS2:
	mov edx, offset message6
	call WriteString
SS1:
	ret
SearchString endp
END main
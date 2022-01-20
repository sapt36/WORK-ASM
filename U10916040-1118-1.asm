; Program IDENTITY NUMBER (U10916040-.asm)
; Program Description: vertification and generation
; Author: Andrew Chen
; Creation Date: 01/06

.386
.model flat, stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc

.data
hHeap DWORD ?
dwByte DWORD ?
dwFlags DWORD HEAP_ZERO_MEMORY

progTitle BYTE "台灣身分證產生與驗證器", 0
optA BYTE "A) 產生隨機身分證號", 0
optB BYTE "B) 檢查身分證號是否合法", 0
optC BYTE "C) 結束", 0
selection BYTE "請輸入選擇： ", 0

generate BYTE "產生的身分證為： ", 0
vertify BYTE "請輸入你想檢查的身分證號： ", 0
wrongAlpha BYTE "無此縣市", 0
wrongGender BYTE "性別錯誤", 0
wrongNumber BYTE "數字錯誤", 0
wrongVerifyCode BYTE "不合法的身分證號", 0
correct BYTE "此身分證合法", 0

row BYTE 0
column BYTE 24
response BYTE ?
tmp BYTE ?
verifyCode WORD ?

geneID BYTE 11 DUP(?), 0
IDNum BYTE 10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 21, 22, 35, 23, 24, 27, 28, 29, 32, 30, 33
IDEng BYTE 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 
					'M', 'N', 'O', 'P', 'Q', 'T', 'U', 'V', 'W', 'X', 'Z'
numList BYTE '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
inputID BYTE 10 DUP(?), 0


.code
main PROC
	INVOKE GetProcessHeap
	mov hHeap, eax
	mov eax, white + (green * 16)
	call SetTextColor

ENTRYPOINT:
	call programMenu
	call getAndCallSelection
	cmp response, 'C'
	jne ENTRYPOINT

	call crlf
	call waitMsg

ENDOFPROGRAM:
	INVOKE ExitProcess, 0
main ENDP

addTwoColumn proc
	add row, 2
	mov dl, column
	mov dh, row
	call gotoxy
	ret
addTwoColumn endp

programMenu proc
	call Clrscr
	mov row, 0
	mov dl, 20
	mov dh, 0
	call gotoxy

	mov edx, OFFSET progTitle
	call writeString
	call addTwoColumn
	mov edx, OFFSET optA
	call WriteString
	call addTwoColumn
	mov edx, OFFSET optB
	call writeString
	call addTwoColumn
	mov edx, OFFSET optC
	call writeString
	ret
programMenu endp

getAndCallSelection proc
	mov dl, 0
	mov dh, 24
	call gotoxy
	mov edx, OFFSET selection
	call writeString
	call readChar
	mov response, al
	INVOKE Str_ucase, ADDR response
	mov al, 'A'
	mov ah, 'B'

	.IF (al == response)
		call generateID
		call waitMsg
	.ELSEIF (ah == response)
		call CheckID
		call waitMsg
	.ENDIF
	ret
getAndCallSelection endp

generateID proc
	call Clrscr
	mov edx, OFFSET generate
	call writeString
	call randomID
	call Crlf
	ret
generateID endp

randomID proc
	mov esi, OFFSET geneID
	call Randomize
	mov eax, 30
	call RandomRange
	mov bl, IDEng[eax]
	mov [esi], bl
	inc esi
	
	movzx bx, IDNum[eax]
	mov ax, bx
	mov bl, 10
	div bl
	mov bh, al
	mov al, ah
	mov bl, 9
	mul bl
	movzx bx, bh
	add ax, bx
	mov verifyCode, ax

	mov eax, 2
	call RandomRange
	inc eax
	mov bl, numList[eax]
	mov [esi], bl
	mov bl, 8
	mul bl
	mov bx, verifyCode
	add ax, bx
	mov verifyCode, ax
	inc esi

	mov ecx, 7
rID2:
	mov eax, 9
	call RandomRange
	mov bl, numList[eax]
	mov [esi], bl
	mov bl, cl
	mul bl
	mov bx, verifyCode
	add ax, bx
	mov verifyCode, ax
	inc esi
	loop rID2
	
	mov ax, verifyCode
	mov bx, 10
	div bl
	sub bl, ah
	movzx eax, bl
	mov bl, numList[eax]
	mov [esi], bl
	mov edx, OFFSET geneID
	call WriteString
	call crlf
	ret
randomID endp

checkID proc
	call Clrscr
	mov edx, OFFSET vertify
	call WriteString
	mov edx, OFFSET inputID
	mov ecx, SIZEOF inputID
	call ReadString
	mov esi, OFFSET inputID
	mov eax, [esi]
	mov edi, OFFSET IDEng
	mov esi, OFFSET IDNum
	mov ecx, 22
cID1:
	mov ebx, [edi]
	cmp al, bl
	je cFound
	inc edi
	inc esi
	loop cID1
	jmp AlphaError
cFound:
	mov al, [esi]
	mov ah, 0
	mov bl, 10
	div bl
	mov bh, al
	mov al, ah
	mov bl, 9
	mul bl
	movzx bx, bh
	add ax, bx
	mov verifyCode, ax

	mov esi, OFFSET inputID
	inc esi
	
	mov eax, [esi]
	.IF al == 31h || al == 32h
		sub al, 30h
	.ELSE
		jmp GenderError
	.ENDIF
	mov ah, 0
	mov bl, 8
	mul bl
	mov bx, verifyCode
	add ax, bx
	mov verifyCode, ax
	inc esi

	mov ecx, 7
NumCheck:
	mov eax, [esi]
	.IF al >= 30h && al <= 39h
		sub al, 30h
	.ELSE
		jmp NumberError
	.ENDIF
	mov ah, 0
	mov bl, cl
	mul bl
	mov bx, verifyCode
	add ax, bx
	mov verifyCode, ax
	inc esi
	loop NumCheck

	mov ax, verifyCode
	mov bx, 10
	div bl
	sub bl, ah
	add bl, 30h
	mov eax, [esi]
	cmp al, bl
	je CorrectID
	jmp VerifyError

AlphaError:
	mov edx, OFFSET wrongAlpha
	call WriteString
	call crlf
	jmp Quit

GenderError:
	mov edx, OFFSET wrongGender
	call WriteString
	call crlf
	jmp Quit

NumberError:
	mov edx, OFFSET wrongNumber
	call WriteString
	mov eax, 10
	sub eax, ecx
	call WriteDec
	call crlf
	jmp Quit

VerifyError:
	mov edx, OFFSET wrongVerifyCode
	call WriteString
	call crlf
	jmp Quit

CorrectID:
	mov edx, OFFSET correct
	call WriteString
	call crlf
	
Quit:
	ret
checkID endp
END main
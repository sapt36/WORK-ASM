.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitProcess:dword
INCLUDE Irvine32.inc
INCLUDE test.inc

STUDENT STRUCT
	id BYTE 9 DUP(?)
	stuname BYTE 6 DUP(?)
	address BYTE 6 DUP(?)
	score1 BYTE ?
	score2 BYTE ?
	score3 BYTE ?
	score4 BYTE ?
STUDENT ENDS
BUFFER_SIZE = 46

mWriteChar PROTO, source:PTR BYTE, count:DWORD
showrecord PROTO, point:PTR STUDENT
nrecordshow PROTO, point:PTR STUDENT, count:DWORD
findrecord PROTO, target:PTR STUDENT, nofstu:DWORD, pattern:PTR BYTE, nchar:DWORD, result:PTR DWORD
scoremean PROTO, target:PTR STUDENT, nofstu:DWORD, displacement:DWORD

.data
	buffer STUDENT BUFFER_SIZE DUP(<>)
	filename BYTE "testdata.txt", 0
	fileHandle HANDLE ?
	stucount DWORD ?
	found DWORD ?
	dest BYTE 10 DUP(0)
	destcount DWORD ?
	city BYTE 10 DUP(0)
	citycount DWORD ?
	tempaddr DWORD ?
.code

main proc
	mov edx, OFFSET filename
	call OpenInputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	jne file_ok
	mWriteLn "Cannot open file. "
	jmp quit

file_ok:
	mov edx, OFFSET buffer
	mov ecx, SIZEOF buffer
	call ReadFromFile
	jnc buf_read_ok
	mWriteLn "Error reading file. "
	jmp close_file

buf_read_ok:
	mWrite "File size: "
	call WriteDec
	mWrite " Bytes,		"
	mov edx, 0
	mov ebx, SIZEOF STUDENT
	div ebx
	mov stucount, eax
	call WriteDec
	mWrite " student's data input......"
	call Crlf

close_file:
	mov eax, fileHandle
	call CloseFile

MENU:
	call Crlf
	mWriteLn "(1)全部顯示 (2)成績統計 (3)姓名搜尋 (4)城市搜尋 (5)結束"
	mChoose 5
	call Crlf
	.IF al == 1
		INVOKE nrecordshow, ADDR buffer, BUFFER_SIZE
	.ELSEIF al == 2
		mWrite "score1 的"
		INVOKE scoremean, ADDR buffer, BUFFER_SIZE, OFFSET STUDENT.score1
		mWrite "score2 的"
		INVOKE scoremean, ADDR buffer, BUFFER_SIZE, OFFSET STUDENT.score2
		mWrite "score3 的"
		INVOKE scoremean, ADDR buffer, BUFFER_SIZE, OFFSET STUDENT.score3
		mWrite "score4 的"
		INVOKE scoremean, ADDR buffer, BUFFER_SIZE, OFFSET STUDENT.score4
	.ELSEIF al == 3
		mWrite "請輸入姓名:"
		mReadString dest
		mov destcount, eax
		call Crlf
		mov eax, OFFSET buffer
		add eax, OFFSET STUDENT.stuname
		INVOKE findrecord, eax, BUFFER_SIZE, ADDR dest, destcount, ADDR found
		mov ebx, found
		.IF ebx == 0FFFFFFFFh
			mWrite "沒找到"
		.ELSE
			mov eax, OFFSET buffer
			add eax, found
			INVOKE showrecord, eax
		.ENDIF
		call Crlf
	.ELSEIF al == 4
		mWrite "請輸入城市:"
		mReadString city
		mov citycount, eax
		call Crlf
		mov ebx, BUFFER_SIZE
		mov eax, OFFSET buffer
		mov tempaddr, eax
L0:
		add eax, OFFSET STUDENT.address
		INVOKE findrecord, eax, ebx, ADDR city, citycount, ADDR found
		mov edx, found
		.IF edx	!=	0FFFFFFFFh
			mov eax, tempaddr
			add eax, found
			add eax, SIZEOF STUDENT
			mov tempaddr, eax
			sub eax, SIZEOF STUDENT
			INVOKE showrecord, eax
			call Crlf
			mov ecx, SIZEOF STUDENT
			mov eax, found
			mov edx, 0
			div ecx
			inc eax
			sub ebx, eax
			jz MENU
			mov eax, tempaddr
			jmp L0
		.ELSEIF ebx == BUFFER_SIZE
			mWrite "沒找到"
		.ENDIF
		call Crlf
	.ELSE
		jmp quit
	.ENDIF
	jmp MENU

quit:
	call WaitMsg
	INVOKE ExitProcess, 0
main ENDP

scoremean PROC uses ecx edx eax ebx esi,
		target:PTR STUDENT, nofstu:DWORD, displacement:DWORD
	mov ecx, nofstu
	mov edx, 0
	mov eax, 0
	mov ebx, 0
	mov esi, target
	add esi, displacement
SM1:
	mov bl, BYTE PTR[esi]
	add eax, ebx
	add esi, SIZEOF STUDENT
	loop SM1
	mov ecx, nofstu
	div ecx
	mWrite "平均值:"
	call WriteDec
	mWriteSpace 3
	mov eax, edx
	mWrite "餘數:"
	call WriteDec
	call Crlf
	ret
scoremean endp

findrecord PROC uses esi edi ebx ecx edx,
		target:PTR STUDENT, nofstu:DWORD, pattern:PTR BYTE, nchar:DWORD, result:PTR DWORD
	cld
	mov esi, result
	mov DWORD PTR[esi], 0FFFFFFFFh
	mov edx, 0
	mov ebx, nofstu
FR1:
	mov esi, target
	add esi, edx
	mov edi, pattern
	mov ecx, nchar
	repe cmpsb
	jz MATCH
	add edx, SIZEOF STUDENT
	dec ebx
	jnz FR1
	jmp QUIT
MATCH:
	mov esi, result
	mov DWORD PTR[esi], edx
QUIT:
	ret
findrecord endp

nrecordshow proc uses ecx edi,
		point:PTR STUDENT, count:DWORD
	mov ecx, count
	mov edi, point
AA1:
	INVOKE showrecord, edi
	call Crlf
	add edi, SIZEOF STUDENT
	loop AA1
	ret
nrecordshow endp

showrecord proc uses edi,
	point:PTR STUDENT

	mov edi, point
	INVOKE mWriteChar, edi, SIZEOF STUDENT.id
	mWriteSpace 3
	add edi, SIZEOF STUDENT.id
	INVOKE mWriteChar, edi, SIZEOF STUDENT.stuname
	mWriteSpace 3
	add edi, SIZEOF STUDENT.stuname
	INVOKE mWriteChar, edi, SIZEOF STUDENT.address
	mWriteSpace 3
	add edi, SIZEOF STUDENT.address
	mov eax, 0
	mov al, BYTE PTR[edi]
	call WriteDec
	mWriteSpace 3
	inc edi
	mov al, BYTE PTR[edi]
	call WriteDec
	mWriteSpace 3
	inc edi
	mov al, BYTE PTR[edi]
	call WriteDec
	mWriteSpace 3
	inc edi
	mov al, BYTE PTR[edi]
	call WriteDec
	mWriteSpace 3

	ret
showrecord endp

mWriteChar proc uses esi edi ecx edx,
		source:PTR BYTE, count:DWORD

.data
	spaces BYTE 10 DUP(0)
.code
	cld
	mov edi, OFFSET spaces
	mov ecx, 10
	mov al, 0
	rep stosb
	mov esi, source
	mov edi, OFFSET spaces
	mov ecx, count
	rep movsb
	mov edx, OFFSET spaces
	call WriteString
	ret
mWriteChar endp
end main
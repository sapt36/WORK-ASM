INCLUDE test.inc
.code
Binomialcoefficient PROC, nval:DWORD
					local temp:DWORD
	.IF nval == 0
		mov dh,0
		mov dl,48
		call Gotoxy
		mov eax,1
		call WriteDec
	.ELSE 
		mov dh,BytE PTR nval
		mov al,2
		mul dh
		mov dl,48
		sub dl,al
		call Gotoxy
		mov ecx,nval
		inc ecx
		mov edx,0
BL0:
	mov temp,0
	INVOKE Combination, nval,edx, ADDR temp
	mov eax,temp
	call WriteDec
	mov al,' '
	call WriteChar
	inc edx
	loop BL0
	.ENDIF
	ret
	Binomialcoefficient ENDP
	end

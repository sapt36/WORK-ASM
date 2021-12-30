INCLUDE test.inc
.code
Combination PROC uses esi ebx, nval1:DWORD, nval2:DWORD, result:PTR DWORD
	mov esi,result
	mov ebx,nval1
	.IF (ebx == nval2) || (nval2 == 0)
		add DWORD PTR [esi],1
	.ELSE
		dec nval1
		INVOKE Combination, nval1,nval2,esi
		dec nval2
		INVOKE Combination, nval1,nval2,esi
	.ENDIF
	ret
Combination ENDP
end
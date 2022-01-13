.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
INCLUDE Irvine32.inc
ID_MAX = 10
LASTNAME_MAX = 20
TRUE = 1
FALSE = 0

CUSTOMER STRUCT
 idNum BYTE ID_MAX DUP(0)
 lastNam BYTE LASTNAME_MAX DUP(0)
 nextNod DWORD 0
CUSTOMER ENDS

sumOfEntryFields = (SIZEOF customer.lastNam + SIZEOF customer.idNum)

.data
 hHeap DWORD ?
 dwBytes DWORD ?
 dwFlags DWORD HEAP_ZERO_MEMORY
 progTitle BYTE "DYNAMIC MEMORY ALLOCATION VIA API CALLS", 0
 optA BYTE "A) DISPLAY CURRENT LIST OF CUSTOMERS", 0
 optB BYTE "B) SEARCH CUSTOMER", 0
 optC BYTE "C) ADD NEW CUSTOMER", 0
 optD BYTE "D) UPDATE CURRENT CUSTOMER", 0
 optE BYTE "E) DELETE EXISTING CUSTOMER", 0
 optF BYTE "F) EXIT PROGRAM", 0
 selection BYTE "PLEASE ENTER YOUR DESIRED SELECTION: ", 0
 newCustTitle BYTE " --- ENTER A NEW CUSTOMER --- ", 0
 createNodMsg BYTE "DO YOU WANT TO ENTER A NEW CUSTOMER ? Y/N: ", 0
 custIdMsg BYTE "ENTER THE CUST ID: ", 0
 custLastMsg BYTE "ENTER THE LAST NAME OF CUSTOMER: ", 0
 displayNothing BYTE " --- THERE ARE NO CUSTOMERS IN MEMORY ---", 0
 titleMsg BYTE " ---- LINK LIST CONTENTS ----", 0
 custIdInfo BYTE "CUSTOMER ID: ", 0
 custLNameInfo BYTE "CUSTOMER LAST NAME: ", 0
 spacer BYTE "-------------------------------", 0
 custSearchMsg BYTE " --- CUSTOMER SEARCH --- ", 0
 getSearchId BYTE "PLEASE ENTER THE CUST ID TO DISPLAY: ", 0
 foundMsg BYTE " --- CUSTOMER FOUND ---", 0
 deletedMsg BYTE " --- AND REMOVED ---", 0
 notFoundMsg BYTE " !!!! CUSTOMER NOT FOUND !!!!", 0
 newInfoMsg BYTE " --- NEW CUSTOMER INFO ---", 0
 custUpdtMsg BYTE " --- CUSTOMER SUCCESFULLY UPDATED --- ", 0
 row BYTE 0
 column BYTE 24
 idNumber BYTE (ID_MAX + 1) DUP(0)
 lastName BYTE (LASTNAME_MAX + 1) DUP(0)
 response BYTE ?
 searchId BYTE (ID_MAX) DUP(0)
 head DWORD 0
 tail DWORD 0
 currNod DWORD 0
 prevNod DWORD 0
 nextNod DWORD 0
 foundVar BYTE FALSE
 thisCust CUSTOMER{}
.code

main PROC
 INVOKE GetProcessHeap
 mov hHeap, eax
 mov dwBytes, SIZEOF customer
 mov eax, yellow + (blue * 16)
 call SetTextColor
ENTRYPOINT :
 call programMenu
 call getAndCallSelection
 cmp response, 'F'
 jne ENTRYPOINT
 call crlf
 call waitMsg
ENDOFPROGRAM :
 exit
main ENDP

addTwoColumn PROC
 add row, 2
 mov dl, column
 mov dh, row
 call gotoxy

 ret
addTwoColumn ENDP

programMenu PROC
 call Clrscr
 mov row, 0
 mov dl, 20
 mov dh, 0
 call Gotoxy
 mov edx, OFFSET progTitle
 call writeString
 call addTwoColumn
 mov edx, OFFSET optA
 call writeString
 call addTwoColumn
 mov edx, OFFSET optB
 call writeString
 call addTwoColumn
 mov edx, OFFSET optC
 call writeString
 call addTwoColumn
 mov edx, OFFSET optD
 call writeString
 call addTwoColumn
 mov edx, OFFSET optE
 call writeString
 call addTwoColumn
 mov edx, OFFSET optF
 call writeString

 ret
programMenu ENDP

getAndCallSelection PROC
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
 mov bl, 'C'
 mov bh, 'D'
 mov cl, 'E'
 .IF(al == response)
  call showContents
 .ELSEIF(ah == response)
  call getSearch
  call waitMsg
 .ELSEIF(bl == response)
  call getData
  call moveToList
  call waitMsg
 .ELSEIF(bh == response)
  call getSearch
  .IF(foundVar == 1)
   call deleteNode
   call getData
   call moveToList
  .ENDIF
  call waitMsg
 .ELSEIF(cl == response)
  call getSearch
  .IF(foundVar == 1)
   call deleteNode
  .ENDIF
  call waitMsg
 .ENDIF

 ret
getAndCallSelection ENDP

showContents PROC
 mov edi, head
 mov ebx, 00h
 call Clrscr
 mov edx, OFFSET titleMsg
 call writeString
 call Crlf
 call Crlf
DISPLAYSTART :
 cmp edi, ebx
 je NOMORE
 call displayCustomer
 add edi, SIZEOF thisCust.lastNam
 mov edi, [edi]
 JMP DISPLAYSTART
NOMORE :
 call waitMsg
 
 ret
showContents ENDP

displayCustomer PROC
 call Crlf
 mov edx, OFFSET custIdInfo
 call writeString
 mov edx, edi
 call writeString
 call Crlf
 mov edx, OFFSET custLNameInfo
 call writeString
 add edi, SIZEOF thisCust.IdNum
 mov edx, edi
 call writeString
 call Crlf
 mov edx, OFFSET spacer
 call writeString
 call Crlf

 ret
displayCustomer ENDP

getData PROC
 INVOKE heapAlloc, hHeap, dwFlags, dwBytes
 mov currNod, eax
 call Clrscr
 mov edx, OFFSET newCustTitle
 call writeString
 call Crlf
 call Crlf
 mov edx, OFFSET custIdMsg
 call writeString
 mov edx, OFFSET thisCust.idNum
 mov ecx, ID_MAX
 call readString
 mov ecx, eax
 mov edi, OFFSET thisCust.idNum
 call NumberStringShift
 mov edi, currNod
 INVOKE Str_copy, ADDR thisCust.idNum, edi
 add edi, SIZEOF thisCust.idNum
 mov edx, OFFSET custLastMsg
 call writeString
 mov edx, OFFSET thisCust.lastNam
 mov ecx, LASTNAME_MAX
 call readString
 INVOKE Str_copy, ADDR thisCust.lastNam, edi
 add edi, SIZEOF thisCust.lastNam
 mov esi,0
 call esitomem4b

 ret
getData ENDP

NumberStringShift PROC
 mov esi, edi
 add edi, 8
 dec esi
 add esi, eax
movebackward :
 mov al, [esi]
 mov [edi], al
 dec esi
 dec edi
 loop movebackward
emptyfill :
 mov BYTE PTR[edi], 30h
 dec edi
 cmp edi, esi
 jne emptyfill

 ret
NumberStringShift ENDP

moveToList PROC
 .IF(head == 0)
  mov edi, currNod
  mov head, edi
  mov tail, edi
 .ELSE
  mov prevNod, 0
  mov edi, head
  mov nextNod, edi
VERIFY:
  .IF(nextNod == 0)
   jmp PLACEFOUND
  .ELSE
   INVOKE Str_compare, nextNod, currNod
   jg PLACEFOUND
  .ENDIF
  mov edi, nextNod
  mov prevNod, edi
  add edi, sumOfEntryFields
  mov edi, [edi]
  mov nextNod, edi
  jmp VERIFY
PLACEFOUND:
  .IF(nextNod == 0)
   mov esi, 0
   mov edi, currNod
   add edi, sumOfEntryFields
   call esitomem4b
   mov esi, currNod
   mov tail, esi
  .ELSE
   mov esi, nextNod
   mov edi, currNod
   add edi, sumOfEntryFields
   call esitomem4b
  .ENDIF
  mov esi, currNod
  .IF(prevNod == 0)
   mov head, esi
  .ELSE
   mov edi, prevNod
   add edi, sumOfEntryFields
   call esitomem4b
  .ENDIF
 .ENDIF

 ret
moveToList ENDP

esitomem4b PROC
 mov ecx, 4
 mov eax, esi
anothermove :
 mov BYTE PTR[edi], al
 shr eax, 8
 inc edi
 loop anothermove

 ret
esitomem4b ENDP

getSearch PROC
 call ClrScr
 mov ebx, 00h
 mov edi, head
 cmp head, ebx
 je NOTHING
 mov edx, OFFSET custSearchMsg
 call WriteString
 call Crlf
 mov edx, OFFSET getSearchId
 call writeString
 mov edx, OFFSET searchId
 mov ecx, ID_MAX
 call readString
 mov ecx, eax
 mov edi, OFFSET searchId
 call NumberStringShift
 call searchList
 jmp endproc
NOTHING :
 mov foundVar, FALSE
 mov edx, OFFSET displayNothing
 call writeString
ENDPROC :
 call crlf

 ret
getSearch ENDP

searchList PROC
 call ClrScr
 mov edi, head
 mov prevNod, 0
 mov ebx, 00h
SEARCHLOOP :
 INVOKE Str_compare, ADDR searchId, edi
 je FOUND
 mov prevNod, edi
 add edi, sumOfEntryFields
 mov edi, [edi]
 cmp edi, ebx
 je NOTFOUND
 jmp SEARCHLOOP
FOUND :
 mov currNod, edi
 mov foundVar, TRUE
 call Crlf
 mov edx, OFFSET foundMsg
 call writeString
 call displayCustomer
 jmp AWAYWITHYOU
NOTFOUND :
 mov foundVar, FALSE
 call Crlf
 mov edx, OFFSET notFoundMsg
 call writeString
 call Crlf
AWAYWITHYOU :
 ret

searchList ENDP

deleteNode PROC
 mov edi, currNod
 add edi, sumOfEntryFields
 mov eax, [edi]
 mov nextNod, eax
 mov edi, currNod
 .IF (edi == head)
  mov head, eax
 .ELSE
  mov edi, prevNod
  add edi, sumOfEntryFields
  mov esi, eax
  call esitomem4b
 .ENDIF
 mov edi, currNod
 .IF (edi == tail)
  mov esi, prevNod
  mov tail, esi
 .ENDIF
 mov edi, currNod
 INVOKE heapFree, hHeap, dwFlags, edi
 call Crlf
 mov edx, OFFSET deletedMsg
 call writeString
 call Crlf
 
 ret
deleteNode ENDP
end main
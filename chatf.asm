assume CS:Code_segment_name,DS:Data_segment_name

Main1 proc far
	mov [sendDOffset],0
	mov [sendDnum],0 ;start from 0
	mov [rowRec],0
	mov [colRec],0 
	call far ptr clearscreen
	call far ptr linee
	call far ptr initialization
	again:
		call far ptr setCurser
		call far ptr getKeyPressed
		call far ptr Recieve
		cmp esqq,1
		je exit
	jmp again
	exit:
	mov [esqq],0
	retf
Main1 endp

clearscreen proc far    
	mov ah,6       
	mov al,0        
	mov bh,7       
	mov ch,0       
	mov cl,0        
	mov dh,24    
	mov dl,79     
	int 10h
	retf
clearscreen endp
	
linee proc far
	mov cx,80
	mov ax,0b800h
	mov es,ax
	mov di,20*160
	drawLine:
		lea si,split
		movsw
	loop drawLine
	retf
linee endp
	
setCurser proc far ;Typing Cursor
	 mov AH, 02h
	 mov bh,0
	 mov DH,[rowType] ;y
	 mov DL,[colType] ;x  
	 int 10h 
	retf
setCurser endp
	
moveCurserType proc far
	inc [colType]
	cmp [colType],80 ;if column reach more than 79 we inc row
	je cmpRowT
	jmp retfFromMoveCurserT
	
	incRowT:
	mov [colType],0
	inc [rowType]
	jmp retfFromMoveCurserT
	
	cmpRowT:
	cmp [rowType],24
	jne incRowT
	
	mov [rowType],24
	mov [colType],0
	call far ptr scrollUpTyping

	retfFromMoveCurserT:
	retf
moveCurserType	endp

moveCurserTypeBack proc far ;Move typing cursor
	cmp [colType],0 ;if column is not zero we dec col and retfurn
	je cmpRowTB ;else we continue
	dec [colType]
	jmp retfFromMoveCurserTB
	
	decRowTB:
	mov [colType],79
	dec [rowType]
	jmp retfFromMoveCurserTB
	
	cmpRowTB:
	cmp [rowType],21 ;if we are on the first line we do nothing
	jne decRowTB ;else we dec the row
	
	mov [rowType],21
	mov [colType],0

	retfFromMoveCurserTB:
	retf
moveCurserTypeBack	endp

setCurserRec proc far ;Recieving Cursor
	 mov AH, 02h
	 mov bh,0
	 mov DH,[rowRec] ;y
	 mov DL,[colRec] ;x  
	 int 10h 
	retf
setCurserRec endp

moveCurserRecieve proc far
	inc [colRec]
	cmp [colRec],80 ;if column reach more than 79 we inc row
	je cmpRowR
	jmp retfFromMoveCurserR
	
	incRowR:
	mov [colRec],0
	inc [rowRec]
	jmp retfFromMoveCurserR
	
	cmpRowR:
	cmp [rowRec],19
	jne incRowR
	
	mov [rowRec],19
	mov [colRec],0
	call far ptr scrollRecHalf

	retfFromMoveCurserR:
	retf
moveCurserRecieve endp

movCurRecNextLine proc far
	cmp [rowRec],19
	jne incRowRN ;increment row recieve new line
	
	mov [rowRec], 19
	mov [colRec], 0
	call far ptr scrollRecHalf
	jmp retfFromMovCurNL
	
	incRowRN:
	inc [rowRec]
	mov [colRec],0
	
	retfFromMovCurNL:
	retf
movCurRecNextLine endp

print proc far
	mov bh,0
	mov bl,07h
	mov cx,1
	mov ah,9
	int 10h 
	retf
print endp

clearAllData proc far
	mov [sendDOffset],0 ;reset offset and SendNum
	mov [sendDnum],0
	
	mov ax,Data_segment_name ;clear the SD's
	mov es,ax
	lea di,sendD1
	mov ax,0 ; stosw .. ax -> es:di
	mov cx, 60*5 ;(120/2)*5 (Word not byte)
	rep stosw
	retf
clearAllData endp

clearTypingAreaAndRestingCusror proc far
	mov ah,6       ;clear Typing Area
	mov al,0
	mov bh,7
	mov ch,21
	mov cl,0
	mov dh,24
	mov dl,79
	int 10h
	
	mov [rowType],21 ;setting cursor to start from beginning
	mov [colType],0

	retf
clearTypingAreaAndRestingCusror endp

printYou proc far
	lea dx,chatMe
	mov ah,09
	int 21h
	;Printing you doesn't move the cursor
	add [colRec],5
	retf
printYou endp

getKeyPressed proc far
	mov ah,1
	int 16h
	jz retfFromKeyPress
	
	mov ah,0 ;read input
	int 16h ;char in al
	cmp al,1bh ;escape key to terminate
	je EscapeKey
	cmp al,08 ;backspace key
	je BackSpace
	cmp al,13 ;EnterKey
	jne continuePrintingChars
		cmp [sendDnum],0
		je ok
		ok:
		cmp [sendDOffset],0
		je leav
		call far ptr Send
		call movCurRecNextLine
		call far ptr  clearTypingAreaAndRestingCusror
		leav:
		jmp retfFromKeyPress
	
	EscapeKey: ;Send Escape terminates the program so no need to jump to retfurn after it
		call far ptr  SendEscape
		mov [esqq],1
	ret
	continuePrintingChars: ;else (enter not pressed we continue)
	cmp [sendDnum],5
	je retfFromKeyPress
	cmp [sendDOffset],120 ;if offset not 120 we check we are in which seg and continue
	jne checkWhichSeg
	mov [sendDOffset],0 ;else (we are 120) we set offset to zero and increment the segNum
	inc [sendDnum]
	cmp [sendDnum],5 ;if num is 5 we are out of range so we take no more input
	je retfFromKeyPress
	
	checkWhichSeg:
	cmp [sendDnum],0
	je fill1
	cmp [sendDnum],1
	je fill2
	cmp [sendDnum],2
	je fill3
	cmp [sendDnum],3
	je fill4Out
	cmp [sendDnum],4
	je fill5Out
	
	jmp continueCode ;because out of range issue
	retfFromKeyPress:
	jmp retfFromKeyPress2
	
	BackSpace:
	mov al,' '
	cmp [sendDOffset],0 ;check the offset
	jne checkWhichSegB ;if offset is not zero (We check which seg to remove from)
	cmp [sendDnum],0 ;else .. we check the seg if it is zero w retf 
	jz retfFromKeyPress2
	dec[sendDnum]	;else we dec sendDnum and make offset 119
	mov [sendDOffset],120
	
	checkWhichSegB:
	cmp [sendDnum],0
	je remove1Out
	cmp [sendDnum],1
	je remove2Out
	cmp [sendDnum],2
	je remove3Out
	cmp [sendDnum],3
	je remove4Out
	cmp [sendDnum],4
	je remove5Out
	
	fill4Out:
	jmp fill4
	fill5Out:
	jmp fill5

	continueCode:
	fill1:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD1[bx],al
	inc [sendDOffset]
	jmp printAndMoveForward
	
	fill2:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD2[bx],al
	inc [sendDOffset]
	jmp printAndMoveForward
	
	fill3:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD3[bx],al
	inc [sendDOffset]
	jmp printAndMoveForward
	
	fill4:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD4[bx],al
	inc [sendDOffset]
	jmp printAndMoveForward
	
	jmp continueCode2 ;because out of range issue AGAIN
	retfFromKeyPress2:
	jmp retfFromKeyPress3
	remove1Out:
	jmp remove1
	remove2Out:
	jmp remove2
	remove3Out:
	jmp remove3
	remove4Out:
	jmp remove4
	remove5Out:
	jmp remove5

	fill5:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD5[bx],al
	inc [sendDOffset]
	jmp printAndMoveForward
	
	continueCode2:
	remove1:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD1[bx],al
	dec [sendDOffset]
	jmp printAndMoveBackward
	
	remove2:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD2[bx],al
	dec [sendDOffset]
	jmp printAndMoveBackward
	
	remove3:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD3[bx],al
	dec [sendDOffset]
	jmp printAndMoveBackward
	
	remove4:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD4[bx],al
	dec [sendDOffset]
	jmp printAndMoveBackward
	
	remove5:
	mov bh,0
	mov bl,[sendDOffset]
	mov sendD5[bx],al
	dec [sendDOffset]
	jmp printAndMoveBackward
	
	jmp continueCode3 ;because out of range issue even AGAIN
	retfFromKeyPress3:
	jmp retfFromGetKeyPressed
	continueCode3:
	
	
	printAndMoveForward:
	call print
	call moveCurserType
	jmp retfFromGetKeyPressed
	
	printAndMoveBackward:
	call moveCurserTypeBack
	call setCurser
	call print

	retfFromGetKeyPressed:
	retf
getKeyPressed endp

	
scrollRecHalf proc far ;scroll Chat(Recieving) Half
	mov ah,6 ; function 6
	mov al,1 ; scroll by 1 line
	mov bh,7 ; normal video attribute
	mov ch,0 ; upper left Y
	mov cl,0 ; upper left X
	mov dh,19 ; lower right Y
	mov dl,79 ; lower right X
	int 10h
	retf
scrollRecHalf endp
	
scrollUpTyping proc far ;Scroll the half where you type
	mov ah,6 ; function 6
	mov al,1 ; scroll by 1 line
	mov bh,7 ; normal video attribute
	mov ch,21 ; upper left Y
	mov cl,0 ; upper left X
	mov dh,24 ; lower right Y
	mov dl,79 ; lower right X
	int 10h
	retf
scrollUpTyping endp
	
scrollDownTyping proc far ;Scroll the half where you type
	mov ah,7 ; function 7
	mov al,1 ; scroll by 1 line
	mov bh,7 ; normal video attribute
	mov ch,21 ; upper left Y
	mov cl,0 ; upper left X
	mov dh,24 ; lower right Y
	mov dl,79 ; lower right X
	int 10h
	retf
scrollDownTyping endp
	
	;Serial Procs
initialization proc far
	mov dx,3fbh
	mov al,80h
	out dx,al
	mov al,0ch
	mov dx,3f8h
	out dx,al
	mov al,0h
	mov dx,3f9h
	out dx,al
	mov dx,3fbh
	mov al,00011011b ;???
	out dx,al
	retf
initialization endp

Send proc far
	;Algorithm 
		;count total number of char that will be sent (loop count)
		;check if we can send THRE [Transmit hold register empty] 
		;send the n-characters only -- (while sending print them on my screen)
		;clear the sendD(s)
		
	call setCurserRec
	call printYou
	
	;Before calculating or sending all data we send "Other Player: " message
	mov ch,0
	mov cl,HostName[1] ;14 for "Other Player: "
	mov bx,2
	SendOtherPlayer:
		CheckSent:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
		jz CheckSent  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		
		mov al,HostName[bx]
		Out dx,al
		inc bx
	loop SendOtherPlayer
	
	;Send ': '
	mov cx,2
	mov bx,0
	SendOther:
		CheckSentS:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
		jz CheckSentS  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		
		mov al,chatOther[bx]
		Out dx,al
		inc bx
	loop SendOther

	
	mov bh,0
	mov bl,120 ;calculate the loop count ... SendDnum * 120 + offset
	mov ah,0
	mov al,[sendDnum]
	mul bl
	mov bl,[sendDOffset]
	add ax,bx
	mov cx,ax
	
	mov [sendDOffsetSend],0 ;index (similar to the offset)
	mov [sendDnumSend],0 ;similar to sendDnum
	;push dx
	
	
	SendAllData:
		CheckSend:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
		jz CheckSend  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		
		;pop dx
		cmp [sendDOffsetSend],120 ;if offset is 120 then reset it
		jne checkWhichDX ;if it is not equal 120 we check which seg we take from
		mov [sendDOffsetSend],0
		inc [sendDnumSend]
		
		checkWhichDX:
		mov bh,0
		mov bl,[sendDOffsetSend]
		cmp [sendDnumSend],0
		je takeFrom1
		cmp [sendDnumSend],1
		je takeFrom2
		cmp [sendDnumSend],2
		je takeFrom3
		cmp [sendDnumSend],3
		je takeFrom4
		cmp [sendDnumSend],4
		je takeFrom5
		
		takeFrom1:
		mov al,sendD1[bx] ;move the data read from the user to THR
		jmp WriteToPort
		takeFrom2:
		mov al,sendD2[bx]
		jmp WriteToPort
		takeFrom3:
		mov al,sendD3[bx]
		jmp WriteToPort
		takeFrom4:
		mov al,sendD4[bx]
		jmp WriteToPort
		takeFrom5:
		mov al,sendD5[bx]
		WriteToPort:
		Out dx,al
		inc [sendDOffsetSend]
		push ax
		push bx
		push cx
		call print
		call moveCurserRecieve
		call setCurserRec
		pop cx
		pop bx
		pop ax
	loop SendAllData
	;pop dx
	;after the loop end .. we send enter key (ascii is 13)
	SendEnter:
	mov dx,3FDh   ;Read the line status register`
	In al,dx
	test al,20h   ;test the THRE [Transmit hold register empty] 
	jz SendEnter  ; if THRE=0 then loop until it = 1 [until the old data is sent]
	mov dx,3F8h
	mov al,13
	Out dx,al
	call clearAllData
	retf
Send endp

SendEscape proc far
		CheckEscSend:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] ;5th bit
		jz CheckEscSend  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		mov al,1bh ;send Escape Key
		Out dx,al
	retf
SendEscape endp

Recieve proc far
	;Algorithm
		;check if there is something to recieve
		;take it and print it on the screen
	mov dx,3FDh        ;Line status register
	In al,dx
	test al,00000001b ; Test if DR=1
	jz retfFromRecieve             ;Jump if zero [DR=0] No data is ready to be picked up
	mov dx,3F8h       ;Read data from Recieve buffer [3F8] into AL    
	In al,dx
	cmp al,1bh ;escape key
	jne cont
	mov [esqq],1
	ret
	cont:
	call setCurserRec
	cmp al,13 ;Enter Key
	jne newLine
	call movCurRecNextLine
	jmp retfFromRecieve
	newLine:
	call print
	call moveCurserRecieve
	retfFromRecieve:
	retf
Recieve endp


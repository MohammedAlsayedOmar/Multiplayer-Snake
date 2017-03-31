Data_segment_name segment para
    apple db 0
	applerow db 0
	applecol db 0
	appleMilSec db 0
	;Snake1
	oScore dw 0,'$'
	remoscore dw 0,'$'
	oHead  db 'o'
	oAttribute db 06h
	oRowBody db 12 dup (?)
	oColBody db 12 dup (?)
	oRowHead db 10,'$'
	oColHead db 20,'$'
	oDirection db 2 ;1 up 2 right 3 down 4 left
	oState db 0 ;0 Alive , 1 deads
	oTrow db ? ;tail row and column
	oTcol db ?
	oCount db 2 ;(start count from zero)
	oHost db 1 ;(0 not host, 1 host)
	oSend db 2 ;the thing to send to the other pc
    oHeadPrevRow  db ?
	oHeadPrevCol   db ?
	;Snake2
	zScore dw 0,'$'
	zHead db 'o'
	zAttribute db 04h
	zRowBody db 12 dup (?)
	zColBody db 12 dup (?)
	zRowHead db 10,'$'
	zColHead db 60,'$'
	zDirection db 4 ;(1 up) (2 right) (3 down) (4 left)
	zState db 0;0 Alive , 1 dead
	zTrow db ?
	zTcol db ?
	zCount db 2
	zSend db 4 ;the thing to send to the other pc
	zHeadPrevRow  db ?
	zHeadPrevCol   db ?
	selectgamemode  db ' Select game mode (1-Increase length ,2-Increase speed) $'
	winMsg db 'You Win!$'
	loseMsg db 'You Lose!$'
	drawMsg db 'DRAW! better luck next time$'
	;------------------------------;
	delaytime dw 6
	index dw  0
	split db '-',07
	gamemode  db  1 ; 1 increase length  ,0 increase speed
  ;---------------------------------------------
    HostName db 16 dup(?)
	GuestName db 16 dup(?) 
	Scorestate  db 'Score:($'
	endbrackn    db '):$'
	endbrack1    db ')$'
	slash       db '/$'
	openbrack   db  '($'
	comma       db   ',$'
	right       db ':Right$'
	left        db ':Left$'
	up          db ':Up$'
	down        db ':Down$'
	inMain     db   1 ;1 if main .. 0 nothing else
	roww  db ?
	coll  db ?
	beg  db " Please enter your name (Max 15 charcters):     $"
	beg1 db " Please enter your name to start the program    $"
	ent  db " Please any key to continue $"
	fun1 db "   Chat.       Press F1 $"
	fun2 db "   Play.       Press F2 $"
	fun3 db "   Design Map. Press F3 $"
	fun4 db "   Exit.       Press Esq $"
	fun5 db '   is designing a map     $'
	emp db "       "
	menuedge1  db '* * * * * * * * * * * * * *$'
	menuedge2  db '* $'
	colm       db 26
	rowm       db 6
	colms      db 27
	rowms      db 7
	selectmap  db    ' Select Map  [1,2,3]:  $'
	hostselecting db ' is selecting a map $'
	key db ?
	namecounter db ?
	playername db ?
	line db '-',05
	;;;;;
	HostGameMessage db "You sent a GAME invitation $"
	HostChatMessage db "You sent a CHAT invitation $"
	HostRejectMessage db "  didn't accept your invitation $"
	GuestChatMessage db " sent you a CHAT invitation,To accept press F1, To reject press N $"
	GuestGameMessage db " sent you a GAME invitation,To accept press F1, To reject press N $"
	GuestRejectMessage db "You refused the invitation $"
	GuestDesign db ' sent you a chat invitation,To accept go back to main menu $'
	Sentdata db ?
	tt dw ?
;-------------------------------------------MUSGI-------------------------------------
    obstcales  db 50d
    row    dw (10)
    col    dw (37)  
    obst   db 'Remaining Obstacles : $'
    mode   db 0            ;1  creat  , 0 Do nothing , 2 save   ,3 load 
    fileHandle DW ?
	map DB 1680 DUP (30h)
    map0 db  '0'
    map1 db  '1'	
	filename1  DB '1.txt', 0
	filename2  DB '2.txt', 0
	filename3  DB '3.txt', 0
	saveload1  DB 's1.txt',0
	saveload2  DB 's2.txt',0
	saveload3  DB 's3.txt',0
	savestate db  'Save to(1,2,3):$'
	loadstate db  'Load from(1,2,3):$'
	clear     db  '                 $'
	base dw 0   ;saving index
	err  db   'DID NOT OPEN FILE$'
	errR db   'DID NOT READ$'
	temp dw 0 ;loading index
	rowp dw 0
	colp dw 0
;-------------------------------------------MICKY-------------------------------------
	esqq  db  0        ; if esq pressed
	chatMe db 'You: $'
	chatOther db ': '
	rowType db 21;row when typing
	colType db 0 ;col when typing
	rowRec db 0  ;row when recieving
	colRec db 0  ;col when recieving
	sendDOffset db ? ; will hold the offset from 0 to 119
	sendDnum db ? ;will hold i am in which data (0,1,2,3,4)
	sendDOffsetSend db ? ;index for sending data
	sendDnumSend db ?
	sendD1 db 120 dup (?) ;Total of 7 lines and a half
	sendD2 db 120 dup (?)
	sendD3 db 120 dup (?)
	sendD4 db 120 dup (?)
	sendD5 db 120 dup (?)
Data_segment_name ends

Stack_segment_name segment para stack

Stack_segment_name ends

Code_segment_name segment
include chatf.asm
include map.asm
include host.asm
include snake1.asm
Main_prog proc far
assume SS:Stack_segment_name,CS:Code_segment_name,DS:Data_segment_name

mov AX,Data_segment_name 
mov DS,AX 
	call clearscreen1
	call buffer
	call clearscreen1
	call creatstartingmenu
;------------print lines
	 ;call far ptr drawLine1 
	 call initialization1
	 call SendRecieveNames
	  loop11:
	 call Checksend1
	 call CheckRecieve 
	 jmp loop11
	
	mov ax,4c00h ; exitmm program
	int 21h
Main_prog      endp

	creatstartingmenu proc near
     mov ah,02h
	 mov bh,0
	 mov dh,rowm ;y
	 mov dl,colm ;x  
	 int 10h 
     lea dx,menuedge1
	 mov ah,09h
     int 21h
	
	 mov ah,02h
	 mov bh,0
	 add rowm,11
	 mov dh,rowm ;y
	 mov dl,colm ;x  
	 int 10h 
     lea dx,menuedge1
	 mov ah,09h
     int 21h
	 
	 sub rowm,11
	 mov cx,10
	 lol:
	 mov ah,02h
	 mov bh,0
	 inc rowm
	 mov dh,rowm ;y
	 mov dl,colm ;x  
	 int 10h 
     lea dx,menuedge2
	 mov ah,09h
     int 21h
	loop lol
	
	mov cx,10
	add colm,26
	lol1:
	 mov ah,02h
	 mov bh,0
	 mov dh,rowm ;y
	 mov dl,colm ;x  
	 int 10h 
     lea dx,menuedge2
	 mov ah,09h
     int 21h
	 dec rowm
	loop lol1
	
	 mov ah,02h
	 mov bh,0
	 mov dh,rowms ;y
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun1
	 mov ah,09h
     int 21h
	 
	 mov ah,02h
	 mov bh,0
	 add rowms,3
	 mov dh,rowms ;y
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun2
	 mov ah,09h
     int 21h
	 
	 mov ah,02h
	 mov bh,0
	 add rowms,3
	 mov dh,rowms ;y
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun3
	 mov ah,09h
     int 21h
	 
	 mov ah,02h
	 mov bh,0
	 add rowms,3
	 mov dh,rowms ;y
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun4
	 mov ah,09h
     int 21h
	 
	 mov colm,26
	 mov rowm,6
	 mov colms,27
	 mov rowms,7
	 ret
   creatstartingmenu endp
	;;;;;;;;;;;;;;;;;;;;
SendRecieveNames proc
	mov bx,00
	mov cx,16
	karrar:
	mov dl,[HostName[bx]]
	mov [Sentdata],dl
	call  far ptr send1
	mov [Sentdata],00
	call RecName
	mov dl,[Sentdata]
	mov [GuestName[bx]],dl
	inc bx
	loop karrar
ret
SendRecieveNames endp

RecName proc
		bye111:
		mov dx,03FDh
		in al,dx
		test al,1
		jz bye111;----------------------------------
		mov dx,03f8h
		in al,dx
		mov [Sentdata],al
		ret
RecName endp 

Recieve1 proc far
		mov dx,03FDh
		in al,dx
		test al,1
		jz bye;----------------------------------
		mov dx,03f8h
		in al,dx
		mov [Sentdata],al
		bye:
		retf
Recieve1 endp
	
CheckRecieve proc
	mov [Sentdata],00h
	call far ptr Recieve1
	cmp [Sentdata], 'q'
	je retdesign
	cmp [Sentdata],1bh
	jne contsent
	jmp exitmm
	contsent:
	cmp [Sentdata],3bh
	je inviteChat
	cmp [Sentdata],3ch
	je invitegame
	cmp [Sentdata],3dh
	je hostdesigning
	
	cmp al,'y'
	je waf2chat
	
	cmp al,'Y' 
	je waf2game
	
	cmp al,'N'
	jne retu1
	jmp mshtmam2
retu1:
ret
    retdesign:
	mov[inMain],1
	call clearscreen1
	call creatstartingmenu
	ret
	hostdesigning:
	mov[inMain],0
	call clearscreen1
	call guestscreenatdesigning
	ret
	inviteChat:
	call gahinvitationChat
	ret
	invitegame:          ;7ot el func el gdeda bta3t el game
	call gahinvitationGame
	ret
waf2chat:
		 call far ptr Main1
		 call clearscreen1
	     call creatstartingmenu
		ret
waf2game:
   call clearscreen1
	mov dh, 10
	mov dl, 35
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,selectmap      ;load $
	mov ah,9
	int 21h 
	loop3 :
	mov ah,01
	int 16h
	jz loop3
	mov ah,0
	int 16h
	
	cmp al,1bh
	jne  contwithq
	mov[esqq],1
	mov [Sentdata],al
	call far ptr send1
	ret
	contwithq:
	 mov [Sentdata],al
	 push ax
	 call  far ptr send1
	 pop  ax
	call far ptr  openfileM
	call far ptr  readfileM
	call far ptr  drawmapM
	call far ptr  drawlinem
	
	
	call far ptr Main3
	ret 
	; CALL FUNC BTA3T GAME ===========================================NOTE=============================================
mshtmam2:
		mov dh, 23
		mov dl, 0
		mov bh, 0h
		mov ah, 2h
		int 10h 
		lea dx,GuestName+2      ;load $
		mov ah,9
		int 21h
		lea dx,HostRejectMessage      ;load $
		mov ah,9
		int 21h
		mov ax,00h
		mov [Sentdata],00h
		jmp loop11
CheckRecieve endp

Checksend1 proc
	;check buffer
	mov ah,01h
	int 16h
	jz retu
	;take input from buffer
	mov ah,00h
	int 16h
	cmp al,1bh ;esc
	jne kammal
	mov [Sentdata],al
	call  far ptr send1
	jmp exitmm	
	kammal:
	cmp ah,3bh ;f1
	je ba3tchat
	cmp ah,3ch ;f2
	je ba3tgame
	cmp ah,3dh ;F3
	je ba3tmap
	retu:
	ret
	ba3tchat:
	call clearMessages
	mov dh, 22
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,HostChatMessage     ;load $
	mov ah,9
	int 21h
	mov [Sentdata],3bh ;f1
	call  far ptr send1
	jmp retu
	ba3tgame:
	call clearMessages
	mov dh, 22
	mov dl, 0
	mov bh, 0
	mov ah, 2h
	int 10h 
	lea dx,HostGameMessage     ;load $
	mov ah,9
	int 21h
	mov [Sentdata],3ch ;f2
	call  far ptr send1
	mov [oHost],1
	jmp retu
	ba3tmap:
	call clearMessages
	mov [Sentdata],3dh
	call  far ptr send1
	mov dh, 22
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	 call far ptr Main2
	 call clearscreen1
	 call creatstartingmenu
	jmp retu	
Checksend1 endp

guestscreenatdesigning proc near
     
     mov ah,02h
	 mov bh,0
	 mov dh,rowms ;y
	 mov dl,colms ;x  
	 int 10h 
     lea dx,GuestName+2
	 mov ah,09h
     int 21h
	 lea dx,fun5
	 mov ah,09h
     int 21h
	 
	 mov ah,02h
	 mov dh,rowms ;y
	 add dh,2
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun1
	 mov ah,09h
     int 21h	 
	 
	 mov ah,02h
	 mov dh,rowms ;y
	 add dh,4
	 mov dl,colms ;x  
	 int 10h 
     lea dx,fun2
	 mov ah,09h
     int 21h
     ret
guestscreenatdesigning endp

printscores1 proc far 
    mov dh,22
	mov dl,1
	mov bh,0h
	mov ah,2h
	int 10h 
	lea dx,Scorestate     ;load $
	mov ah,9
	int 21h
	lea dx,HostName+2     ;load $
	mov ah,9
	int 21h
	lea dx,slash
	mov ah,9
	int 21h
	lea dx,GuestName+2    
	mov ah,9
	int 21h
	lea dx,endbrackn
	mov ah,9
	int 21h
	lea dx,openbrack
	mov ah,9
	int 21h
	mov ax,oScore
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,slash
	mov ah,9
	int 21h
	mov ax,zScore
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
	mov dh, 22
	mov dl, 35
	mov bh, 0h
	mov ah, 2h
	int 10h
	mov al,20h
	mov bh,0
	mov bl,60h
	mov cx,1
	mov ah,9
	int 10h
	mov dh,22
	mov dl,37
	mov bh,0h
	mov ah,2h
	int 10h
	lea dx,HostName+2     ;load $
	mov ah,9
	int 21h
	cmp oDirection,1
	je printup
	cmp oDirection,2
	je printright
	cmp oDirection,3
	je printdown
	lea dx,left  
    jmp contpritn	;load $
	printup:
	lea dx,up
	jmp contpritn
	printright:
	lea dx,right
	jmp contpritn
	printdown:
	lea dx,down
	contpritn:
	mov ah,9
	int 21h
	lea dx,openbrack
	mov ah,9
	int 21h
	mov ah,0
	mov al,oRowHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,comma
	mov ah,9
	int 21h
	mov ah,0
	mov al,oColHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
	mov dh, 22
	mov dl, 60
	mov bh, 0h
	mov ah, 2h
	int 10h
	mov al,20h
	mov bh,0
	mov bl,40h
	mov cx,1
	mov ah,9
	int 10h
	mov dh,22
	mov dl,62
	mov bh,0h
	mov ah,2h
	int 10h
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	cmp zDirection,1
	je printup2
	cmp zDirection,2
	je printright2
	cmp zDirection,3
	je printdown2
	lea dx,left  
    jmp contpritn2	;load $
	printup2:
	lea dx,up
	jmp contpritn2
	printright2:
	lea dx,right
	jmp contpritn2
	printdown2:
	lea dx,down
	jmp contpritn2
	lea dx,left  
	contpritn2:   ;load $
	mov ah,9
	int 21h
	mov ah,0
	mov al,zRowHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,comma
	mov ah,9
	int 21h
	mov ah,0
	mov al,zColHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
retf
printscores1 endp

printscores proc far
    call clearMessages
    cmp oHost,1
	jne Guestm
	call printscores1
	retf
	Guestm:
	mov dh,22
	mov dl,1
	mov bh,0h
	mov ah,2h
	int 10h 
	lea dx,Scorestate     ;load $
	mov ah,9
	int 21h
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	lea dx,slash
	mov ah,9
	int 21h
	lea dx,HostName+2    
	mov ah,9
	int 21h
	lea dx,endbrackn
	mov ah,9
	int 21h
	lea dx,openbrack
	mov ah,9
	int 21h
	mov ax,oScore
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,slash
	mov ah,9
	int 21h
	mov ax,zScore
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
	mov dh, 22
	mov dl, 35
	mov bh, 0h
	mov ah, 2h
	int 10h
	mov al,20h
	mov bh,0
	mov bl,60h
	mov cx,1
	mov ah,9
	int 10h
	mov dh,22
	mov dl,37
	mov bh,0h
	mov ah,2h
	int 10h
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	cmp oDirection,1
	je printup3
	cmp oDirection,2
	je printright3
	cmp oDirection,3
	je printdown3
	lea dx,left  
    jmp contpritn3	;load $
	printup3:
	lea dx,up
	jmp contpritn3
	printright3:
	lea dx,right
	jmp contpritn3
	printdown3:
	lea dx,down
	contpritn3:
	mov ah,9
	int 21h
	lea dx,openbrack
	mov ah,9
	int 21h
	mov ah,0
	mov al,oRowHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,comma
	mov ah,9
	int 21h
	mov ah,0
	mov al,oColHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
	mov dh, 22
	mov dl, 60
	mov bh, 0h
	mov ah, 2h
	int 10h
	mov al,20h
	mov bh,0
	mov bl,40h
	mov cx,1
	mov ah,9
	int 10h
	mov dh,22
	mov dl,62
	mov bh,0h
	mov ah,2h
	int 10h
	lea dx,HostName+2     ;load $
	mov ah,9
	int 21h
	cmp zDirection,1
	je printup4
	cmp zDirection,2
	je printright4
	cmp zDirection,3
	je printdown4
	lea dx,left  
    jmp contpritn4	;load $
	printup4:
	lea dx,up
	jmp contpritn4
	printright4:
	lea dx,right
	jmp contpritn4
	printdown4:
	lea dx,down
	contpritn4:
	mov ah,9
	int 21h
	lea dx,openbrack
	mov ah,9
	int 21h
	mov ah,0
	mov al,zRowHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,comma
	mov ah,9
	int 21h
	mov ah,0
	mov al,zColHead
	mov bl,10
	div bl
	add ax,3030h
	mov remoscore,ax
	lea dx,remoscore
	mov ah,9
	int 21h
	lea dx,endbrack1
	mov ah,9
	int 21h
retf
printscores endp

gahinvitationGame proc
	call clearMessages
	mov dh, 23
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	lea dx,GuestGameMessage     ;load $
	mov ah,9
	int 21h
	mov [oHost],0
	loop2:
	mov ah,01h
	int 16h
	jz loop2
	replo2:
	mov ah,00h
	int 16h
	cmp ah,3bh ;f1
	je letsRoll ;jmp GAME
	cmp al,'n' ;else jmp to no
	je NOO
	jmp replo2
    ret
	letsRoll:
	mov [Sentdata],'Y'   ; Y dy accept al game
	call  far ptr send1
	mov al,00h	;===================================================================NOTE===============================================
	call clearscreen1
	;CALL FUNCTION BTA3T AL GAME
	mov dh, 23
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	lea dx,hostselecting
    mov ah,9
	int 21h
	call RecName
	call far ptr GuestMain
	ret 
	NOO:
	mov [Sentdata],'N'
	call  far ptr send1
	mov al,00h
	;print you reject the invitation
	mov dh, 22
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,GuestRejectMessage      ;load $
	mov ah,9
	int 21h
	ret
gahinvitationGame endp

gahinvitationChat proc 
	call clearMessages
	mov dh, 23
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	lea dx,GuestChatMessage     ;load $
	mov ah,9
	int 21h
	
	loop22:
	mov ah,01h
	int 16h
	jz loop22
	replo:
	mov ah,00h
	int 16h
	cmp ah,3bh ;f1
	
	je chatm ;jmp chat
	;
	cmp al,'n' ;else jmp to no
	je NOoO
	jmp replo
ret 
	chatm:
	 mov [Sentdata],'y'
	 call  far ptr send1
	 call far ptr Main1
	 call clearscreen1
	 call creatstartingmenu
	 ret
	NOoO:
	mov [Sentdata],'N'
	call  far ptr send1
	mov al,00h
	;print you reject the invitation
	mov dh, 22
	mov dl, 0
	mov bh, 0h
	mov ah, 2h
	int 10h 
	lea dx,GuestRejectMessage      ;load $
	mov ah,9
	int 21h
	ret
gahinvitationChat endp
	
clearscreen1 proc near
	push ax
    mov ax,0003h
	int 10h
	pop ax
	ret
clearscreen1 endp
	
	screenline proc near
		mov cx,80
		mov ax,0b800h
		mov es,ax
		mov di,20*160
		drawLine1:
			lea si,line
			movsw
		loop drawLine1
		
		ret
	screenline endp
	
 buffer proc near
	;set cursor to print msg on screen
        mov ah,02h
	    mov bh,0
	    mov dh,5 ;y
	    mov dl,20 ;x  
	    int 10h 
        lea dx,beg ;print msg
	    mov ah,09h
        int 21h
		;set cursor to type name
		mov ah,02h
	    mov bh,0
	    mov dh,6 ;y
	    mov dl,21 ;x  
	    int 10h 
		
		call getName
		call far ptr WaitAndReady
		
		ret
 buffer endp
 
getName proc near
	push bx
	mov bx,2 ;start from 2
	inputHost:
	mov ah,1 ;check if there is anything in the keyboard buffer
	int 16h
	jz inputHost
	
	mov ah,0 ;read the keyboard buffer
	int 16h
	
	cmp al,13 ;enter key
	je EnterKeyBuff
	
	cmp al,8 ;backSpace
	je BackSpaceBuff
	
	cmp bx,17 ;bx reached maximum
	je inputHost
			;not back space or enter check if i am in the first count(bx=0) then it must be in a range A-Z and a-z
	cmp bx,2
	je checkFirstLetter
	mov HostName[bx],al
	inc bx
	;set cur and print and mov cur
	push bx
		mov ah,02h
	    mov bh,0 
	    int 10h
		;print at poss
		mov bh,0
		mov bl,07h
		mov cx,1 ;how many times
		mov ah,9 ;function 9
		int 10h
	pop bx
	add dl,1
	jmp inputHost
	
	EnterKeyBuff:
	cmp bx,2
	je inputHost
	jmp returnFromGetName
	BackSpaceBuff:
	cmp bx,2
	je inputHost
	mov al,' '
	mov HostName[bx],al
	dec bx
	sub dl,1
	;set cur and print and mov cur
	push bx
		mov ah,02h
	    mov bh,0 
	    int 10h

		;print at poss
		mov bh,0
		mov bl,07h
		mov cx,1 ;how many times
		mov ah,9 ;function 9
		int 10h
	pop bx
	jmp inputHost
	
	
	checkFirstLetter:
	cmp al,97
	jae chackmax2
	cmp al,65
	jae checkmax
	jmp inputHost
	checkmax:
	cmp al,90
	jbe savttohsot
	jmp inputHost
	chackmax2:
	cmp al,122
	jbe  savttohsot
	jmp inputHost
	savttohsot:
	mov HostName[bx],al
	inc bx
	;set cur and print and mov cur
	push bx
		mov ah,02h
	    mov bh,0 
	    int 10h

		;print at poss
		mov bh,0
		mov bl,07h
		mov cx,1 ;how many times
		mov ah,9 ;function 9
		int 10h
	pop bx
	add dl,1
	
	
	jmp inputHost
	returnFromGetName:
	mov HostName[bx],'$'
	dec bx
	dec bx
	mov HostName[1],bl
	pop bx
	ret
getName endp
				
empty proc near
		lea dx,emp       ;load $
		mov ah,9
		int 21h
		ret
empty endp

initialization1 proc near
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
	ret
initialization1 endp
	
send1 proc far
	mov dx,03fdh
	in al,dx
	test al,00100000b ; to check hold reg
	jz send1;---------------------------------
	mov al,[Sentdata]
	mov dx,03f8h
	out dx,al
	retf
send1 endp

clearMessages proc
mov ah,06h
mov al,3
mov bh,07h
mov ch,22
mov cl,0
mov dh,24
mov dl,79
int 10h
ret
clearMessages endp

exitmm:
cmp inMain,1
jne return
call clearscreen1
        mov ax,4c00h ; exitmm programs
		int 21h
return:
ret

Code_segment_name ends
end Main_prog

		



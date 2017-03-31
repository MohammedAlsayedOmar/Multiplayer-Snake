assume CS:Code_segment_name,DS:Data_segment_name
;COMMENT FOR MUSGI .. EL BETA3A EL SAHLA - 
Main2 proc far
    mov[inMain],0
	mov [obstcales],50
	mov [mode],0
	call far ptr clearscreenm
	call far ptr drawlinem
    call far ptr setcruser	
	Bonus:
	;===========
	call far ptr Recieve1
	cmp [Sentdata],3bh
	jne contenu
	mov [Sentdata],0
	;else print you have been invited
	;setCurser
	mov bh,0
	mov dl,0 ;col zero
	mov dh,23 ;row 23
	mov ah,2h
	int 10h
	;print 
	lea dx,GuestName+2     ;load $
	mov ah,9
	int 21h
	lea dx,GuestDesign     ;load $
	mov ah,9
	int 21h
	;setCur Back
	mov bh,0
	mov dl, byte ptr(col) ;col zero
	mov dh,byte ptr(row) ;row 23
	mov ah,2h
	int 10h
	
	contenu:
	mov ah,1
	int 16h
	jz Bonus
	;===========================
	call far ptr getinput
	cmp al,1bh;quit (esq)
	je endmd
	call far ptr checkinput  
	call far ptr setcruser
	cmp mode,1  ; drawing obstacles
	je draww
	cmp mode,2  
	je savem
	cmp mode,3 
	je loadm
	cmp mode,4 
	je deleteobstt
	jmp Bonus
	draww:
	call far ptr drawobst
	jmp Bonus
	savem:
	call far ptr savemap
    mov mode,0  ; reset the mode 
	mov base,0
	jmp Bonus
	loadm:
	mov [obstcales],50d
	call far ptr loadmap
	mov mode,0 ; reset the mode 
	mov temp ,0
	jmp Bonus
	deleteobstt:
	call far ptr deletobst
	mov mode,0
	jmp Bonus
	endmd:
	mov [Sentdata],'q' ;send q because escape exit prog
	call far ptr Send1
	call far ptr clearscreenm
	retf
Main2 endp

    clearscreenm proc near
	mov ax,0003h
	int 10h
	retf
	clearscreenm endp
	
    setcruser proc near
	 mov AH, 02h
	 mov bh,0
	 mov DH,byte ptr(row) ;y
	 mov DL,byte ptr(col) ;x  
	 int 10h 
	retf
	setcruser endp
	
	getinput proc near
	mov ax,0
	int 16h
	retf
	getinput endp
	
	checkinput proc near
	cmp ax, 4800h   ;UP.
    je  arrow_up
    cmp ax, 5000h   ;DOWN.
    je  arrow_down
    cmp ax, 4B00h   ;LEFT.
    je  arrow_left
    cmp ax, 4D00h   ;RIGHT.
    je  arrow_right
	cmp al,73h      ;save map (s)
	je  savmap
	cmp al,6ch       ;load map (L)
	je loamap
	cmp al,70h    ;print mode obst  (p)
	je changemode
	cmp al,64h   ;delete  d
	je deletemode
    jmp endddd
	arrow_up:
	cmp row,0
	je rowend
	sub [row],1
	retf
	arrow_down:
	cmp row,20
	je rowstart
	add [row],1 
	retf
	arrow_left: 
	cmp col,0
	je  colright
	sub [col],1 	
	retf
	arrow_right:
	cmp col,79
	je colleft
	add [col],1 
	retf        
	deletemode:
	mov [mode],4
	retf
    changemode:
	cmp mode,0
	je change 
	mov [mode],0
	retf
	change:
	mov [mode],1
    retf 
	rowend:
	mov [row],20
	retf
	rowstart:
	mov row,0
	retf
	colright:
	mov col,79
	retf
	colleft:
	mov col,0
	retf
	savmap:
	mov mode,2
	retf
	loamap:
	mov [mode],3
	retf
	endddd:
	retf
	checkinput endp
	
	drawobst proc near
	cmp obstcales,0
	je NoMore
	mov ah,08h ;to check if we are making obstcale above each other
	int 10h
	cmp ah,77h ;compare the returned att with the att
	je NoMore
	mov ax,row
	mov bl,80
	mul bl
	add ax,col
	mov bx,ax
	mov map[bx],31h
	mov al,20h
	mov bh,0
	mov bl,77h
	mov cx,1
	mov ah,9
	int 10h 
	sub [obstcales],1
	NoMore:
	retf
	drawobst endp
	
	checkobst proc near 
	mov ax,0000
	mov ax,row
	mov bl,80
	mul bl
	add ax,col
	mov bx,ax
	cmp map[bx],31h 
	je No
	mov bx,0
	retf
	No:
	mov bx,1
	retf
	checkobst endp
   
	deletobst proc near  
	mov ax,0000
    mov ax,row
	mov bl,80
	mul bl
	add ax,col
	mov bx,ax
	cmp map[bx],31h
	jne quitsx
	mov map[bx],30h
	add [obstcales],1 
	call far ptr setcruser
	mov al,20h
	mov bh,0
	mov bl,07h
	mov cx,1
	mov ah,9
	int 10h 
	quitsx:
	retf
	deletobst endp
	
	drawlinem proc near
	mov cx,80
	mov ax,0b800h
	mov es,ax
	mov di,21*160
	draw:
		lea si,split
		movsw
	loop draw
	retf
	drawlinem endp
	
  openfileSL proc near
    cmp al,31h
	je saveto1
	cmp al,32h
	je saveto2
	cmp al,33h
	je saveto3
	jmp retttt
	saveto1:
	lea dx,filename1
	jmp openSl
	saveto2:
	lea dx,filename2
	jmp openSl
	saveto3:
	lea dx,filename3
	openSl:
    mov ah,3dh ;opening file
	mov al,2 ;2 read/write
	int 21h
	jc ERROROPENs;jump if there is carry (carry=error)
	mov fileHandle,ax ;store ax in file handle
	retf
	ERROROPENs:
	lea dx,err
	mov ah,09
	int 21h
	retttt:
	retf
  openfileSL endp

 readfilesl proc near
 mov dx,offset map
  mov [temp],0
	ReadBytess:
		mov ah,3fh ;read from file
		mov bx,fileHandle
		mov cx,1
		int 21h
		jc ERRORREADs
		mov cx,1
		cmp ax,cx
		jne EndOfFiles
		mov bx,temp
		cmp map[bx],31h
		jne check0s
		cmp obstcales,0
		je reto
		sub obstcales,1
		add [temp],1
         inc dx 
		 jmp ReadBytess
		check0s:
		cmp map[bx],30h
		jne EndOfFiles
		add [temp],1
		inc dx 
	jmp ReadBytess
	ERRORREADs:
	lea dx,errR
	mov ah,09
	int 21h
	retf
	EndOfFiles:  ;Close File
	mov bx,fileHandle
	mov ah,3eh ;close file
	int 21h
	reto:
	retf
 readfilesl endp
 
 savemap proc near
     ;set curser
     mov ah,02h
	 mov bh,0
	 mov dh,22 ;y
	 mov dl,0 ;x  
	 int 10h 
	 ;print save msg
     lea dx,savestate
	 mov ah,09h
     int 21h
	 call far ptr getinput
     call far ptr openfileSL
	 ;writing to file
	 writefile:
	 cmp base,1680
	 je quit
	 mov bx,base
	 cmp map[bx],30h
	 je setdx0
	 lea dx,map1
	 jmp write
	 setdx0:
	 lea dx,map0
	 write:
	 mov AH,40h
     mov BX ,fileHandle
     mov CX,1
	 int 21h
	 add [base],1
	 jmp writefile
	 quit:
	 mov bx,fileHandle
	 mov ah,3eh ;close file
	 int 21h
	 ;clear notif area
	 mov ah,02h
	 mov bh,0
	 mov dh,22 ;y
	 mov dl,0 ;x  
	 int 10h 
	 ;print save msg
     lea dx,clear
	 mov ah,09h
     int 21h
	 call far ptr setcruser
	 retf
 savemap endp
 
 loadmap proc near
 	 mov ah,02h
	 mov bh,0
	 mov dh,22 ;y
	 mov dl,0 ;x  
	 int 10h 
	 ;print save msg
     lea dx,loadstate
	 mov ah,09h
     int 21h
	 call far ptr getinput
	 call far ptr openfileSL
	 call far ptr readfilesl
	 call far ptr drawmapM
	 mov ah,02h
	 mov bh,0
	 mov dh,22 ;y
	 mov dl,0 ;x  
	 int 10h 
	 ;print save msg
     lea dx,clear
	 mov ah,09h
     int 21h
	 call far ptr setcruser
	 retf
 loadmap endp
 

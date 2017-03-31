assume SS:Stack_segment_name,CS:Code_segment_name,DS:Data_segment_name

GuestMain proc far  ;allow the guest to receive the map,and then draw it
	
	;call far ptr RecName
	    cmp esqq,1
		je exitG
		mov al,Sentdata
	call far ptr SelectMapH
	call far ptr drawlinem
	
	mov [oScore],0 
	mov [oRowHead],10d
	mov [oColHead],20d
	mov [oDirection],2
	mov [oSend],2
	mov [oCount],2
	mov [oState],0
	mov [zScore],0 
	mov [zRowHead],10d
	mov [zColHead],60d
	mov [zDirection],4
	mov [zSend],4
	mov [zCount],2
	mov [zState],0
	call far ptr Main3
	retf
	exitG:
	mov [esqq],0
retf
GuestMain endp

SelectMapH proc far
	call far ptr openfileM
    call far ptr readfileM  	
    call far ptr drawmapM
retf
SelectMapH endp

drawmapM proc far    ;3ahsan e load men el file bas mesh ll design
    mov [colp],0
	mov [rowp],0
    loadMM:
	;set index
   	mov ax,0000
    mov ax,rowp
	mov bl,80
	mul bl
	add ax,colp 
	mov bx,ax	
	cmp map[bx],31h
	je obba
	cmp map[bx],49d
	je obba
	;No Obstacle
	 mov AH,02h
	 mov bh,0
	 mov DH,byte ptr(rowp) ;y
	 mov DL,byte ptr(colp) ;x  
	 int 10h
	 ;print at curser
	 mov al,20h
	 mov bh,0
	 mov bl,07h
	 mov cx,1
	 mov ah,9
	 int 10h 
	 add [colp],1
	 cmp colp,80
	 je setcoll
	 jmp loadMM
	 setcoll:
	 mov [colp],0
	 add [rowp],1
	 cmp rowp,21
	 je endddddM
	 jmp loadMM
	Obba:
	;set curser
	 mov AH,02h
	 mov bh,0
	 mov DH,byte ptr(rowp) ;y
	 mov DL,byte ptr(colp) ;x  
	 int 10h
	 ;print at curser
	 mov al,20h
	 mov bh,0
	 mov bl,77h
	 mov cx,1
	 mov ah,9
	 int 10h 
	 ;mov to next index
	 add [colp],1
	 cmp colp,80
	 je setcoll
	 jmp loadMM
	 endddddM:
	 retf
 drawmapM endp
 
  readfileM proc far
 mov dx,offset map
		mov[temp],0
	ReadBytesM:
		mov ah,3fh ;read from file
		mov bx,fileHandle
		mov cx,1
		int 21h
		jc ERRORREADM
		mov cx, 1
		cmp ax,cx
		jne EndOfFileM
		mov bx,temp
		cmp map[bx],31h
		jne checkM0
		add [temp],1
         inc dx 
		 jmp ReadBytesM
		checkM0:
		cmp map[bx],30h
		jne EndOfFileM
		add [temp],1
		inc dx 
	jmp ReadBytesM
	ERRORREADM:
	lea dx,errR
	mov ah,09
	int 21h
	ret
	EndOfFileM:  ;Close File
	mov bx,fileHandle
	mov ah,3eh ;close file
	int 21h
	retf
 readfileM endp
 
  openfileM proc far
    cmp al,31h
	je read1
	cmp al,32h
	je read2
	cmp al,33h
	je read3
	ret
	read1:
	lea dx,filename1
	jmp openread
	read2:
	lea dx,filename2
	jmp openread
	read3:
	lea dx,filename3
	openread:
    mov ah,3dh ;opening file
	mov al,0 ;0 read, 1 write, 2 read/write
	int 21h
	jc ERROROPENN;jump if there is carry (carry=error)
	mov fileHandle,ax ;store ax in file handle
	ret
	ERROROPENN:
	lea dx,err
	mov ah,09
	int 21h
	rettttt:
	retf
  openfileM endp
  
sendMapNum proc far
	mov dx,03fdh
	in al,dx
	test al,00100000b ; to check hold reg
	jz sendMapNum;---------------------------------
	mov al,[Sentdata]
	mov dx,03f8h
	out dx,al
	retf
sendMapNum endp
	
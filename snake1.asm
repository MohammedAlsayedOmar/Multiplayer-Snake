assume SS:Stack_segment_name,CS:Code_segment_name,DS:Data_segment_name

Main3 proc far
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
	mov [delaytime],6
	call far ptr setUpSnakes
	call far ptr drawSnakes
	call far ptr drawline
	call far ptr WaitAndReady
	
	pappple1:
		call far ptr getMilSec
		call far ptr RecieveSnake1
		call far ptr genApple
		cmp apple,1
		je printandCon1t
	jmp pappple1
	printandCon1t:
	call far ptr PrintApple
	
	gameloop:
	    call far ptr printscores 
		call far ptr delay
		call far ptr checkInputs
		call far ptr RecieveSnake
		call far ptr moveSnake1
		call far ptr moveSnake2
		call far ptr checkCollision
		cmp oState,0 ;if snake 1 is alive check snake 2
		je checkS2
		jmp exits
		checkS2:
		cmp zState,0 ;if snake 2 is not alive exit else loop again
		jne exits

		;Check if both snakes head collided
		call far ptr drawSnakes
		call far ptr checkHitCollision
		pappple:
			call far ptr getMilSec
			call far ptr RecieveSnake1
			call far ptr genApple
			cmp apple,1
			je printandCont
			cmp oHost,1 ;if not host request
			je pappple
			call far ptr requestMilSec
		jmp pappple
		printandCont:
		call far ptr PrintApple
	jmp gameloop
	exits:
	call far ptr clearscreen1
	;after clearing we print the win/lose
	mov al,oState ;put state of the host snake in al for easier comparison
	cmp zState,al ;if both states are equal means both are dead so we check the score`
	je compareScores
			;else we check the dead is lost no matter the score
	cmp oState,1 ;if host dead .. means guest alive
	je hailTheGuest
				;else hail host
	jmp hailHost
	
	compareScores:
	mov ax,oScore
	cmp zScore,ax
	je itsADraw ;if scores are equal then its a draw
	cmp zScore,ax
	ja hailTheGuest ;above means snake2 score is more than snake1
			;else hail host
	hailHost:
	cmp oHost,1 ;if i am not host print lose
	jne printLost
	;else print win
	call printWinMidScreen
	jmp continueToTheMainMenu
	
	itsADraw:
	call printDrawMidScreen
	jmp continueToTheMainMenu
	
	hailTheGuest:
	cmp oHost,1 ;if i am host print Lose
	je printLost
	;else print win
	call printWinMidScreen
	jmp continueToTheMainMenu
	
	printLost:
	call printLoseMidScreen
	
	
	continueToTheMainMenu:
	 mov ax,delaytime
	 mov [delaytime],0ffffh
	 mov delaytime,ax
	 mov cx,9
	 del:
	 push cx
	 call far ptr delay
	 pop cx
	 loop del
	 

	call far ptr clearscreenm
	call far ptr creatstartingmenu
	retf
Main3 endp

printLoseMidScreen proc near
	;set Cursor
	 mov bh,0h
	 mov ah,02h
	 mov dh, 11 ;row
	 mov dl, 35 ;col
	 int 10h
	 ;print
	 lea dx,loseMsg
	 mov ah,9
	 int 21h	
	ret
printLoseMidScreen endp

printWinMidScreen proc near
	;set Cursor
	 mov bh,0h
	 mov ah,02h
	 mov dh, 11 ;row
	 mov dl, 35 ;col
	 int 10h
	 ;print
	 lea dx,winMsg
	 mov ah,9
	 int 21h
	ret
printWinMidScreen endp

printDrawMidScreen proc near
	;set Cursor
	 mov bh,0h
	 mov ah,02h
	 mov dh, 11 ;row
	 mov dl, 26 ;col
	 int 10h
	 ;print
	 lea dx,drawMsg
	 mov ah,9
	 int 21h
	ret
printDrawMidScreen endp

checkInputs proc far
	mov ah,1
	int 16h ;check if there is anything in the keyboard buffer
	jz retFromIinput1
	
	mov ah,0
	int 16h ;read from keyboard buffer
	
	cmp oHost,1 ;if i am host
	je val1
	call far ptr validiateMovment2
	jmp retFromIinput
	
	val1:
	call far ptr validiateMovment1
	
	retFromIinput:
	retf
	retFromIinput1:
	call far ptr SendSnake
	jmp retFromIinput
checkInputs endp

validiateMovment1 proc far
	cmp ah, 48h   ;UP.
    je  arrow_upff
    cmp ah, 50h   ;DOWN.
    je  arrow_downff
    cmp ah, 4Bh   ;LEFT.
    je  arrow_leftff
    cmp ah, 4Dh   ;RIGHT.
    je  arrow_rightff
	jmp returnFromValidiate
	
	;Up is pressed
	arrow_upff:
	cmp oDirection,3 ;check i am moving up we cant move down
	je returnFromValidiate
	mov [oDirection],1 ;else set the direction to (1 up)
	jmp returnFromValidiate
	;Down is pressed
	arrow_downff:
	cmp oDirection,1 ;check i am moving down we cant move up
	je returnFromValidiate
	
	mov [oDirection],3 ;else set the direction to (3 down)
	jmp returnFromValidiate
	
	;Left is pressed
	arrow_leftff:
	cmp oDirection,2 ;check i am moving left we cant move right
	je returnFromValidiate
	
	mov [oDirection],4 ;else set the direction to (4 left)
	jmp returnFromValidiate
	
	;Right is pressed
	
	arrow_rightff:
	cmp oDirection,4 ;check i am moving left we cant move right
	je returnFromValidiate
	
	mov [oDirection],2 ;else set the direction to (2 right)
	jmp returnFromValidiate
	
	returnFromValidiate:
	mov al,[oDirection]
	mov [oSend],al
	call far ptr SendSnake
	retf
validiateMovment1 endp

validiateMovment2 proc far
	cmp ah, 48h   ;UP.
    je  arrow_up2ff
    cmp ah, 50h   ;DOWN.
    je  arrow_down2ff
    cmp ah, 4Bh   ;LEFT.
    je  arrow_left2ff
    cmp ah, 4Dh   ;RIGHT.
    je  arrow_right2ff
	jmp returnFromValidiate2
	
	;Up is pressed
	arrow_up2ff:
	cmp zDirection,3 ;check i am moving up we cant move down
	je returnFromValidiate2
	
	mov [zDirection],1 ;else set the direction to (1 up)
	jmp returnFromValidiate2
	
	;Down is pressed
	arrow_down2ff:
	cmp zDirection,1 ;check i am moving down we cant move up
	je returnFromValidiate2
	
	mov [zDirection],3 ;else set the direction to (3 down)
	jmp returnFromValidiate2
	
	;Left is pressed
	arrow_left2ff:
	cmp zDirection,2 ;check i am moving left we cant move right
	je returnFromValidiate2
	
	mov [zDirection],4 ;else set the direction to (4 left)
	jmp returnFromValidiate2
	
	;Right is pressed
	
	arrow_right2ff:
	cmp zDirection,4 ;check i am moving left we cant move right
	je returnFromValidiate2
	
	mov [zDirection],2 ;else set the direction to (2 right)
	jmp returnFromValidiate2

	returnFromValidiate2:
	mov al,[zDirection]
	mov [zSend],al
	call far ptr SendSnake
	retf
validiateMovment2 endp

moveSnake1 proc far

	;CHECK SELF COLLISION
	call far ptr checkSelfCollision1
	
	;store the tail before moving
	mov bl,[oCount]
	mov bh,0
	dec bl
	mov al,oRowBody[bx]
	mov [oTrow],al
	mov al,oColBody[bx]
	mov [oTcol],al
	;move body
	mov cx,11
	mov bx,10
	mov[index],11
	MoveS1:;10->11
		mov ah,0
		mov al,oColBody[bx]
		mov ah,oRowBody[bx]
		push bx
		mov bx,index
		mov oColBody[bx],al
		mov oRowBody[bx],ah
		pop bx
		dec bx
		sub[index],1
	loop MoveS1
	mov al,[oColHead]
	mov oColBody[0],al
	mov al,[oRowHead]
	mov oRowBody[0],al
	
	
	cmp oDirection,1 ;jump if direction is up
	je moveUp1
	cmp oDirection,2 ;jump if direction is RIGHT
	je moveRight1
	cmp oDirection,3 ;jump if direction is Down
	je moveDown1OutofRange
				;ELSE MOVE LEFT
	;moveHead
	cmp oColHead,0	;compare 3 times because we add 2 we need to compare 3 times
	je gotoRight1
	sub [oColHead],1
	call far ptr checkCollision
	call far ptr checkSelfCollision1
	call far ptr checkCollisionUpDown1
	cmp oState,1 ;if snake 1 is dead
	je returnFromMoveSnake1OutOfRange
	cmp oColHead,0
	je gotoRight1
	sub [oColHead],1
	cmp oColHead,0
	call far ptr checkCollision
	call far ptr checkSelfCollision1
	call far ptr checkCollisionUpDown1
	je gotoRight1
	jmp returnFromMoveSnake1OutOfRange
	gotoRight1:
	mov [oColHead],79
	jmp returnFromMoveSnake1OutOfRange
	
	moveDown1OutofRange:
	jmp moveDown1
	returnFromMoveSnake1OutOfRange:
	jmp returnFromMoveSnake1
	
	
	moveUp1:
	cmp oRowHead,0 ;compare first to make sure we can walk on the corner
	je gotoBot1
	sub [oRowHead],1
	call far ptr checkCollisionRightLeft1
	jmp returnFromMoveSnake1
	gotoBot1:
	mov [oRowHead],20
	call far ptr checkCollisionRightLeft1
	jmp returnFromMoveSnake1
	
	moveRight1:
	cmp oColHead,79 ;compare 3 times because we add 2 we need to compare 3 times
	je gotoLeft1
	add [oColHead],1
	call far ptr checkCollision
	call far ptr checkSelfCollision1
	call far ptr checkCollisionUpDown1
	cmp oState,1 ;if snake 1 is dead
	je returnFromMoveSnake1
	cmp oColHead,79
	je gotoLeft1
	add [oColHead],1
	call far ptr checkCollision
	call far ptr checkSelfCollision1
	call far ptr checkCollisionUpDown1
	cmp oColHead,79
	je gotoLeft1
	jmp returnFromMoveSnake1
	gotoLeft1:
	mov [oColHead],0
	jmp returnFromMoveSnake1
	
	moveDown1:
	;moveHead
	cmp [oRowHead],20
	je gotoTop1
	add [oRowHead],1
	call far ptr checkCollisionRightLeft1
	jmp returnFromMoveSnake1
	gotoTop1:
	mov [oRowHead],0
	call far ptr checkCollisionRightLeft1
	returnFromMoveSnake1:
	retf
moveSnake1 endp

checkCollisionUpDown1 proc far ;UpDown for snake1
	;When snake move right or left we check if up and down are the same because snake by5tareq el snake
	;Check up
	mov dh,[oRowHead]	;row
	mov dl,[oColHead]	;col
	add dh,1
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[zAttribute] ;compare if i dost 3ala snake2
	jne returnFromCheckCollisioUpDown1
	
	;check down
	sub dh,2
	call far ptr setCursor
	mov ah,8h
	int 10h
	cmp ah,[zAttribute] ;another snake
	jne returnFromCheckCollisioUpDown1
	
	;kill snake 1
	mov oState,1
	
	returnFromCheckCollisioUpDown1:
	retf
checkCollisionUpDown1 endp

checkSelfCollision1 proc far
	;* * * * *
	;*   * (move up)
	;* * *
	mov dh,[oRowHead]	;row
	mov dl,[oColHead]	;col
	
	cmp oDirection,1 ;up
	je check1Self1
	cmp oDirection,2 ;right
	je check2Self1
	cmp oDirection,3 ;down
	je check3Self1
				;CHECK 4(Left)
	sub dl,1
	jmp contCollision
	
	check1Self1:;UP
	sub dh,1
	jmp contCollision
	
	check2Self1: ;RIGHT
	add dl,1
	jmp contCollision
	
	check3Self1:;DOWN
	add dh,1
	
	contCollision:

	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[oAttribute] ;compare if i dost 3ala nafsi
	je killSnake
	
	jmp returncheckSelfCollision1
	 killSnake:
	 mov oState,1
	 returncheckSelfCollision1:
	retf
checkSelfCollision1 endp

checkCollisionRightLeft1 proc far
	;When snake move up or down we check if right and left are the same because snake by5tareq el snake
	;Check right
	mov dh,[oRowHead]	;row
	mov dl,[oColHead]	;col
	add dl,1
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[zAttribute] ;compare if i dost 3ala snake2
	jne returnFromCheckColisionLeftRight1
	
	;check left
	sub dl,2
	call far ptr setCursor
	mov ah,8h
	int 10h
	cmp ah,[zAttribute] ;another snake
	jne returnFromCheckColisionLeftRight1
	
	;kill snake 1
	mov oState,1
	
	returnFromCheckColisionLeftRight1:
	retf
checkCollisionRightLeft1 endp

checkCollision proc far
	;check Snake1
	mov dh,[oRowHead]	;row
	mov dl,[oColHead]	;col
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[zAttribute] ;compare if i dost 3ala snake2
	je killS1
	cmp ah,77h ;obstacle
	je killS1
	cmp ah,11h ;assume 54 is fruit
	je IncreaseScore
	
	jmp check2
	killS1:
	mov [oState],1
	jmp returnFromCollision
	
	IncreaseScore:
	cmp [apple],0
	je check2
	cmp oScore,30
	je kil2
	inc [OScore]
	jmp dontKkill2
	kil2:
	mov [ZState],1
	dontKkill2:
	mov [apple],0
	cmp [oCount],12
	je check2
	cmp gamemode,0
	je incSpeed
	inc [oCount]
	jmp check2
	incSpeed:
	cmp delaytime,1
	je check2
	sub [delaytime],1
	check2:
	;Check Snake2
	mov dh,[zRowHead]	;row
	mov dl,[zColHead]	;col
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[oAttribute] ;compare if i dost 3ala snake1
	je killS2
	cmp ah,77h ;obstacle
	je killS2
	cmp ah,11h ;assume 54 is fruit
	je IncreaseScore2
	
	jmp returnFromCollision
	killS2:
	mov [zState],1
	jmp returnFromCollision
	
	IncreaseScore2:
	cmp [apple],1
	jne returnFromCollision
	cmp zScore,30
	je kil1
	inc [zScore]
	jmp dontKkill1
	kil1:
	mov [oState],1
	dontKkill1:
	mov [apple],0
	cmp zCount,12
	je returnFromCollision
	cmp gamemode,0
	je incSpeed2
	inc [zCount]
	jmp returnFromCollision
	incSpeed2:
	cmp delaytime,1
	je returnFromCollision
	sub [delaytime],1
	returnFromCollision:
	retf
checkCollision endp

checkHitCollision proc far
	mov al,oRowHead
	mov dl,zRowHead
	cmp al,dl
	je checkCol
	jmp retFromHit
	checkCol:
	mov al,oColHead
	mov dl,zColHead
	cmp al,dl
	jne retFromHit
	
	;kill both
	mov [oState],1
	mov [zState],1
		
	retFromHit:
	retf
checkHitCollision endp

setUpSnakes proc far
	;Snake1
	mov bx,0 ;set up the rest of body
	mov cx,12
	mov dx,1    ; 1 3ashn el head mtb2ash fe nafs el mkan lel body el el awwlany y3ni head we b3deh be 2 cols yb2 ael body law be 0 hyoverwirte fel initial
	setUp1:
		mov ah,0
		mov al,oColHead
		push dx
		push bx
		push ax
		mov bl,2
		mov al,dl
		mul bl
		mov dl,al
		pop ax
		pop bx
		sub al,dl
		mov oColBody[bx],al
		mov al,oRowHead
		mov oRowBody[bx],al
		pop dx
		inc bx
		inc dx
	loop setUp1
	
	;Snake2
	mov bx,0 ;set up the rest of body
	mov cx,12
	mov dx,1
	setUp2:
		mov ah,0
		mov al,zColHead
		push dx
		push bx
		push ax
		mov bl,2
		mov al,dl
		mul bl
		mov dl,al
		pop ax
		pop bx
		add al,dl
		mov zColBody[bx],al
		mov al,zRowHead
		mov zRowBody[bx],al
		pop dx
		inc bx
		inc dx
	loop setUp2
	
	retf
setUpSnakes endp

drawSnakes proc far
	;Draw Snake1 Head
	mov dh,[oRowHead]
	mov dl,[oColHead]
	mov al,[oHead]
	mov bl, [oAttribute]
	call far ptr printAttPos ;sets the cursor where the head is
	call far ptr getsnakeprevhead1
	mov dh,[oHeadPrevRow]
	mov dl,[oHeadPrevCol]
	mov ah,2
	int 10h
	mov ah,8
	int 10h
	cmp al,'-'
	je forgg
	mov al,20h
	mov bl,07h
	call far ptr printAttPos
	forgg:
	;Draw Snake1 Body
	mov ch,0
	mov cl,[oCount]
	mov bx,0
	DrawSnake1:
		mov dh,oRowBody[bx]
		mov dl,oColBody[bx]
		mov al,'+'
		push bx
		push cx
		mov bl,[oAttribute]
		call far ptr printAttPos
		pop cx
		pop bx
		inc bx
	loop DrawSnake1
	;empty delo
	mov dh,[oTrow]
	mov dl,[oTcol]
	mov al,' '
	mov bl,07h
	call far ptr printAttPos
	
	
	;Draw Snake2 Head
	mov dh,[zRowHead]
	mov dl,[zColHead]
	mov al,[zHead]
	mov bl, [zAttribute]
	call far ptr printAttPos ;sets the cursor where the head is
	call far ptr getsnakeprevhead2
	mov dh,[zHeadPrevRow]
	mov dl,[zHeadPrevCol]
	mov al,20h
	mov bl,07h
	call far ptr printAttPos
	;Draw Snake2 Body
	mov ch,0
	mov cl,[zCount]
	mov bx,0
	DrawSnake2:
		mov dh,zRowBody[bx]
		mov dl,zColBody[bx]
		mov al,'+'
		push bx
		push cx
		mov bl,[zAttribute]
		call far ptr printAttPos
		pop cx
		pop bx
		inc bx
	loop DrawSnake2
	;empty delo
	mov dh,[zTrow]
	mov dl,[zTcol]
	mov al,' '
	mov bl,07h
	call far ptr printAttPos
	retf
drawSnakes endp

getsnakeprevhead1 proc far
    cmp oDirection,1 ;jump if direction is up
	je addrow
	cmp oDirection,2 ;jump if direction is RIGHT
	je subcol
	cmp oDirection,3 ;jump if direction is Down
	je subrow
	mov al,[oColHead]    ;left is left from the direction
	inc al
	cmp al,80
	je alzero
	contprev:
	mov [oHeadPrevCol],al
	mov al,[oRowHead]
	mov [oHeadPrevRow],al
	retf
	alzero:
	mov al,0
	jmp contprev
	retf
	addrow:
	mov al,[oRowHead]    
	inc al
	mov [oHeadPrevRow],al
	mov al,[oColHead]
	mov [oHeadPrevCol],al
	retf
	subcol:
	mov al,[oColHead]    
	dec al
	mov [oHeadPrevCol],al
	mov al,[oRowHead]
	mov [oHeadPrevRow],al
	retf
	subrow:
	mov al,[oRowHead]    
	dec al
	mov [oHeadPrevRow],al
	mov al,[oColHead]
	mov [oHeadPrevCol],al
	retf
getsnakeprevhead1 endp

getsnakeprevhead2 proc far
    cmp zDirection,1 ;jump if direction is up
	je addrow2
	cmp zDirection,2 ;jump if direction is RIGHT
	je subcol2
	cmp zDirection,3 ;jump if direction is Down
	je subrow2
	mov al,[zColHead]    ;left is left from the direction
	inc al
	cmp al,80
	je alzero2
	contprev2:
	mov [zHeadPrevCol],al
	mov al,[zRowHead]
	mov [zHeadPrevRow],al
	retf
	alzero2:
	mov al,0
	jmp contprev2
	retf
	addrow2:
	mov al,[zRowHead]    
	inc al
	mov [zHeadPrevRow],al
	mov al,[zColHead]
	mov [zHeadPrevCol],al
	retf
	subcol2:
	mov al,[zColHead]    
	dec al
	mov [zHeadPrevCol],al
	mov al,[zRowHead]
	mov [zHeadPrevRow],al
	retf
	subrow2:
	mov al,[zRowHead]    
	dec al
	mov [zHeadPrevRow],al
	mov al,[zColHead]
	mov [zHeadPrevCol],al
	retf
getsnakeprevhead2 endp
 
printAttPos proc far ;prints char in (al) with attribute stored in (bl) in position of DX (DH=row, DL=col)
	call far ptr setCursor
	mov bh,0
	mov cx,1 ;how many times
	mov ah,9 ;function 9
	int 10h 
	retf
printAttPos endp

setCursor proc far ;sets the cursor where dh ROW and dl Col
	 mov AH, 02h
	 mov bh,0
	 int 10h 
	retf
setCursor endp

delay proc far
    mov ah, 00
    int 1Ah
    mov bx, dx
jmp_delay:
    int 1Ah
    sub dx, bx
    ;there are about 18 ticks in a second, 10 ticks are about enough
    cmp dx, delaytime                                                      
    jl jmp_delay    
    retf
    
delay endp

moveSnake2 proc far

	;CHECK SELF COLLISION
	call far ptr checkSelfCollision2
	
	;store the tail before moving
	mov bl,[zCount]
	mov bh,0
	dec bl
	mov al,zRowBody[bx]
	mov [zTrow],al
	mov al,zColBody[bx]
	mov [zTcol],al
	;move body
	mov cx,11
	mov bx,10
	mov[index],11
	MoveS2:;10->11
		mov ah,0
		mov al,zColBody[bx]
		mov ah,zRowBody[bx]
		push bx
		mov bx,index
		mov zColBody[bx],al
		mov zRowBody[bx],ah
		pop bx
		dec bx
		sub[index],1
	loop MoveS2
	mov al,[zColHead]
	mov zColBody[0],al
	mov al,[zRowHead]
	mov zRowBody[0],al
	
	
	cmp zDirection,1 ;jump if direction is up
	je moveUp2
	cmp zDirection,2 ;jump if direction is RIGHT
	je moveRight2
	cmp zDirection,3 ;jump if direction is Down
	je moveDown2OutofRange
				;ELSE MOVE LEFT
	;moveHead
	cmp zColHead,0	;compare 3 times because we add 2 we need to compare 3 times
	je gotoRight2
	sub [zColHead],1
	call far ptr checkCollision
	call far ptr checkSelfCollision2
	call far ptr checkCollisionUpDown2
	cmp zState,1 ;if snake 1 is dead
	je returnFromMoveSnake2OutOfRange
	cmp zColHead,0
	je gotoRight2
	sub [zColHead],1
	cmp zColHead,0
	call far ptr checkCollision
	call far ptr checkSelfCollision2
	call far ptr checkCollisionUpDown2
	je gotoRight2
	jmp returnFromMoveSnake2OutOfRange
	gotoRight2:
	mov [zColHead],79
	jmp returnFromMoveSnake2OutOfRange
	
	moveDown2OutofRange:
	jmp moveDown2
	returnFromMoveSnake2OutOfRange:
	jmp returnFromMoveSnake2
	
	
	moveUp2:
	cmp zRowHead,0 ;compare first to make sure we can walk on the corner
	je gotoBot2
	sub [zRowHead],1
	call far ptr checkCollisionRightLeft2
	jmp returnFromMoveSnake2
	gotoBot2:
	mov [zRowHead],20
	call far ptr checkCollisionRightLeft2
	jmp returnFromMoveSnake2
	
	moveRight2:
	cmp zColHead,79 ;compare 3 times because we add 2 we need to compare 3 times
	je gotoLeft2
	add [zColHead],1
	call far ptr checkCollision
	call far ptr checkSelfCollision2
	call far ptr checkCollisionUpDown2
	cmp zState,1 ;if snake 1 is dead
	je returnFromMoveSnake2
	cmp zColHead,79
	je gotoLeft2
	add [zColHead],1
	cmp zColHead,79
	je gotoLeft2
	jmp returnFromMoveSnake2
	gotoLeft2:
	mov [zColHead],0
	jmp returnFromMoveSnake2
	
	moveDown2:
	;moveHead
	cmp [zRowHead],20
	je gotoTop2
	add [zRowHead],1
	call far ptr checkCollisionRightLeft2
	jmp returnFromMoveSnake2
	gotoTop2:
	mov [zRowHead],0
	call far ptr checkCollisionRightLeft2
	returnFromMoveSnake2:
	retf
moveSnake2 endp

checkCollisionUpDown2 proc far ;UpDown for snake1
	;When snake move right or left we check if up and down are the same because snake by5tareq el snake
	;Check up
	mov dh,[zRowHead]	;row
	mov dl,[zColHead]	;col
	add dh,1
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[oAttribute] ;compare if i dost 3ala snake2
	jne returnFromCheckCollisioUpDown2
	
	;check down
	sub dh,2
	call far ptr setCursor
	mov ah,8h
	int 10h
	cmp ah,[oAttribute] ;another snake
	jne returnFromCheckCollisioUpDown2
	
	;kill snake 2
	mov zState,1
	
	returnFromCheckCollisioUpDown2:
	retf
checkCollisionUpDown2 endp

checkSelfCollision2 proc far
	;* * * * *
	;*   * (move up)
	;* * *
	mov dh,[zRowHead]	;row
	mov dl,[zColHead]	;col
	
	cmp zDirection,1 ;up
	je check1Self2
	cmp zDirection,2 ;right
	je check2Self2
	cmp zDirection,3 ;down
	je check3Self2
				;CHECK 4(Left)
	sub dl,1
	jmp contCollision2
	
	check1Self2:;UP
	sub dh,1
	jmp contCollision2
	
	check2Self2: ;RIGHT
	add dl,1
	jmp contCollision2
	
	check3Self2:;DOWN
	add dh,1
	
	contCollision2:

	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[zAttribute] ;compare if i dost 3ala nafsi
	je killSnake2
	
	jmp returncheckSelfCollision2
	 killSnake2:
	 mov zState,1
	 returncheckSelfCollision2:
	retf
checkSelfCollision2 endp

checkCollisionRightLeft2 proc far
	;When snake move up or down we check if right and left are the same because snake by5tareq el snake
	;Check right
	mov dh,[zRowHead]	;row
	mov dl,[zColHead]	;col
	add dl,1
	call far ptr setCursor
	mov ah,8h ;function 8 which check attribute are the cursor position
	int 10h ;AH color and AL character
	cmp ah,[oAttribute] ;compare if i dost 3ala snake2
	jne returnFromCheckCollllisionLeftRight2
	
	;check left
	sub dl,2
	call far ptr setCursor
	mov ah,8h
	int 10h
	cmp ah,[oAttribute] ;another snake
	jne returnFromCheckCollllisionLeftRight2
	
	;kill snake 1
	mov zState,1
	
	returnFromCheckCollllisionLeftRight2:
	retf
checkCollisionRightLeft2 endp
;----------------------------------------------------SEND AND RECIEVE SNAKE
SendSnake proc far
	sendAgainSnake:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
	jz sendAgainSnake  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		cmp oHost,1
		je sendOSend ;if i am host send OSend else send Zsend
		mov al,[zSend]
		jmp Send5alas
		sendOSend:
		mov al,[oSend]
		
		Send5alas:
		Out dx,al
	retf
SendSnake endp

RecieveSnake1 proc far
	recieveSnakeAgain1:
		mov dx,3FDh        ;Line status register
		In al,dx
		test al,00000001b ; Test if DR=1
	jz byee1             ;Jump if zero [DR=0] No data is ready to be picked up 
	mov dx,3F8h       ;Read data from Recieve buffer [3F8] into AL
	In al,dx
	
	
	cmp al,'-' ;host recieved milsec
	je RecMilSec1
	cmp al,'+' ;client sent + to request the milsec again
	je sendMilSec01
	
	
	
	cmp oHost,1 ;if i am host what i recieve is Z
	je goTo2
	
	mov [oDirection],al
	jmp byee1
	
	goTo2:
	mov [zDirection],al
	jmp byee1
	
	RecMilSec1:
	call far ptr RecieveMilSec
	jmp byee1
	
	sendMilSec01:
	call far ptr SendMilSec
	
	
	byee1:
	retf
RecieveSnake1 endp

RecieveSnake proc far
	recieveSnakeAgain:
		mov dx,3FDh        ;Line status register
		In al,dx
		test al,00000001b ; Test if DR=1
	jz recieveSnakeAgain             ;Jump if zero [DR=0] No data is ready to be picked up 
	mov dx,3F8h       ;Read data from Recieve buffer [3F8] into AL
	In al,dx
	
	
	cmp al,'-' ;host recieved milsec
	je RecMilSec
	cmp al,'+' ;client sent + to request the milsec again
	je sendMilSec0
	
	
	
	cmp oHost,1 ;if i am host what i recieve is Z
	je goTo22
	
	mov [oDirection],al
	jmp byee
	
	goTo22:
	mov [zDirection],al
	jmp byee
	
	RecMilSec:
	call far ptr RecieveMilSec
	jmp byee
	
	sendMilSec0:
	call far ptr SendMilSec
	
	byee:
	retf
RecieveSnake endp

RecieveMilSec proc far
	recieveSMilSec:
		mov dx,3FDh        ;Line status register
		In al,dx
		test al,00000001b ; Test if DR=1
	jz recieveSMilSec             ;Jump if zero [DR=0] No data is ready to be picked up 
	mov dx,3F8h       ;Read data from Recieve buffer [3F8] into AL
	In al,dx
	mov [appleMilSec],al
	mov apple,1
	
	returnFromRecMilSec:
	retf
RecieveMilSec endp

SendMilSec proc far
	;send Flag
	sendMilSecloop:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
	jz sendMilSecloop  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		mov al,'-'
		Out dx,al
	
	;Send MilSec
	sendMilSecloop2:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
	jz sendMilSecloop2  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		mov al,[appleMilSec]
		Out dx,al	
		
	mov [apple],1
	retf
SendMilSec endp

requestMilSec proc far
	cmp oHost,1 ;if i am not host i return (host never request MilSec .. he creates them)
	jne returnFromReqMilSec
			;if i am not host i check if there is no apple .. i request
	cmp apple,1
	jne returnFromReqMilSec ;i apple is not 1 we send '+' to request a milSec
	
	reqMilSecloop:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
	jz reqMilSecloop  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		mov al,'+'
		Out dx,al
	
	returnFromReqMilSec:
	retf
requestMilSec endp

WaitAndReady proc far
		;Algorithm
		;Send Y and wait till the other pc recieve Y and then he send Y and i wait till i recieve Y
	checkClear:
		mov dx,3FDh   ;Read the line status register`
		In al,dx
		test al,20h   ;test the THRE [Transmit hold register empty] 
	jz checkClear  ; if THRE=0 then loop until it = 1 [until the old data is sent]
		mov dx,3F8h
		
		mov al,'Y'
		Out dx,al
	
	recieveAgain:
		mov dx,3FDh        ;Line status register
		In al,dx
		test al,00000001b ; Test if DR=1
	jz recieveAgain             ;Jump if zero [DR=0] No data is ready to be picked up 
	mov dx,3F8h       ;Read data from Recieve buffer [3F8] into AL    
	In al,dx
	cmp al,'Y'
	jne checkClear
	
	retf
WaitAndReady endp

;-----------APPLE

genApple proc far
	 mov dl,[appleMilSec]
	 mov ah,00h
	 mov al,dl
	 mov cl,21
	 div cl
	 mov dh,ah
	 mov al,dl
	 mov cl,40
	 div cl
	 mov al,ah
	 mov cl,2
	 mul cl
	 mov dl,al
	 mov [applecol],dl
	 mov [applerow],dh
	retf
genApple endp

; genApple proc
	 ; loopGenApple:
	 ; ;get milsec
	 ; mov ah,2ch
	 ; int 21h
	 ; ;cal row and col
	 ; mov ah,00h
	 ; mov al,dl
	 ; mov cl,21
	 ; div cl
	 ; mov dh,ah
	 ; mov al,dl
	 ; mov cl,40
	 ; div cl
	 ; mov al,ah
	 ; mov cl,2
	 ; mul cl
	 ; mov dl,al
	 ; cmp dl,0
	 ; je setdl
	 ; mov [applecol],dl
	 ; mov [applerow],dh
	 ; jmp contseta
	 ; setdl:
	 ; add dl,2
	 ; mov [applecol],dl
	 ; mov [applerow],dh
	 ; contseta:
	 ; ;set cursor
	 ; mov bh,0h
	 ; mov ah,02h
	 ; int 10h
	 ; mov bx,0
	 ; call far ptr checkobstacles
	 ; cmp bx,0
	 ; je loopGenApple
	 ; ;print apple
	 ; mov al,'a'
	 ; mov bh,0
	 ; mov bl,11h
	 ; mov cx,1;
	 ; mov ah,09h
	 ; int 10h
; retf
; genApple endp

checkobstacle proc far
;get 
	 mov bh,0
	 mov ah,08h
	 int 10h
	 cmp ah,07h
	 je contff
	 retf
	contff:
	cmp al,20h   ;lma ash8l el load 5leha 20h
	je finish
	retf
	finish:
	mov bx,1
  retf
checkobstacle endp

printApple proc far
	;set Cursor
	 mov dl,[applecol]
	 mov dh,[applerow]
	 push bx
	 call far ptr setCursor
	 pop bx
	 mov al,'a'
	 mov bh,0
	 mov bl,11h
	 mov cx,1;
	 mov ah,09h
	 int 10h
	retf
printApple endp

getMilSec proc far
	cmp oHost,1
	jne returnFromGetMilSec ;return if we are not host
	cmp apple,1
	je returnFromGetMilSec ;return and don't send if we have apple
	
	 loopGenApple:
	 ;get milsec
	 mov ah,2ch
	 int 21h
	 ;cal row and col
	 mov ah,00h
	 mov al,dl
	 mov [appleMilSec],dl
	 mov cl,21
	 div cl
	 mov dh,ah
	 mov al,dl
	 mov cl,40
	 div cl
	 mov al,ah
	 mov cl,2
	 mul cl
	 mov dl,al
	 mov [applecol],dl
	 mov [applerow],dh
		
	;set curser
	 mov bh,0h
	 mov ah,02h
	 int 10h
	
	 mov bx,0
	 call far ptr checkobstacle
	 cmp bx,0
	 je loopGenApple
	 
	 call far ptr SendMilSec
	 
	 returnFromGetMilSec:
	retf
getMilSec endp


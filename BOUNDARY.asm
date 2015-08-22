
.MODEL SMALL    
.STACK 100H
.DATA
KEY DW 0H
FRUITX DW 0
FRUITY DW 0
SCORE DW 0
LENGTH DW 0
INTRO DB "WELCOME TO THE WORM GAME ! !"
INSTRUCT DB "USE ARROW TO MOVE THE WORM"
BOARD DB "SCORE:  ",0
GAMEOVER DB "GAME OVER >_<"
DRAW_ROX MACRO X
    LOCAL R1    
    MOV AH,0CH  ;WRITE PIXEL FUNCTION
    MOV AL,75    ;START WITH COLOR 0
    MOV BH,0    ;PAGE 0
    MOV CX,10    ;COLUMN 0
    MOV DX,X ; ROW X
R1: INT 10H     ;WIRTE PIXEL
    INC CX      ;NEXT COL
    CMP CX,300  ;FINISHED ?
    JL R1       ;NO,REPEAT  
    
    ENDM
DRAW_COLUMN MACRO Y
    LOCAL R1    
    MOV AH,0CH  ;WRITE PIXEL FUNCTION
    MOV AL,75    ;START WITH COLOR 0
    MOV BH,0    ;PAGE 0
    MOV CX,Y    ;COLUMN 0
    MOV DX,100 ; ROW X
R1: INT 10H     ;WIRTE PIXEL
    INC DX      ;NEXT COL
    CMP DX,300  ;FINISHED ?
    JL R1       ;NO,REPEAT  
    
    ENDM
.CODE
MAIN PROC
     ;SET MODE
    MOV AH,0h
    MOV AL,12H
    INT 10H
    
    mov ax,@data 		; set up ds as the segment for data
    mov es,ax
             		; put this in es 

    mov bp,OFFSET INTRO 	; ES:BP points to message

    mov ah,13h 		; function 13 - write string
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,2 		; attribute - magenta
    mov cx,28 		; length of string
    mov dh,3 		; row to put string
    mov dl,5 		; column to put string
    int 10h 		; call BIOS service
    
    MOV BP,OFFSET INSTRUCT
     
    mov ah,13h 		; function 13 - write string
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,2 		; attribute - magenta
    mov cx,26 		; length of string
    mov dh,8 		; row to put string
    mov dl,5 		; column to put string
    int 10h 		; call BIOS service
                                         
    MOV BP,OFFSET BOARD                                       
    mov ah,13h 		; function 13 - write string
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,2 		; attribute - magenta
    mov cx,8 		; length of string
    mov dh,12 		; row to put string
    mov dl,5 		; column to put string
    int 10h 		; call BIOS service
    

    
   
   
    ;DRAW BOUNDARY
    DRAW_ROX 100
    DRAW_ROX 300
    DRAW_COLUMN 10
    DRAW_COLUMN 300
    
    
    
    ;DISPLAY SETTING THE STARTING POINT AND SNAKE COLOR
    MOV AH,0CH  ;WRITE PIXEL FUNCTION
    MOV AL,95    ;START WITH COLOR 95
    MOV BH,0    ;PAGE 0
    MOV CX,150    ;COLUMN 150
    MOV DX,200 ; ROW 150
    
    ;MAKING THE KEY VARIABLE 0 
    PUSH BX
    LEA BX,KEY
    MOV WORD PTR[BX],0
    POP BX 
    
    MOV LENGTH,10
    MOV SCORE,0
    MOV FRUITX,150
    MOV FRUITY,220          
    
    ;STARTING WITH MAKING THE SNAKE GO LEFT
    CALL DOWN   
    
    ;CONTINUOS LOOP OF GAME
    
    AGAIN:
    PUSH BX
    LEA BX,KEY
    MOV BX,WORD PTR [BX] ;CHECK IF DOWN KEY IS PRESSED
    CMP BH,50H
    POP BX
    JE DW
     
    PUSH BX
    LEA BX,KEY
    MOV BX,WORD PTR [BX]  ;CHECK IF LEFT KEY IS PRESSED
    CMP BH,4BH
    POP BX    
    JE LF  
    
     PUSH BX
    LEA BX,KEY
    MOV BX,WORD PTR [BX]  ;CHECK IF RIGHT KEY IS PRESSED
    CMP BH,4DH
    POP BX    
    JE RI
    
    PUSH BX
    LEA BX,KEY
    MOV BX,WORD PTR [BX]  ;CHECK IF UP KEY IS PRESSED
    CMP BH,48H
    POP BX    
    JE U
    
     mov ax,@data 		; set up ds as the segment for data
    mov es,ax
             		; put this in es 

    mov bp,OFFSET GAMEOVER 	; ES:BP points to message

    mov ah,13h 		; function 13 - write string
    mov al,01h 		; attrib in bl,move cursor
    xor bh,bh 		; video page 0
    mov bl,2 		; attribute - magenta
    mov cx,20 		; length of string
    mov dh,20 		; row to put string
    mov dl,5 		; column to put string
    int 10h 		; call BIOS service
    
    
    HLT ;END GAME 
    
    
    DW:
         
    PUSH BX
    LEA BX,KEY
    MOV WORD PTR[BX],0  ;MAKING KEY TO ZERO AGAIN
    POP BX 
    CALL DOWN
    JMP AGAIN
    
    LF:
    
    PUSH BX
    LEA BX,KEY
    MOV WORD PTR[BX],0   ;MAKING KEY TO ZERO AGAIN
    POP BX 
    CALL LEFT
    JMP AGAIN 
    
    
    U:
    PUSH BX
    LEA BX,KEY
    MOV WORD PTR[BX],0   ;MAKING KEY TO ZERO AGAIN
    POP BX 
    CALL UP
    JMP AGAIN
    
    RI:
    PUSH BX
    LEA BX,KEY
    MOV WORD PTR[BX],0   ;MAKING KEY TO ZERO AGAIN
    POP BX 
    CALL RIGHT
    JMP AGAIN
    
    
    
    MAIN ENDP    
UP PROC
   
TU: INT 10H     ;WIRTE PIXEL
    CALL FRUIT
    CMP DX,LENGTH   ; TO CHECK IF ITS OUT OF THE BORDER 
    JL NEXTU    ;IF IT IS DONT ERASE FOR TAIL
    CMP DX,299  ; TO CHECK IF ITS OUT OF THE BORDER 
    JNL NEXTU   ;IF IT IS DONT ERASE FOR TAIL
    PUSH DX
    PUSH AX
    ADD DX,LENGTH
    MOV AL,0    ;ASSINING BACKGROUND COLOR TO TAIL
    INT 10H
    POP AX
    POP DX 
    NEXTU:
    
     ;CHECK FOR KEYBORAD PRESSED OR NOT
    CALL INPUT
    PUSH BX
    LEA BX,KEY
    CMP WORD PTR [BX],0  ;IS ANY KEY PRESSED
    POP BX
    JNZ EXITU:
    
    DEC DX      ;NEXT COL
    CMP DX,100  ;FINISHED ?
    JG TU       ;NO,REPEAT
    
    EXITU:
     
    PUSH DX
    PUSH AX
    PUSH BX
    MOV BX,LENGTH
    RU:
    PUSH DX
    CMP DX,300   ;IS IT LOWER THEN 300
    JNL NOPEU
    ADD DX,BX   
    MOV AL,0     ;MAKE THE SNAKE INTO 1 DOT FOR TURN
    INT 10H
    POP DX
    NOPEU:
    DEC BX
    CMP BX,0
    JNE RU
    POP BX
    POP AX
    POP DX 
    CALL FRUIT
    RET
    UP ENDP
DOWN PROC
   
   
TD: INT 10H     ;WIRTE PIXEL
    CALL FRUIT
    CMP DX,LENGTH   ; TO CHECK IF ITS OUT OF THE BORDER 
    JL NEXTD    ;IF IT IS DONT ERASE FOR TAIL
    CMP DX,101
    JNG NEXTD
    PUSH DX
    PUSH AX
    SUB DX,LENGTH
    MOV AL,0    ;ASSINING BACKGROUND COLOR TO TAIL
    INT 10H
    POP AX
    POP DX 
    NEXTD:
    
    ;CHECK FOR KEYBORAD PRESSED OR NOT
    CALL INPUT
    PUSH BX
    LEA BX,KEY
    CMP WORD PTR [BX],0
    POP BX
    JNZ EXITD:
    
    INC DX      ;NEXT COL
    CMP DX,300  ;FINISHED ?
    JL TD       ;NO,REPEAT
    
    EXITD:
    
    PUSH DX
    PUSH AX
    PUSH BX
    MOV BX,LENGTH
    RD:
    PUSH DX
    CMP DX,100
    JNG NOPED
    SUB DX,BX   
    MOV AL,0
    INT 10H
    POP DX
    NOPED:
    DEC BX
    CMP BX,0
    JNE RD
    POP BX
    POP AX
    POP DX 
    CALL FRUIT
    RET
    DOWN ENDP


RIGHT PROC    
    
  
TR: INT 10H     ;WIRTE PIXEL
    CALL FRUIT
    CMP CX,30
    JL NEXTR
    CMP CX,10
    JNG NEXTR
    PUSH CX
    PUSH AX
    SUB CX,LENGTH
    MOV AL,0
    INT 10H
    POP AX
    POP CX 
    NEXTR:
    
    ;CHECK FOR KEYBORAD PRESSED OR NOT
    CALL INPUT
    PUSH BX
    LEA BX,KEY
    CMP WORD PTR [BX],0
    POP BX
    JNZ EXIT:
     
    INC CX      ;NEXT COL
    CMP CX,300  ;FINISHED ?
    JL TR       ;NO,REPEAT
    
    EXIT:
    
    PUSH CX
    PUSH AX
    PUSH BX
    MOV BX,LENGTH
    RR:
    PUSH CX
    CMP CX,10
    JNG NOPER
    SUB CX,BX   
    MOV AL,0
    INT 10H
    POP CX
    NOPER:
    DEC BX
    CMP BX,0
    JNE RR
    POP BX
    POP AX
    POP CX 
    CALL FRUIT
    RET
    RIGHT ENDP

LEFT PROC
  
TL: INT 10H     ;WIRTE PIXEL
    CALL FRUIT
    CMP CX,299
    JG NEXTL
    PUSH CX
    PUSH AX
    ADD CX,LENGTH
    MOV AL,0
    INT 10H
    POP AX
    POP CX 
    NEXTL:
    
      ;CHECK FOR KEYBORAD PRESSED OR NOT
    CALL INPUT
    PUSH BX
    LEA BX,KEY
    CMP WORD PTR [BX],0
    POP BX
    JNZ EXITL
    
    DEC CX      ;NEXT COL
    CMP CX,10  ;FINISHED ?
    JG TL       ;NO,REPEAT
    
    EXITL:
    
    PUSH CX
    PUSH AX
    PUSH BX
    MOV BX,LENGTH
    RL:
    PUSH CX
    CMP CX,299
    JG NOPEL
    ADD CX,BX   
    MOV AL,0
    INT 10H
    POP CX
    NOPEL:
    DEC BX
    CMP BX,0
    JNE RL
    POP BX
    POP AX
    POP CX 
    CALL FRUIT
    
    RET
    LEFT ENDP


FRUIT PROC
   
   PUSH CX
   PUSH DX
   PUSH AX
   
   PUSH BX
   
   LEA BX,FRUITX
   
   MOV CX,WORD PTR [BX]
   
   LEA BX,FRUITY
   
   MOV DX,WORD PTR [BX]
   
   POP BX
   
   MOV AL,45
   INT 10H
   
   POP AX
   POP DX
   POP CX

    
   CMP FRUITX,CX 
   JNE NEVERMIND
   CMP FRUITY,DX
   JNE NEVERMIND
   
   PUSH BX
   LEA BX,SCORE
   ADD WORD PTR [BX],10
   LEA BX,LENGTH
   ADD WORD PTR [BX],10
   
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
 
    mov ah,02
    mov dl,0x08
    int 21h
    int 21h 
   
  
    mov ax,score
    
    call dispnum
    
    POP DX
    POP CX
    POP BX
    POP AX
   
   POP BX
   
   PUSH BX
   PUSH AX
   
   MOV AX,FRUITX
   MOV BX,FRUITY
   
   SHR AX,1
   SHR BX,1   
   ADD FRUITX,AX
   ;MOV AX,FRUITX
   CMP FRUITX,200
   JNA NEXTFX
   CMP FRUITX,10
   JB NEXTFX
   
   MOV FRUITX,10
   ADD FRUITX,AX
    
   NEXTFX:
   
   ADD FRUITY,BX
   CMP FRUITY,200
   JNA NEXTFY
   CMP FRUITY,100
   JB NEXTFY
   
   MOV FRUITY,100
   ADD FRUITY,AX
   
   NEXTFY:
   
   
   
   POP AX
   POP BX  
   
   NEVERMIND:
    
   
    
    RET 
    
    FRUIT ENDP

INPUT PROC
    ;SAVING REGISTERS
    PUSH AX
    PUSH BX      
    PUSH CX
    PUSH DX  
    
    MOV AH, 01H
    INT 16H
    JNZ keybdpressed
    JMP NOKEYPRESSED
    keybdpressed:
   
        ;extract the keystroke from the buffer
        MOV AH, 00H
        INT 16H
        LEA BX, KEY                ; get address of KEY in BX.
        MOV WORD PTR [BX], AX    ; modify the contents of KEY.
            
        
    NOKEYPRESSED:
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
    INPUT ENDP

dispdigit proc
    add dl, '0'
    mov ah, 02H
    int 21H
    ret
dispdigit endp   
   
dispnum proc
    push ax
    push bx
    push dx
        
    test ax,ax
    jz retz
    xor dx, dx
    ;ax contains the number to be displayed
    ;bx must contain 10
    mov bx,10
    div bx
    ;dispnum ax first.
    push dx
    call dispnum  
    pop dx
    call dispdigit
    pop dx
    pop bx
    pop ax 
    ret
retz:
    mov ah, 02
    
    pop dx
    pop bx
    pop ax  
    ret    
dispnum endp  

END MAIN
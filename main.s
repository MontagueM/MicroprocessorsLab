#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D, LCD_Write_Hex, LCD_Clear_Display, LCD_delay_ms ; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine

    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
	ARG1L	EQU 0x20
	ARG1H	EQU 0x21
	ARG2L	EQU 0x22
	ARG2H	EQU 0x23
	ARG2U	EQU 0x24
	RES0	EQU 0x28
	RES1	EQU 0x29
	RES2	EQU 0x2A
	RES3	EQU 0x2B
	DIG0	EQU 0x30
	DIG1	EQU 0x31
	DIG2	EQU 0x32
	DIG3	EQU 0x33
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	;call	SetupMultiply16x16
	;call	Multiply16x16
	;call	SetupMultiply8x24
	;call	Multiply8x24
	;goto	gend
	goto	start

SetupMultiply16x16:
	movff	ADRESL, ARG1L	
	movff	ADRESH, ARG1H
	;movlw	0xd2
	;movwf	ARG1L
	;movlw	0x04
	;movwf	ARG1H
	movlw	0x02
	movwf	ARG2L
	movlw	0x10
	movwf	ARG2H
	return

Multiply16x16:
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L->
	; PRODH:PRODL
	MOVFF PRODH, RES1 ;
	MOVFF PRODL, RES0 ;
	;
	MOVF ARG1H, W
	MULWF ARG2H ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVFF PRODH, RES3 ;
	MOVFF PRODL, RES2 ;
	;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1L * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
	;
	MOVF ARG1H, W ;
	MULWF ARG2L ; ARG1H * ARG2L->
	; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ; 
	return

Multiply8x24:
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L->
	; PRODH:PRODL
	MOVFF PRODH, RES1 ; 
	MOVFF PRODL, RES0 ;
	;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W
	ADDWF RES1, F	; PRODL + RES1--> RES1
	MOVFF PRODH, RES2 ;
	; 
	MOVF ARG1L, W
	MULWF ARG2U ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W
	ADDWFC RES2, F ; PRODL + RES2 + carry bit --> RES2
	MOVLW 0x0
	ADDWFC	PRODH, F ; add the carry bit to RES3 (highest byte)
	MOVFF PRODH, RES3 ; 
	return

GetDigits:
	; Setup 16x16
	call	SetupMultiply16x16
	; Do 16x16 mult
	call	Multiply16x16
	; Set first digit
	movf	RES3, W
	movwf	DIG0, F

	; Setup 8x24
	movlw	0x0A
	movwf	ARG1L, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	RES2, W
	movwf	ARG2U, F
	; Do 8x24 mult and set each digit three times
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	DIG1, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	RES2, W
	movwf	ARG2U, F
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	DIG2, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	RES2, W
	movwf	ARG2U, F
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	DIG3, F
	
	; Convert to ASCII
	movlw	48
	addwf	DIG0, F
	addwf	DIG1, F
	addwf	DIG2, F
	addwf	DIG3, F
	

	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
	
	; Calculate digits from hex value
	;call	GetDigits
	call	measure_loop
	call	gend
	
	
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_l	; output message to LCD
				; don't send the final carriage return to LCD
	movlw	4
	lfsr	2, DIG0
	call	LCD_Write_Message
	
measure_loop:
	call	ADC_Read
	
	call	GetDigits
	
	call	LCD_Setup
	movf	DIG0, W	
	call	LCD_Send_Byte_D
	movf	DIG1, W	
	call	LCD_Send_Byte_D
	movf	DIG2, W	
	call	LCD_Send_Byte_D
	movf	DIG3, W	
	call	LCD_Send_Byte_D
	movlw	2000
	call	LCD_delay_ms
	goto	gend
	;goto	measure_loop		; goto current line in code
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return
gend:
	end	rst
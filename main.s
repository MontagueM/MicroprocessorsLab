#include <xc.inc>

extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I
extrn	Keyboard_Setup

psect	udata_acs   ; reserve data space in access ram

myTable__1:ds 1
KB_Val:ds 1
KB_Col:ds 1
KB_Row:ds 1
KB_Fin:ds 1
KB_Pressed: ds 1
KB_Fix: ds 1
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:	
	db	'1','2','3','F','4','5','6','E','7','8','9','D','A','0','B','C'
	myTable_l   EQU	16	; length of data
	align	2
	
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup
	movlw	3
	movwf	KB_Fix

	
	goto	set_kb

	; ******* Main programme ****************************************
	
set_kb:
	movlw	0x0
	movwf	KB_Pressed, A
	goto	start

start:
	call	Keyboard_Setup
	;movlw	0x1
	movwf	KB_Val, A  ; store the value of KB row and column
	
	; check KB_val is not zero
	movlw	0x00
	cpfsgt	KB_Val
	bra	set_kb

	; are we already pressed
	movlw	0x00
	cpfseq	KB_Pressed
	bra	start
	
	movlw	0x01
	movwf	KB_Pressed
	
	;split into KB_col and KB_row
	movlw	0x0f
	andwf	KB_Val, 0
	movwf	KB_Col, A
	
	swapf	KB_Val, 1
	movlw	0x0f
	andwf	KB_Val, 0
	movwf	KB_Row, A
	
	; starts at 1, need to start at 0
	bcf     STATUS, 0
	rrcf	KB_Col, 1
	bcf     STATUS, 0
	rrcf	KB_Row, 1
	
	movlw	4
	cpfslt	KB_Row
	movff	KB_Fix, KB_Row
	movlw	4
	cpfslt	KB_Col
	movff	KB_Fix, KB_Col
	
	movlw	0x00
	movwf	TRISH, A
	movff	KB_Col, PORTH
	movlw	0x00
	movwf	TRISJ, A
	movff	KB_Row, PORTJ
	
	; KB_Col + 4 * KB_Row
	movf	KB_Row, 0
	addwf	KB_Row, 0
	addwf	KB_Row, 0
	addwf	KB_Row, 0
	bcf     STATUS, 0
	addwfc	KB_Col, 0
	movwf	KB_Fin, A
	
	; read the corresponding value
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	
	movf	KB_Fin, 0
	addwfc	TBLPTRL, 0
	movwf	TBLPTRL, A
	
	movlw	1
	lfsr	2, myArray
	call	LCD_Write_Message
	
	bra	start
	end	rst
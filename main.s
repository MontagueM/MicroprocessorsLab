	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable:
   	db	0xf9, 0x99, 0x9f ; 0
	db	0x66, 0x66, 0x66 ; 1
	db	0xF8, 0x42, 0x1F ; 2
	db	0xf8, 0xee, 0x8f ; 3
	db	0x15, 0x5F, 0xF4 ; 4
	db	0xf1, 0xff, 0x8f ; 5
	db	0xf1, 0x1f, 0x9f ; 6
	db	0xf8, 0x88, 0x88 ; 7
	db	0xf9, 0xff, 0x9f ; 8
	db	0xf9, 0x9f, 0x88 ; 9
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x20	; Address of counter variable
  	c2 EQU 0x11
 	c3 EQU 0x12
	align	2		; ensure alignment of subsequent instructions
	; SET ALL PORTS TO OPEN

	; ******* Main programme *********************
start:	
    
    	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	movlw 	0x0
	movwf	TRISD, A	    ; Port D all outputs
	movlw 	0x0
	movwf	TRISE, A	    ; Port E all outputs
    
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	10		; 22 bytes to read
	movwf 	counter, A	; our counter register
	bra loop
	
delay2:
	; 1 + 1 + 2 + 1 + 2 + 2 = 9 (loop is 
    	movlw 0xFF
	movwf c3, A
	call	delay3
	decfsz	c2, A
	bra	delay2
	return
	
	
delay3:
	; 1 + 2 + 2 = 5 (loop is 1 + 2 = 3)
	decfsz	c3, A
	bra	delay3
	return

loop:
	movlw 0xFF
	movwf c2, A
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
		call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
		call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
	call delay2
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTC	
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD		
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTE	
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	
	goto	0

	end	main
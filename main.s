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
	;db	0x66, 0x66, 0x66 ; 1
	db	0xF8, 0x42, 0x1F ; 2
	;db	0x15, 0x5F, 0xF4 ; 4
	myArray EQU 0x400	; Address in RAM for data
	;counter EQU 0x10	; Address of counter variable
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
	;movlw	22		; 22 bytes to read
	;movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTC	
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD		
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTE	
	;decfsz	counter, A	; count down to zero
	;bra	loop		; keep going until finished
	
	goto	0

	end	main
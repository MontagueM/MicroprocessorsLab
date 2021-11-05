	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	//movlw	0x0
	//movwf	TRISE, A
	//movlw	0xFF
	//movwf   TRISD, A
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	c1 EQU 0x10
 	c2 EQU 0x11
 	c3 EQU 0x12
 	movlw 0xFF
	movwf c1, A


	movlw 0x0
	bra 	test

delay1:
    	movlw 0x7F
	movwf c2, A
	call	delay2
	decfsz	c1, A
	bra	delay1
	return
	
delay2:
	; 1 + 1 + 2 + 1 + 2 + 2 = 9 (loop is 
    	movlw 0xAF
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
	//movf	0x08, W
	//xorwf	PORTD, 0, 0
	//BTG	0x08, W, 0
	//movwf	0x08, A
	//movwf	PORTE, A
	call delay1
	movff 	0x06, PORTC
	incf 	0x06, W, A
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0x63
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main
	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw	0x0
	movwf	TRISE, A
	movlw	0xFF
	movwf   TRISD, A
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	bra 	test
loop:
	movf	0x08, W
	iorwf	PORTD, 0, 0
	movwf	0x08, A
	movwf	PORTE, A
	movff 	0x06, PORTC
	incf 	0x06, W, A
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0x63
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main

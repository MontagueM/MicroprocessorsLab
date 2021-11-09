	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100


	; ******* Main programme *********************
start:	
    
    	movlw 	0x0
	; Port C is for control
	movwf	TRISC, A
    	movlw 	0x0
	; Port D is for data
	movwf	TRISD, A	
	
	; Set OE* to high and CP to high, default states
	; OE* is bit 0, CP is bit 1
	movlw 0x1 | 0x2
	movwf PORTC, A
	
	; Set the data to be written to the chip
	movlw 0x1 | 0x2 | 0x4 | 0x80
	movwf PORTD, A
	
	; Flip CP low then high to write the data
	movlw 0x1
	movwf PORTC, A
	
	movlw 0x1 | 0x2
	movwf PORTC, A
	
	; Make OE* low so we can see the data in LEDs
	movlw 0x2
	movwf PORTC, A
	
	end	main
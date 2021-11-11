	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	call	SPI_MasterInit
  	c1 EQU 0x10
  	c2 EQU 0x11
 	c3 EQU 0x12
  	counter EQU 0x9
	TransmitValue EQU 0x13
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

delay:
    	movlw 0x10
	movwf c1, A
	call delay1
	return
	
delay1:
    	movlw 0xFF
	movwf c2, A
	call	delay2
	decfsz	c1, A
	bra	delay1
	return
	
delay2:
    	movlw 0xFF
	movwf c3, A
	call	delay3
	decfsz	c2, A
	bra	delay2
	return
	
	
delay3:
	decfsz	c3, A
	bra	delay3
	return
	
SPI_MasterInit:
    bcf	    CKE2
    movlw   (SSP2CON1_SSPEN_MASK | SSP2CON1_CKP_MASK | SSP2CON1_SSPM1_MASK)
    movwf   SSP2CON1, A
    bcf	    TRISD, PORTD_SDO2_POSN, A
    bcf	    TRISD, PORTD_SCK2_POSN, A
    return
    
SPI_MasterTransmit:
    movwf   SSP2BUF, A
Wait_Transmit:
    btfss   SSP2IF
    bra	    Wait_Transmit
    bcf	    SSP2IF
    return

Do_Transmit_Increment:
    rlcf   TransmitValue
    movf    TransmitValue, 0
    call    SPI_MasterTransmit
    call    delay
    return
    
Do_Transmit_Decrement:
    rrcf   TransmitValue
    movf    TransmitValue, 0
    call    SPI_MasterTransmit
    call    delay
    return

	; ******* Main programme *********************
start:	
        movlw	0x1
	movwf	TransmitValue, A
	movlw	0x7
	movwf	counter, A
	; Set the data to be written to the chip
Increment:
	call	Do_Transmit_Increment
	decfsz	counter
	bra	Increment
	
	movlw	0x7
	movwf	counter, A
Decrement:
	call	Do_Transmit_Decrement
	decfsz	counter
	bra	Decrement
	
	
	bra	start
	end	main
	
	

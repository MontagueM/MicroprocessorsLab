	#include <xc.inc>
	
psect	code, abs
main:
	org 0x0
	call	SPI_MasterInit

	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

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
	
	; ******* Main programme *********************
start:	
	; Set the data to be written to the chip
	movlw	0x1 | 0x4 | 0x20
	call	SPI_MasterTransmit
	;goto 0x0
	end	main
	
	

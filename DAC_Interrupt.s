#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi
    
psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	incf	LATJ, F, A	; increment PORTJ
	bcf	TMR0IF		; clear interrupt flag
	
	; Set CS* and WR* low
	;movlw	0x0
	;movwf	PORTC
	
	; Wait 40ns
	;call	LCD_delay_x4us
	
	; Set CS* and WR* high
	;movlw	0x1 | 0x2
	;movwf	PORTC
	
	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISC, A	; Control line set all outputs for WR*
	clrf	TRISJ, A	; Set PORTJ as all outputs
	clrf	LATC, A		; Clear PORTC outputs
	clrf	LATJ, A		; Clear PORTJ outputs
	
	; Set both CS* and WR* to high
	movlw	0x1 | 0x2
	movwf	PORTC
	
	movlw	10000001B	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
	
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return
	
	end

	


#include <xc.inc>

global  Keyboard_Setup

psect	udata_acs   ; named variables in access ram
KB_row:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
KB_col:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
KB_fin:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
psect	kb_code,class=CODE
    
Keyboard_Setup:
	banksel PADCFG1
	bsf	REPU
	clrf	LATE, A
	banksel	0  ; we need this to put default bank back to A
	
	movlw	0x0F
	movwf	TRISE
	
	; delay?
	movlw	5
	call	LCD_delay_ms
	
	; Drive output bits low all at once
	movlw	0x00
	movwf	PORTE, A
	
	; Read 4 PORTE input pins
	movff 	PORTE, KB_col

	; Invert the pins to show only the pressed ones
	movlw	0x0F
	xorwf	KB_col, 1, 0
	
	
	; Configure bits 0-3 output, 4-7 input
	movlw	0xF0
	movwf	TRISE
	
	movlw	5
	call	LCD_delay_ms
	
	; Drive output bits low all at once
	movlw	0x00
	movwf	PORTE, A
	
	
	; Read4 PORTE input pins
	movff 	PORTE, KB_row
	movlw	0xF0
	xorwf	KB_row, 1, 0
	
	; Decode results to determine
	; Print results to PORTD
	
	movlw	0x00
	movwf	TRISD, A
	movwf	KB_fin
	movf	KB_row, 0
	addwf	KB_fin
	movf	KB_col, 0
	addwf	KB_fin
	movff	KB_fin, PORTD
	movf	KB_fin, 0  ; store KB_fin in w reg for later use
	return

	
; ** a few delay routines below here as LCD timing can be quite critical ****
LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
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


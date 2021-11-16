#include <xc.inc>

extrn	Keyboard_Setup

psect	udata_acs   ; reserve data space in access ram

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	Keyboard_Setup
	goto	start

	; ******* Main programme ****************************************
start:

	end	rst
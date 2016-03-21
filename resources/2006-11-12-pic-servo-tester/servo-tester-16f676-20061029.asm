; $Id: servo-tester-16f676.asm,v 1.7 2006/10/29 01:35:58 adicvs Exp $
;
; Copyright (C) 2006  Adi Linden <adi@adis.ca>
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
;
;-----------------------------------------------------------------------------
;
; The "Servo Tester" is a small device that generates PPM pulses to drive
; R/C servos. It has two operation modes: In manual mode servo movement is 
; contolled by user input. In automatic mode the servo is swept from one 
; limit to the other with sweep speed controlled by user input.
;
; Author:
; Adi Linden <adi@adis.ca>
;
; Website:
; <http://www.oodi.ca/>
;
; Hardware: 
; Three tact switches are used for user input and five LEDs provide
; feedback about device operation. The microcontroller I/O is used
; as follows:
;    RA3  -  right key
;    RA4  -  middle key
;    RA5  -  left key
;    RC0  -  LED 1 (left)
;    RC1  -  LED 2
;    RC2  -  LED 3
;    RC3  -  LED 4
;    RC4  -  LED 5 (right)
;    RC5  -  PPM Out
;
; Software:
; Pulse generation is controlled by loading timer1 and waiting for overflow
; to occur. No interrupt routine is utilzed. Program flow is as follows:
;
;    1. Initialize ports and variables
;    2. Set ppm pin (high)
;    3. Load timer1 with pulse on ticks
;    4. Wait for timer1 to overflow
;    5. Clear ppm pin (low)
;    6. Load timer1 with pulse off ticks
;    7. Handle key input
;    8. Update display
;    9. Update pulse on and off variables
;   10. Wait for timer1 to overflow
;
; Additional operations should be inserted during the off time of the pulse.
; There are 18ms to 19ms available which are mostly spent waiting for timer1
; to overflow.
;
; Timing has been optimized for greatest accuracy of the pulse on time as it
; determines servo position.
;
; Generation of the ppm signal updates the portc latch by modifying the
; shadow register and writing the result to the portc latch. To update LED
; state just change the shadow register, the ppm code updates portc.
;
;-----------------------------------------------------------------------------

	list      p=16f676, r=hex	; list directive to define processor
	#include <p16F676.inc>		; processor specific variable definitions

	errorlevel  -302		; suppress message 302 from list file

	__CONFIG   _CP_OFF & _CPD_OFF & _BODEN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

; PPM characteristics
; in number of timer1 ticks (dependend on oscillator frequency 4MHz = 1us tick)
#define	COR_ON		.4			; correction for on cycle
#define COR_OFF		.28			; correction for off cycle
#define PPER		(.20000 - COR_OFF)	; pulse period
#define	PMIN		(.900 - COR_ON)		; low position
#define	PCTR		(.1500 - COR_ON)	; center position 
#define	PMAX		(.2200 - COR_ON)	; high position
#define	PSTEP		.20			; pulse change per key press

; LED thresholds
; these determine which LEDs light at which pulse tick setting
#define	LED1_L		PMIN
#define LED1_H		(PMIN + (PCTR - PMIN) / 3)
#define	LED2_L		(PMIN + PSTEP)
#define LED2_H		(PCTR - PSTEP)
#define	LED3_L		(PCTR - (PCTR - PMIN) / 3)
#define LED3_H		(PCTR + (PMAX - PCTR) / 3)
#define LED4_L		(PCTR + PSTEP)
#define LED4_H		(PMAX - PSTEP)
#define LED5_L		(PMAX - (PMAX - PCTR) / 3)
#define LED5_H		PMAX

; LED bit assignment (left to right)
#define	LED1		0	; left most LED
#define	LED2		1	;     |
#define	LED3		2	;     |
#define	LED4		3	;     |
#define	LED5		4	; right most LED

; Port bit switches are attached to 
#define	SW1		3	; up key
#define	SW2		4	; center key
#define	SW3		5	; down key

; Parameters for switch subroutine
#define	SW_DLY		.40	; initial delay, repeat counter ticks (20ms)
#define	SW_RPT		.8	; repeat delay, repeat counter ticks (20ms)

; PPM output bit assignment
#define PPM		5	; PPM output
 
; RAM registers
	CBLOCK	0x20
tmp:2				; 16 bit temporary data
pon:2				; 16 bit pulse on timer ticks
poff:2				; 16 bit pulse off timer ticks
portc_reg			; shadow register for portc
				; each switch has a register to track state
				;  <--- repeat counter --->
				; | b4 | b3 | b2 | b1 | b0 | old | new |
sw1_flags			; state info for up key
sw2_flags			; state info for center key
sw3_flags			; state info for down key
	ENDC

; Macros to select register banks
bank0	macro			; switch to bank0
	bcf	STATUS,RP0
	endm
	
bank1	macro			; switch to bank1
	bsf	STATUS,RP0
	endm

addlf2	macro	_lit,_src	; 16 bit addition f src plus literal, result in f src
	movlw	low _lit	; process low byte
	addwf	_src,f		; add literal (w) to source
	btfsc	STATUS,C	; process carry
	incf	_src + 1,f
	movlw	high _lit	; process high byte
	addwf	_src + 1,f
        endm

lgtf2	macro	_lit,_src	; compare, literal greater then f
	movlw	low _lit
	subwf	_src,w		; subtract literal (w) from f
	movlw	high _lit
	btfss	STATUS,C	; carry set for positive or zero result
	addlw	0x01
	subwf	_src + 1,w	; subtract literal (w) from f
	endm			; carry flag is clear if literal > f
	
fgtl2	macro	_src,_lit	; compare, f greater then literal
	movf	_src,w
	sublw	low _lit	; subtract f (w) from literal
	movf	_src + 1,w
	btfss	STATUS,C	; carry set for positive or zero result
	addlw	0x01
	sublw	high _lit	; subtract f (w) from literal
	endm			; carry flag is clear if f > literal

subflf2	macro	_lit,_src,_dst	; 16 bit subtract f src from literal, result in f dst
	movf	_src,w		; process low byte
	sublw	low _lit	; subtract source (w) from literal
	movwf	_dst		; put result in destination
	movf	_src + 1,w	; process high byte
	btfss	STATUS,C	; take low byte carry into consideration
	addlw	0x01
	sublw	high _lit	; subtract source (w) from literal
	movwf	_dst + 1	; put result in destination
	endm

sublf2	macro	_lit,_src	; 16 bit subtract literal from f src, result in f src
	movlw	low _lit	; process low byte
	subwf	_src,f		; subtract literal (w) from source
	movlw	high _lit	; process high byte
	btfss	STATUS,C	; take low byte carry into consideration
	addlw	0x01
	subwf	_src + 1,f	; subtract literal (w) from source
	endm

movlf2	macro	_lit,_dst	; 16 bit move literal to f
	movlw	low _lit
	movwf	_dst
	movlw	high _lit
	movwf	_dst + 1
	endm
	 
; Define reset and interrupt vectors
	ORG	0x000		; processor reset vector
	goto	main		; go to beginning of program
	
	ORG     0x004		; interrupt vector location
	retfie			; return from interrupt

; The main program
;
; Start by initializing ports, timer, interrupts and variables.
main
	call    0x3FF		; retrieve factory calibration value
	bsf     STATUS,RP0	; set file register bank to 1 
	movwf   OSCCAL		; update register with factory cal value 
	bcf     STATUS,RP0	; set file register bank to 0

; setup interrupts (none)
	bank0			; disable interrupts
	clrf	INTCON		; disable global interrupts
	bank1
	clrf	PIR1		; clear peripheral interrupts
        bank0
	clrf	PIE1		; disable peripheral interrupts	
	
; initialize porta and portc
	movlw	0x1f		; portc 0:4 high, portc 5 low
	movwf	portc_reg	; write to portc shadow register
	movwf	PORTC		; write to port latch
	bank1
	movlw	0x07		; porta 0:2 weak pullup (pins n/c)
	movwf	WPUA		; pullup prevents latchup, safer then output
	movlw	0xff		; porta all input
	movwf	TRISA
	clrf	ANSEL		; all digital i/o
	clrf	TRISC		; portc output 
	bank0

; initialize variables
	movlf2	PCTR,pon	; set initial pulse to center
	clrf	sw1_flags	; clear switch flags
	clrf	sw2_flags	; clear switch flags
	clrf	sw3_flags	; clear switch flags
	
; The main loop
;
; Timing is provided by two back to back timer1 overflows. The loop starts by setting up
; timer1 for a 1-2ms period during which the PPM output is driven high. This is followed by
; a 19-18ms period during which the PPM output is low. Little additional processing is done
; during the PPM high time. However, during the low time the key switches are scanned,
; debounced and appropriate action taken. The LEDs are updated as well.
main_loop

; Setup timer1 (pulse on)
	clrf	T1CON		; stop timer1
	comf	pon + 1 ,w	; load timer1 high register
	movwf	TMR1H		; since timer1 counts up, load the complement
	comf	pon,w		; load timer1 low register
	movwf	TMR1L 		; since timer1 counts up, load the complement
	bcf	PIR1, TMR1IF	; clear timer1 overflow
	movlw	0x01		; internal clock with 1:1 presacaler
	movwf	T1CON		; start timer1

; Set portc, 5 high (pulse on)
	bsf	portc_reg,PPM	; set port pin in shadow register
	movf	portc_reg,w	; update port latch from shadow register
	movwf	PORTC

; Calculate pulse off time
	subflf2	PPER,pon,poff	; subtract pulse on from pulse period and place in pulse off 

; Wait for timer1 to overflow
wait_pulse_high
	btfss	PIR1, TMR1IF
	goto	wait_pulse_high

; Clear portc, 5 (pulse off)
	bcf	portc_reg,PPM	; clear port pin in shadow register
	movf	portc_reg,w	; update port latch from shadow register
	movwf	PORTC

; Setup timer1 (pulse off)
	clrf	T1CON		; stop timer1
	comf	poff + 1,w	; load timer1 high register
	movwf	TMR1H		; since timer1 counts up, load the complement
	comf	poff,w		; load timer1 low register
	movwf	TMR1L 		; since timer1 counts up, load the complement
	bcf	PIR1,TMR1IF	; clear timer1 overflow
	movlw	0x01		; internal clock with 1:1 presacaler
	movwf	T1CON		; start timer1

; Process switch inputs
	movlw	sw1_flags	; pass sw1_flags register location
	movwf	FSR		; to subroutine via FSR
	movlw	SW1		; pass port bit location via w
	call	switch_main
	andlw	0x01		; subroutine returns 0x01 if switch action due
	btfsc	STATUS,Z
	goto	done_sw1	; no action needed skip to next switch
	addlf2	PSTEP,pon	; increment pulse by our step value
	fgtl2	pon,PMAX	; is pulse greater then PMAX?
	btfsc	STATUS,C
	goto	done_sw1	; actual pulse is smaller then maximum value
	movlf2	PMAX,pon	; limit pulse to max value by making pulse PMAX
done_sw1

	movlw	sw2_flags	; pass sw1_flags register location
	movwf	FSR		; to subroutine via FSR
	movlw	SW2		; pass port bit location via w
	call	switch_main
	andlw	0x01		; subroutine returns 0x01 if switch action due
	btfsc	STATUS,Z
	goto	done_sw2	; no action needed skip to next switch
	movlf2	PCTR,pon	; set pulse to center value
done_sw2

	movlw	sw3_flags	; pass sw1_flags register location
	movwf	FSR		; to subroutine via FSR
	movlw	SW3		; pass port bit location via w
	call	switch_main
	andlw	0x01		; subroutine returns 0x01 if switch action due
	btfsc	STATUS,Z
	goto	done_sw3	; no action needed skip to next switch
	sublf2	PSTEP,pon	; decrement pulse by step value
	lgtf2	PMIN,pon	; is PMIN greater then pon?	
	btfsc	STATUS,C	; carry set for positive and zero results
	goto	done_sw3	; actual pulse is larger then minimum value
	movlf2	PMIN,pon	; limit pulse to min value by making pulse PMIN
done_sw3	

; Update LEDs
;
; Because we are operating on a shadow register we can compare compare LED
; thresholds one at a time and update the LED status without risk of
; flickering lights. Note: The real portc is updated from portc_reg every
; time the PPM pin is changed.
	bcf	portc_reg,LED1	; turn LED1 on
	fgtl2	pon,LED1_H	; is pon greater then LED1_H?
	btfss	STATUS,C	; carry clear true
	bsf	portc_reg,LED1	; LED1 off

	bsf	portc_reg,LED2	; turn LED2 off
	fgtl2	pon,LED2_L	; is pon greater then LED2_L?
	btfss	STATUS,C	; carry clear true
	bcf	portc_reg,LED2	; LED2 on
	fgtl2	pon,LED2_H	; is pon greater then LED2_H?
	btfss	STATUS,C	; carry clear true
	bsf	portc_reg,LED2	; LED2 off

	bsf	portc_reg,LED3	; turn LED3 off
	fgtl2	pon,LED3_L	; is pon greater then LED3_L?
	btfss	STATUS,C	; carry clear true
	bcf	portc_reg,LED3	; LED3 on
	fgtl2	pon,LED3_H	; is pon greater then LED3_H?
	btfss	STATUS,C	; carry clear true
	bsf	portc_reg,LED3	; LED3 off
	
	bsf	portc_reg,LED4	; turn LED4 off
	fgtl2	pon,LED4_L	; is pon greater then LED4_L?
	btfss	STATUS,C	; carry clear true
	bcf	portc_reg,LED4	; LED4 on
	fgtl2	pon,LED4_H	; is pon greater then LED4_H?
	btfss	STATUS,C	; carry clear true
	bsf	portc_reg,LED4	; LED4 off

	bsf	portc_reg,LED5	; turn LED5 off
	fgtl2	pon,LED5_L	; is pon greater then LED5_L?
	btfss	STATUS,C	; carry clear true
	bcf	portc_reg,LED5	; LED5 on
	
; Wait for timer1 to overflow
wait_pulse_low
	btfss	PIR1, TMR1IF
	goto	wait_pulse_low

; Start all over
	goto	main_loop	


; Bit to byte converion table 
;
; This table converts an 8 bit value to a bit pattern. It only supports the eight possible
; single bit positions possible per byte.
byte2bit
	addwf	PCL,f
	retlw	0x01
	retlw	0x02
	retlw	0x04
	retlw	0x08
	retlw	0x10
	retlw	0x20
	retlw	0x40
	retlw	0x80

; Switch subroutine
;
; This subroutine reads a switch attached to a port pin. It debounces the switch and 
; automatically repeats if the key is held continuously. I requires that the FSR is setup
; with the location of the flags register and w contains the bit number the switch is
; connected to, It returns 0x00 if no switch action is required and 0x01 if switch action is
; needed.
switch_main
	bcf	INDF,0		; clear 'new' flag
	call	byte2bit	; get bit mask based on w content
	andwf	PORTA,w		; read switch position from port	
	btfsc	STATUS,Z	; set flag on zero since switches pull low
	bsf	INDF,0		; update 'new' flag according to port bit
	movf	INDF,w		; place 'old' and 'new' flags in w
	andlw	0x03		; mask repeat counter
	addwf	PCL,f
	goto	switch_released	; switch is released and debounced
	goto	switch_changed	; switch is released from pressed state
	goto	switch_changed	; switch is pressed from released state
	goto	switch_pressed	; switch is pressed and debounced
	
switch_released
	clrf	INDF
	retlw	0x00
	
switch_changed
	bcf	INDF,1		; update 'old' flag
	btfsc	INDF,0		; to 'new' flag
	bsf	INDF,1
	retlw	0x00
	
switch_pressed
	movlw	0xfc		; mask flags and test repeat counter
	andwf	INDF,w		; cleared counter indicates initial switch
	btfsc	STATUS,Z	; action
	goto	switch_initial
	movlw	0x04		; increment repeat counter by adding 0x04
	addwf	INDF,f		; on overflow counter expired
	btfss	STATUS,C
	retlw	0x00
	movf	INDF,w		; set repeat counter preserving flags
	andlw	0x03		; clear counter bits
	iorlw	(SW_RPT^0xff)<<2
	movwf	INDF		; apply (left shifted) repeat value
	retlw	0x01		; return 'true'
switch_initial
	movf	INDF,w		; set repeat counter preserving flags
	andlw	0x03		; clear counter bits
	iorlw	(SW_DLY^0xff)<<2
	movwf	INDF		; apply (left shifted) initial delay value
	retlw	0x01		; return 'true'

; The program comes to an end right here...
	END                     ; directive 'end of program'

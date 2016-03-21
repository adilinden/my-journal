;====== clock.asm ============================== 98-02-08 ==
;
; clock with mux LED, alarm and 4 keys to set alarm time
; and real time. 7 segmant display anodes are connected
; to portb, common cathodes are connected to porta.
; Clock frequency is 4MHz. Tried to conserve RAM which
; makes for somewhat awkward code to eliminate unwanted
; bits in a lot of portions.
;
; Time is incremented on interrupt.
;
;----------------------------------------------------------
;
	list	p=16f84
	radix	hex
	__config h'fff9'
;
;- destination designator equates -------------------------
;
w	equ	0
f	equ	1
;
;- cpu equates --------------------------------------------
;
indf	equ	0x00
tmr0	equ	0x01
pcl	equ	0x02
status	equ	0x03
fsr	equ	0x04
porta	equ	0x05
portb	equ	0x06
pclath	equ	0x0a
intcon	equ	0x0b
optionr	equ	0x81
trisa	equ	0x85
trisb	equ	0x86
;
rp0	equ	5
z	equ	2
dc	equ	1
c	equ	0
t0if	equ	2
;
;- equates ------------------------------------------------
;
temp	equ	0x0c	;temporary storage
count	equ	0x0d	;general purpose loop count
key	equ	0x0e	;key press location, flag
;			 7|6|5|4|3|2|1|0 bits
;			  | | | | |x|x|x not used
;			  |x|x|x|x| | |  input buffer
;			 x| | | | | | |  debounce flag
	
;
dispsel	equ	0x0f	;pointer to active digit
;			 7|6|5|4|3|2|1|0 bits
;			  | | | | |x|x|x digit count
;			  | | | |x| | |  display alarm flag
;			  | | |1| | | |  always set for fsr
;			  |x|x| | | | |  not used
;			 x| | | | | | |  display time flag
;
hrh	equ	0x10	;hours 10's
hrl	equ	0x11	;hours 1's
minh	equ	0x12	;minutes 10's
minl	equ	0x13	;minutes 1's
sech	equ	0x14	;seconds high byte
secl	equ	0x15	;seconds low byte
temp_w	equ	0x16	;store w during interrupt
temp_s	equ	0x17	;store s during interrupt
alahrh	equ	0x18	;alarm hours 10's
alahrl	equ	0x19	;alarm hours 1's
alaminh	equ	0x1a	;alarm minutes 10's
alaminl	equ	0x1b	;alarm minutes 1's
debounce	equ	0x1c	;counter key processing
alaflag	equ	0x1d	;alarm flag
;			 7|6|5|4|3|2|1|0 bits
;			  | | |x| | | |  alarm on/off
;			 x|x|x| |x|x|x|x not used
;
;- start of main routine --------------------------------- 
;
	org	0x000
	goto	start
	org	0x004
	goto	inctime	;interrupt service routine
;
start	clrf	portb 	;clear portb
	movlw	b'00011111' ;set porta high
	movwf	porta 	;to ensure no led selected
	bsf	status,rp0	;switch to bank 1
	movlw	b'01010110' ;enable portb pull-ups
	movwf	optionr	;timer prescaler 1:128
	clrf	trisb 	;make rb0 to rb7 outputs
	movlw	b'11100000' ;make ra0 to ra4 outputs
	movwf	trisa
	bcf	status,rp0	;switch to bank 0
	movlw	0x0c	;clear memory locations
	movwf	fsr	;set fsr to lowest address
loop1	clrf	indf
	incf	fsr,f 	;next ram location
	btfss	fsr,5 	;skip if 0x20
	goto	loop1
	movlw	0x10	;initialize display memory
	movwf	fsr	;set fsr to memory location
	movlw	d'4'	;Who says clocks have to start at
	movwf	minl	;12:00???
	movwf	alaminh
	movlw	d'1'
	movwf	hrh
	movwf	alahrh
	movlw	0xff
	movwf	alaflag	;inizialize alarm flag
	bsf	dispsel,4	;initialize display pointer
	clrf	tmr0	;clear timer
	movlw	0xa0	;initialize interrupt
	movwf	intcon	;allow timer overflow
	bsf	dispsel,7	;set flag so main only runs once
main	movlw	b'00001111' ;turn off com cathodes save alarm
	iorwf	porta,f	;change porta
	movlw	b'10000000' ;turn off anodes
	andwf	portb,f	;change portb
	btfsc	dispsel,2	;check if keyscan reached
	call	keyscan	;if set goto keyscan routine
	movlw	b'00011111' ;mask unused bits
	andwf	dispsel,w	;result in w
	movwf	fsr	;prepare indiract addressing
	movf	indf,w	;get display info
	call	pattern	;lookup led pattern
	movwf	portb 	;send pattern to port
	movlw	b'00000011' ;mask bits to ignore
	andwf	dispsel,w	;place digit position in w
	call	digit 	;get digit mask
	andwf	alaflag,w	;get alarm condition
	movwf	porta	;activate digit
	incf	dispsel,f	;increment digit counter
	call	alarmset	;check for alarm condition
delay	btfsc	tmr0,4	;skip if tmr0 bit 4 is clear
	bcf	dispsel,7	;clear flag if tmr0,7 is set
	btfsc	dispsel,7	;skip if flag is clear
	goto	delay 	;do the loop
	btfsc	tmr0,4	;skip if tmr0 bit 4 is clear
	goto	delay 	;do the loop
	bsf	dispsel,7	;set flag
	goto	main	;do main loop
;
;- servicing of keyinput ---------------------------------
;
; this portion will read the key switches and adjust
; time and alarm time accordingly.
;
keyscan	bsf	status,rp0	;switch to bank1
	movlw	b'00011110' ;make rb3 to rb6 inputs
	movwf	trisb
	bcf	status,rp0	;switch to bank0
	andwf	portb,w	;read inputs, w already masked
	movwf	temp	;store input
	bcf	status,c	;clear carry flag
	rlf	temp,f	;shift left to match buffer
	rlf	temp,f
	bsf	status,rp0	;switch to bank1
	clrf	trisb 	;make all rb outputs
	bcf	status,rp0	;switch to bank0
	movf	temp,w	;test stored input
	sublw	b'01111000'	;all high if no key pressed
	btfsc	status,z	;skip next if key pressed
	goto	nokey
;
	movlw	b'01111000'	;eliminate unwanted flags
	andwf	key,w	;get stored key
	subwf	temp,w	;compare with new input
	btfss	status,z	;z clear means new input
	goto	newkey	;service new input
;
	decfsz	debounce,f	;decrement debounce skip if zero
	goto	endkey 	
;
;- adjusting alarm time ----------------------------------
;
	btfsc	temp,3	;skip if alarm button pressed
	goto	dotime	;process time set
	bsf	alaflag,4	;clear alarm	
	bsf	dispsel,3	;show alarm time on display
	btfss	temp,5	;skip if set hour not pressed
	goto	adjahr	;adjust alarm minute
	btfss	temp,6	;skip if set minutes not pressed
	goto	adjamin	;adjust alarm minutes
	goto	setrpt	;just show alarm time
;
adjahr	btfss	temp,6	;adjust hours, skip if min not pressed
	goto	endkey	;invalid input
	incf	alahrl,f 	;increase alarm hour 1's
	btfss	alahrh,0 	;hour total only counts
;			 to 12 skip if alarm hour 10's are 1
	goto	incalahrl	;increase alarm hour low count
	movlw	d'10'	;add d'10' to alarm hour 1's
	addwf	alahrl,w 	;determine if alarm hours reached 12
	sublw	d'13'	;substract 13
	btfss	status,z	;skip if overrun
	goto	incalahrl	;if count <13 increase as usual
	clrf	alahrl	;reset alarm hour 1's
	movlw	0x0a	;reset alarm hour 10's to 0x0a for
	movwf	alahrh	;leading zero blanking
	goto	setrpt
incalahrl	movlw	d'10'	;counts from 0 to 9
	subwf	alahrl,w 	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	alahrl	;reset hour 1's
	movlw	d'1'	;load 1 into hour 10's, can't
	movwf	alahrh	;increase as zero is 0x0a
	goto	setrpt
;
adjamin	incf	alaminl,f	;increase alarm minutes 1's
	movlw	d'10'	;counts from 0 to 9
	subwf	alaminl,w	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	alaminl	;reset alarm minute 1's
	incf	alaminh,f	;increase alarm minutes 10's
	movlw	d'6'	;counts from 0 to 5
	subwf	alaminh,w	;test if count reached 6
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	alaminh	;reset min 10's
	goto	setrpt
;
;- adjust real time --------------------------------------
;
dotime	btfsc	temp,4	;check if time set is pressed
	goto	endkey	;abort if not
	bcf	dispsel,3	;show time on display
	btfss	temp,5	;skip if set hour not pressed
	goto	adjhr	;adjust alarm minute
	btfss	temp,6	;skip if set minutes not pressed
	goto	adjmin	;adjust alarm minutes
	goto	setrpt	;just show alarm time
;
adjhr	btfss	temp,6	;adjust hours, skip if min not pressed
	goto	setrpt	;invalid input
	call	clrsec	;clear seconds
	incf	hrl,f 	;increase alarm hour 1's
	btfss	hrh,0 	;hour total only counts
;			 to 12 skip if alarm hour 10's are 1
	goto	incrhrl	;increase alarm hour low count
	movlw	d'10'	;add d'10' to alarm hour 1's
	addwf	hrl,w 	;determine if alarm hours reached 12
	sublw	d'13'	;substract 13
	btfss	status,z	;skip if overrun
	goto	incrhrl	;if count <13 increase as usual
	clrf	hrl	;reset alarm hour 1's
	movlw	0x0a	;reset alarm hour 10's to 0x0a for
	movwf	hrh	;leading zero blanking
	goto	setrpt
incrhrl	movlw	d'10'	;counts from 0 to 9
	subwf	hrl,w 	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	hrl	;reset hour 1's
	movlw	d'1'	;load 1 into hour 10's, can't
	movwf	hrh	;increase as zero is 0x0a
	goto	setrpt
;
adjmin	call	clrsec	;clear seconds
	incf	minl,f	;increase alarm minutes 1's
	movlw	d'10'	;counts from 0 to 9
	subwf	minl,w	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	minl	;reset alarm minute 1's
	incf	minh,f	;increase alarm minutes 10's
	movlw	d'6'	;counts from 0 to 5
	subwf	minh,w	;test if count reached 6
	btfss	status,z	;skip if overrun
	goto	setrpt
	clrf	minh	;reset min 10's
	goto	setrpt
;
clrsec	clrf	secl	;clear low byte
	clrf	sech	;clear high byte
	return
;
setrpt	movf	debounce,f	;test debounce counter
	btfss	status,z	;skip if debounce is 0
	goto	endkey
	movlw	0x14	;load new value into debounce
	movwf	debounce	;to repeat pressed keys
	goto	endkey
;
newkey	movlw	b'10000111' ;mask unwanted
	andwf	key,w 	;get key buffer
	iorwf	temp,w	;merge with stored input
	movwf	key	;store keypressed
	movlw	0x03	;set counter
	movwf	debounce	;to approx. 50ms
	goto	endkey
;
nokey	clrf	key	;clear key buffer
	bcf	dispsel,3	;clear display alarm flag
endkey	bcf	dispsel,2	;reset digit pointer
	return
;
;- lookup tables for display drive -----------------------
;
pattern	addwf	pcl,f 	;add offset to program counter
	retlw	b'10111111' ;pattern for 0
	retlw	b'10000110' ;pattern for 1
	retlw	b'11011011' ;pattern for 2
	retlw	b'11001111' ;pattern for 3
	retlw	b'11100110' ;pattern for 4
	retlw	b'11101101' ;pattern for 5
	retlw	b'11111101' ;pattern for 6
	retlw	b'10000111' ;pattern for 7
	retlw	b'11111111' ;pattern for 8
	retlw	b'11101111' ;pattern for 9
	retlw	b'10000000' ;pattern for blank 0x0a
;
digit	addwf	pcl,f 	;add offset to program counter
	retlw	b'11111110' ;pattern for hour 10's
	retlw	b'11111101' ;pattern for hour 1's
	retlw	b'11111011' ;pattern for min 10's
	retlw	b'11110111' ;pattern for min 1's
;
;- check if alarm occured --------------------------------
;
alarmset	movf	hrh,w	;get time and compare
	subwf	alahrh,w	;with alarm set
	btfss	status,z	;if equal skip
	return
	movf	hrl,w	;same with hour 1's
	subwf	alahrl,w
	btfss	status,z	;if equal skip
	return
	movf	minh,w	;same with minute 10's
	subwf	alaminh,w
	btfss	status,z	;if equal skip
	return
	movf	minl,w	;same with minute 1's
	subwf	alaminl,w
	btfss	status,z	;if equal skip
	return
	bcf	alaflag,4	;set flag for alarm
	return		;Note that output
;			 is active low!
;			 I had use a flag for
;			 porta,4 because it's an
;			 open drain. Once alarm was
;			 on, a read would result in
;			 a zero read. BSF simply
;			 kept the pin low!
;
;- interrupt servicing -----------------------------------
;
; increases time on every counter overflow
; seconds locations are not seconds but updated
; every 32.768ms. A second count of 1831 equals
; 1 minute.
;
inctime	movwf	temp_w	;save contents of w
	swapf	status,w	;swap status doesn't affect status bits
	movwf	temp_s	;save contents of status register
	bcf	status,rp0	;switch to bank 0 just in case
	call	checksec	;call subroutine to check if minute is reached
	btfsc	status,z	;skip if overrun
	goto	minute	;seconds reached top limit
	incfsz	secl,f	;increase seconds skip if secl overrun
	goto	intdone
	incf	sech,f	;increase seconds high byte
	goto	intdone
;
minute	clrf	secl	;reset sec high byte
	clrf	sech	;clear sec high byte
	incf	minl,f	;increase minutes 1's
	movlw	d'10'	;counts from 0 to 9
	subwf	minl,w	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	intdone
	clrf	minl	;reset minute 1's
	incf	minh,f	;increase minutes 10's
	movlw	d'6'	;counts from 0 to 5
	subwf	minh,w	;test if count reached 6
	btfss	status,z	;skip if overrun
	goto	intdone
	clrf	minh	;reset min 10's
	incf	hrl,f 	;increase hour 1's
	btfss	hrh,0 	;hour total only counts
;			 to 12 skip if hour 10's are 1
	goto	inchrl	;increase hour low count
	movlw	d'10'	;add d'10' to hour 1's
	addwf	hrl,w 	;determine if hours reached 12
	sublw	d'13'	;substract 13
	btfss	status,z	;skip if overrun
	goto	inchrl	;if count <13 increase as usual
	clrf	hrl	;reset hour 1's
	movlw	0x0a	;reset hour 10's to 0x0a for
	movwf	hrh	;leading zero blanking
	goto	intdone
inchrl	movlw	d'10'	;counts from 0 to 9
	subwf	hrl,w 	;test if count reached 10
	btfss	status,z	;skip if overrun
	goto	intdone
	clrf	hrl	;reset hour 1's
	movlw	d'1'	;load 1 into hour 10's, can't
	movwf	hrh	;increase as zero is 0x0a
	goto	intdone
;
checksec	movlw	b'00100111' ;maximum sec low byte count
	subwf	secl,w	;test if count reached limit
	btfss	status,z	;skip if overrun
	return
	movlw	b'00000111' ;maximum sec high byte count
	subwf	sech,w	;test if count reached limit
	return
;
intdone	bcf	intcon,t0if	;clear tmr0 interrupt flag
	swapf	temp_s,w	;get contents of status
	movwf	status	;restore status register
	swapf	temp_w,f	;prepare to restore
	swapf	temp_w,w	;get contents of w
	retfie		;return from interrupt
;
	end




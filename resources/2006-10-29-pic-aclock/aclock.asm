;= Analog Clock ===========================================================
;
; 'Semi-analog' clock with 60 red LED's arranged in a cirle for minutes
; and 16 green LED's arranged in a larger circle for hour indication.
;
; I used the PIC16C73 simply because it was on hand. The PIC16C63 should
; work just as well since no A/D converter is needed.
;
; Pin assignment:
;
; RB0/INT   AC detect input, low on AC present
; RB1-7     LED rows 2 to 8 (LED Anodes)
; RB1       Up Key - to set time, keys are high active
; RB2       Down Key - to set time, keys are high active
; RA0-5     LED columns 1 to 6 (LED Kathodes)
; RC2-5     LED columns 7 to 10 (LED Kathodes)
; RC7       LED row 1 (LED Anodes)
; RC0,1     TMR1 oscillator
;
; The interrupt service routine is executed by either a TMR1 overflow
; or RB0 rising edge. TMR1 overflow simply increments the various time
; registers. A RB0 interrupt indicates loss of AC power. The display
; will be blanked immediately and RB0 will be polled for return of
; power. PIC will be put to sleep until power returns except for
; wake-ups from TMR1 to keep time advancing.
;
; Main routine drives display and sets the time if keys are pressed.
;
; Adi Linden, 98-07-17
;
;--------------------------------------------------------------------------

;  #define	debug
  errorlevel	0,-302
  list	p=16c73a
  page
  include	"16c73a.inc"
  radix	dec
  __config	_cp_off & _wdt_off & _xt_osc & _pwrte_on & _BODEN_OFF

;- equates ----------------------------------------------------------------

fast_dly    equ         75          ;keyboard repeat timing

;- registers --------------------------------------------------------------

  cblock 0x20

sec_c                               ;keeps seconds count (inc every 2 sec)
min_c                               ;keeps minutes count
hr_c                                ;keeps hour count

new_key                             ;stores newly read key input
old_key                             ;stores prev. read key for debounce
repeat                              ;variable for auto-repeat

w_temp                              ;saves w content during interrupt
s_temp                              ;saves status content during interrupt

mpx                                 ;multiplex
                                    ; 0 --> show minutes
                                    ; 1 --> show current hour
                                    ; 2 --> show next hour
                                    ; 3 --> show second hour LED
buffa                               ;port a buffer
buffb                               ;port b buffer
buffc                               ;port c buffer
shift                               ;temporary register

  endc

;- set vectors ------------------------------------------------------------

  org	0x000
  goto	start
  org	0x004
  goto	interrupt		;interrupt service routine

;- lookup tables ----------------------------------------------------------

mpx_table
  addwf     pcl,f
  goto      show_minute
  goto      show_hour
  goto      show_double
  goto      show_seconds

pattern_table
  addwf     pcl,f
  retlw     b'00000001'
  retlw     b'00000010'
  retlw     b'00000100'
  retlw     b'00001000'
  retlw     b'00010000'
  retlw     b'00100000'
  retlw     b'01000000'
  retlw     b'10000000'

;- start of main routine --------------------------------------------------

start                               ;begin of program
  movlw     b'00111111'             ;intitialize ports
  movwf     porta
  clrf      portb
  movlw     b'00111100'
  movwf     portc
  bsf       status,rp0              ;switch to bank 1
  movlw     b'00000111'             ;configure adcon1
  movwf     adcon1                  ;16C73a makes porta analog in
  movlw     b'11000000'             ;porta all outputs
  movwf     trisa
  movlw     b'00000001'             ;portb 0 is input remainder output
  movwf     trisb
  movlw     b'00000011'             ;portc 0,1 input, remainder output
  movwf     trisc
  movlw     b'11010010'             ;configure tmr0 overflow @ 2ms
  movwf     option_reg              ;1:8 prescaler
  bsf       pie1,tmr1ie             ;enable tmr1 overflow interrupt
  bcf       status,rp0              ;switch to bank 0
  clrf      tmr0                    ;clear tmr0 register
  clrf      tmr1l                   ;clear tmr1 registers
  clrf      tmr1h
  movlw     b'00001111'             ;configure tmr1
  movwf     t1con
  bcf       pir1,tmr1if             ;clear tmr1 overflow flag
  movlw     b'01010000'             ;configure intcon
  movwf     intcon
  clrf      sec_c                   ;clear time keeping registers
  clrf      min_c
  clrf      hr_c
  clrf      old_key                 ;clear key buffer
  clrf      mpx                     ;clear multiplex counter

main_routine                        ;start of main routine
  bcf       intcon,t0if             ;clear tmr0 overflow

gie_loop
  bcf       intcon,gie              ;disable global interrupt
  btfsc     intcon,gie              ;confirm clearing of gie
   goto     gie_loop                ;try again
  call      read_kb                 ;read and execute key input
  bsf       intcon,gie              ;enable global interrupt
  call      show_time               ;set output to show time

tmr0_loop
ifndef   debug
  btfss     intcon,t0if             ;wait for timer overflow
   goto     tmr0_loop               ;loop until tmr0 expires
endif
  goto      main_routine

;- display time --- -------------------------------------------------------

show_time                           ;convert and display time
  clrf      shift                   ;clear shift variable
  clrf      buffa                   ;clear port buffers
  clrf      buffb
  clrf      buffc
  incf      mpx,f                   ;advance mpx
  movlw     0x04                    ;check for overflow
  subwf     mpx,w
  btfsc     status,z
   clrf     mpx                     ;reset mpx count
  movf      mpx,w
  call      mpx_table               ;lookup what to show
  comf      buffa,w                 ;invert bit pattern
  andlw     b'00111111'             ;mask output
  movwf     porta                   ;write to port
  comf      buffc,w                 ;invert bit pattern
  andlw     b'11111100'             ;mask output
  movwf     portc                   ;write to port
  bcf       portc,7                 ;do not invert bit7 of portc
  btfsc     buffc,7                 ;it's driving rows
   bsf      portc,7
  movf      buffb,w                 ;get bit pattern
  andlw     b'11111110'             ;mask output
  movwf     portb                   ;write to port
  return

show_minute                         ;calculates and displays minute
  movf      min_c,w                 ;get minutes
  movwf     shift                   ;prepare shift for column calc
  andlw     b'00000111'             ;get row
  call      pattern_table           ;get output pattern
  movwf     buffb                   ;write to buffer
  btfsc     buffb,0                 ;bit0 set?
   bsf      buffc,7                 ;set row0 location
  movlw     b'00111000'             ;get column
  andwf     shift,f                 ;mask unwanted
  bcf       status,c                ;clear carry to prepare for shift
  rrf       shift,f                 ;shift right 3 times
  rrf       shift,f
  rrf       shift,w
  call      pattern_table           ;get output pattern
  movwf     buffa                   ;write to buffer
  btfsc     buffa,6                 ;bit6 set?
   bsf      buffc,2                 ;set col7 location
  btfsc     buffa,7                 ;bit7 set?
   bsf      buffc,3                 ;set col8 location
  return

show_hour                           ;calculates and displays hour
  movf      hr_c,w                  ;get hour
  andlw     b'00000111'             ;get row
  call      pattern_table           ;get output pattern
  movwf     buffb                   ;write to buffer
  btfsc     buffb,0                 ;bit0 set?
   bsf      buffc,7                 ;set row0 location
  btfss     hr_c,3                  ;set proper column
   bsf      buffc,4                 ;hour<9
  btfsc     hr_c,3
   bsf      buffc,5                 ;hour>8
  return

show_double                         ;some hours have 2 LED's
  movf      hr_c,w                  ;get hours
  sublw     0
  btfsc     status,z
   bsf      buffb,4                 ;write buffer if hours=0
  movf      hr_c,w
  sublw     3
  btfsc     status,z
   bsf      buffb,5                 ;write buffer if hours=3
  movf      hr_c,w
  sublw     6
  btfsc     status,z
   bsf      buffb,6                 ;write buffer if hours=6
  movf      hr_c,w
  sublw     9
  btfsc     status,z
   bsf      buffb,7                 ;write buffer if hours=9
  bsf       buffc,5                 ;write column to buffer
  return

show_seconds                        ;flashes center LED's in 2 sec rythm
  btfsc     sec_c,0                 ;test seconds register
   bsf      buffb,6                 ;light one LED if sec LSB set
  btfss     sec_c,0
   bsf      buffb,7                 ;light other LED if sec LSB clear
  bsf       buffc,3
  return
  
;- read key input and set time --------------------------------------------

read_kb                             ;read key input
  clrf      portb                   ;turn lights off
  movlw     b'00111111'
  movwf     porta
  movlw     b'00111100'
  movwf     portc
  bsf       status,rp0              ;switch to bank 1
  movlw     b'00000111'             ;make certain pins input
  movwf     trisb
  bcf       status,rp0              ;switch to bank 0
  movlw     b'00000110'             ;mask inputs
  andwf     portb,w                 ;read portb
  movwf     new_key                 ;save input
  bsf       status,rp0              ;switch to bank 1
  movlw     b'00000001'             ;restore portb settings
  movwf     trisb
  bcf       status,rp0              ;switch to bank 0
  movf      new_key,w               ;get input read
  btfsc     status,z                ;any key presssed?
   goto     no_key
  subwf     old_key,w               ;compare with previous input
  btfsc     status,z
   goto     no_key
  decfsz    repeat,f                ;advance repeat counter
   return                           ;all done if not expired
  movlw     fast_dly                ;set repeat time
  movwf     repeat
  btfsc     new_key,1               ;down key pressed?
   goto     dec_time                ;set clock backwards
  clrf      sec_c                   ;clear seconds
  incf      min_c,f                 ;advance minutes
  movlw     60                      ;check for overflow
  subwf     min_c,w
  btfss     status,z
   return
  clrf      min_c                   ;reset minutes
  incf      hr_c,f                  ;advance hours
  movlw     12                      ;check for overflow
  subwf     hr_c,w
  btfss     status,z
   return
  clrf      hr_c                    ;reset hours
  return

dec_time                            ;set clock backwards
  clrf      sec_c                   ;clear seconds
  decf      min_c,f                 ;advance minute
  movlw     0xff                    ;check for overflow
  subwf     min_c,w
  btfss     status,z
   return
  movlw     59                      ;reset minutes
  movwf     min_c
  decf      hr_c,f                  ;advance hours
  movlw     0xff                    ;check for overflow
  subwf     hr_c,w
  btfss     status,z
   return
  movlw     11                      ;reset hours
  movwf     hr_c
  return

no_key                              ;exit when no input
  movf      new_key,w               ;make new key the old key
  movwf     old_key                 ;to debounce
  movlw     0x01                    ;set repeat counter for
  movwf     repeat                  ;immediate action next time
  return

;- interrupt routine ------------------------------------------------------

interrupt                           ;interrupt service routine
  movwf     w_temp                  ;save w register
  swapf     status,w                ;save status register
  movwf     s_temp                  ;no bank switching in main routine!

sleep_loop
  btfsc     intcon,intf             ;rb0/int flag set?
   call     power_down              ;yes, power down
  btfsc     pir1,tmr1if             ;tmr1 overflow?
   call     inc_time                ;yes, increment time
  btfsc     portb,0                 ;rb0 set indicated no ac power
   goto     sleep_cont
  swapf     s_temp,w                ;restore status register
  movwf     status
  swapf     w_temp,f                ;restore w register
  swapf     w_temp,w
  retfie                            ;return from interrupt

power_down                          ;kill lights to preserve energy
  bcf       intcon,intf             ;clear external interrupt flag
  clrf      portb                   ;turn off rows and columns
  movlw     b'00111100'
  movwf     portc
  movlw     b'00111111'
  movwf     porta
  return

inc_time                            ;increments time
  bcf       pir1,tmr1if             ;clear tmr1 overflow interrupt
  incf      sec_c,f                 ;increment seconds
  movlw     30                      ;one count every 2 seconds
  subwf     sec_c,w                 ;test seconds for overflow
  btfss     status,z
   return
  clrf      sec_c                   ;reset seconds
  incf      min_c,f                 ;increment minutes
  movlw     60
  subwf     min_c,w                 ;test minutes for overflow
  btfss     status,z
   return
  clrf      min_c                   ;reset minutes
  incf      hr_c,f                  ;increment hours
  movlw     12                      ;analog clock has only 12 hours
  subwf     hr_c,w
  btfss     status,z
   return
  clrf      hr_c                    ;reset hours
  return

sleep_cont                          ;continue sleeping
  sleep                             ;put processor to sleep
  goto      sleep_loop              ;service interrupt routine on wake-up

;- Revisions --------------------------------------------------------------
;
; 98-07-28 -Corrected table to store offset PCL in file register not w.
;           This solved all problems! Future idea, make display more
;           redeable by lighting up current and next hour at 20 minutes
;           past the hour and show next hours only at 45 minutes past the
;           hour.
; 98-07-26 -Finished assembling circuit, began debug. Clock won't advance
;           hours or minutes. Stuck at 12 o'clock.
; 98-07-17 -The beginning...

  end

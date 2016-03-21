;= Room Thermostat ========================================================
;
; This program implements a room thermostat. A Dallas DS1621 and a Dallas
; DS1307 are connected to Port A and a 2x20 LCD is connected to Port B.
; The low and high temperatures are saved in realtime clock RAM.
;
; DS1621 is initialized for one-shot operation to minimize self heating
; and reduce power consumption. Conversion takes approx. 10ms. Check 'DONE'
; bit in configuration register before read.
;
; Utilizes tmr0 to time execution of subroutines. However, delay times and
; I2C timing are done in software and optimized for a 4MHz crystal.
;
; Future enhancement ideas:
;
;   2 wire interface to Heating Controller to optimize boiler firing times
;
; New code done:
;
;   I2C master to communicate with DS1621 temperature sensor
;   I2C master to communicate with DS1307 real-time clock
;   4-bit communication with LCD display
;
; Adi Linden, 98-03-14
;
;--------------------------------------------------------------------------

;  #define    debug
  errorlevel 0,-302
  list       p=16f84
  page
  include    "16f84adi.inc"
  radix      dec
  __config   _cp_off & _wdt_off & _xt_osc

;- equates ----------------------------------------------------------------

i2c_sda      equ  0           ;i2c data pin
i2c_scl      equ  1           ;i2c clock pin
i2c_port     equ  porta       ;define port used for i2c communications
i2c_tris     equ  trisa

ds1621_w     equ  b'10011110' ;DS1621 write address
ds1621_r     equ  b'10011111' ;DS1621 read address
ds1621_time  equ  0x50        ;temperature read cycle - 65ms increments

ds1307_w     equ  b'11010000' ;DS1307 write address
ds1307_r     equ  b'11010001' ;DS1307 read address
ds1307_time  equ  0x09        ;time & thermostat control read cycle - 65ms inc
ds1307_sec   equ  0x00        ;register address for seconds
ds1307_min   equ  0x01        ;register address for minutes
ds1307_hr    equ  0x02        ;register address for hours
ds1307_ch    equ  7           ;clock halt bit 0=clock enabled
ds1307_ampm  equ  6           ;12-hour 24-hour bit 0=24 hour mode
ds1307_span  equ  0x10        ;saved span location
ds1307_setp  equ  0x11        ;saved setpoint location
ds1307_err   equ  3           ;error flag for improper data reads

lcd_port     equ  portb       ;define port for lcd
lcd_e        equ  5           ;lcd data enable pin (0 to 1 loads data)
lcd_rs       equ  4           ;lcd register select pin (0 sends instr.)

kb_port      equ  portb       ;define port for keyboard
kb_tris      equ  trisb
kb_in        equ  b'00001111' ;port pins used for keyboard read
kb_scan      equ  6           ;port bit for keyboard scan
kb_mode      equ  3           ;port pin for mode key
kb_down      equ  2           ;port pin for down key
kb_up        equ  1           ;port pin for up key
kb_repeat    equ  0x04        ;auto-repeat time - 65ms increments

                              ;flags set on key press
new_mode     equ  2           ;flag set if mode key
new_up       equ  1           ;flag set if up key
new_down     equ  0           ;flag set if down key
new_time     equ  0xaa        ;timeout of display in 65ms inc

l_temp       equ  7           ;flag set if 1/2 degree

low_lim      equ  5           ;flag for low limit status
high_lim     equ  6           ;flag for high limit status
                              ; 5 | 6
                              ; 0 | 0  room below low + high limits
                              ; 1 | 0  room above low, below high limit
                              ; 1 | 1  room above low + high limits
                              ; 0 | 1  better not be true!

setpoint_l   equ  10          ;lowest allowable setpoint
setpoint_h   equ  30          ;highest allowable setpoint + 1
setspan_l    equ  1           ;lowest allowable span
setspan_h    equ  4           ;highest allowable span + 1

;- registers --------------------------------------------------------------


  cblock 0x0c
                   
h_temp                        ;temperature (binary)
                              ; 1/10 in flags
setpoint                      ;thermostat setting (binary)
setspan                       ;thermostat span (low limit=setpoint-setspan)

time_hr                       ;hours read from ds1307 (bcd)
time_min                      ;minutes read from ds1307 (bcd)

cnt                           ;count variable, local use
ds1307_dly                    ;times ds1307 reads
ds1621_dly                    ;timer ds1621 reads
timeout                       ;counter for display timeout

dly_1                         ;delay counters used by delay routines
dly_2
flags                         ;flags
                              ;bit 0 --> up key flag
                              ;bit 1 --> down key flag
                              ;bit 2 --> mode key flag
                              ;bit 3 --> ds1307 read errors
                              ;bit 4 --> lcd_rs status
                              ;bit 5 --> low limit status
                              ;bit 6 --> high limit status
                              ;bit 7 --> l_temp

mode                          ;Unit mode
                              ; 0x00 --> main screen
                              ; 0x01 --> set thermostat
                              ; 0x02 --> set span
                              ; 0x03 --> set minutes
                              ; 0x04 --> set hours
                              ; 0x05 --> about

i2c_rcv                       ;receive i2c byte
i2c_snd                       ;send i2c byte

ds1307_addr                   ;register address
ds1307_data                   ;data read or written

adjust                        ;contains value being adjusted in set modes
lcd_sav                       ;temporary storage used by LCD

bin2bcd                       ;variables for binary to bcd conversion
bcd                           ;same as above

kb_deb                        ;debounce key
kb_sav                        ;temporary storage for keypress
kb_dly                        ;repeat counter for key presses

  endc

;- set vectors ------------------------------------------------------------

  org        0x000
  goto       start
  org        0x004
  goto       start            ;interrupt service routine

;- lookup tables ----------------------------------------------------------

lcd_msg_table                 ;points to message location
  addwf pcl,f
  goto       msg_0
  goto       msg_1
  goto       msg_2
  goto       msg_3
  goto       msg_4
  goto       msg_5

msg_0                         ;main screen
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," ",0x13,0xdf,"C at ",0x18,":",0x19," "
  dt         0x11," ",0x16,"L ",0x17,"H set at ",0x14,0xdf,"C",0x10

msg_1
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," ",0x13,0xdf,"C at ",0x18,":",0x19," "
  dt         0x11,"Thermostat: ",0x1b,"      ",0x10

msg_2
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," ",0x13,0xdf,"C at ",0x18,":",0x19," "
  dt         0x11,"Adj. Span: ",0x1b," ",0x10

msg_3
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," ",0x13,0xdf,"C at ",0x18,":",0x19," "
  dt         0x11,"Adj. Minutes: ",0x1a,0x10

msg_4
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," ",0x13,0xdf,"C at ",0x18,":",0x19," "
  dt         0x11,"Adj. Hours: ",0x1a,"   ",0x10

msg_5
  movf       cnt,w
  addwf      pcl,f
  dt         0x12," By Adi Linden     "
  dt         0x11," July 8, 1998      ",0x10

lcd_ins_table                 ;inserts variables into display
  movlw      b'00001111'      ;get command
  andwf      lcd_sav,w
  addwf      pcl,f
  goto       lcd_ins_end      ;0x10 --> end of message
  goto       lcd_ins_cr       ;0x11 --> carriage return --> begin of second line
  goto       lcd_ins_home     ;0x12 --> cursor home
  goto       lcd_ins_temp     ;0x13 --> insert current room temperature
  goto       lcd_ins_hset     ;0x14 --> insert thermostat setting
  goto       lcd_ins_span     ;0x15 --> insert thermostat span
  goto       lcd_ins_low      ;0x16 --> insert low status
  goto       lcd_ins_high     ;0x17 --> insert high status
  goto       lcd_ins_hr       ;0x18 --> insert hours
  goto       lcd_ins_min      ;0x19 --> insert minutes
  goto       lcd_ins_adj_bcd  ;0x1a --> insert adjustment variable bcd format
  goto       lcd_ins_adj_bin  ;0x1b --> insert adjustment variable binary

mode_table
  movlw      new_time
  movwf      timeout
  movf       mode,w
  addwf      pcl,f
  goto       mode_0
  goto       mode_1
  goto       mode_2
  goto       mode_3
  goto       mode_4
  goto       mode_5


;- start of main routine --------------------------------------------------

start                         ;start of main program
  movlw      b'11110000'      ;initialize ports
  movwf      portb
  movlw      b'11111100'
  movwf      porta
  bsf        status,rp0       ;switch to bank 1
  clrf       trisb            ;portb all outputs
  movlw      0xe3             ;ra0 & ra1 inputs
  movwf      trisa
  movlw      b'11010111'      ;assign prescaler and enable tmr0
  movwf      option_reg
  bcf        status,rp0       ;switch to bank 0
  clrf       flags            ;init flags
  bsf        flags,low_lim
  bsf        flags,high_lim
  movlw      kb_in
  movwf      kb_sav           ;init with no key press
  movlw      ds1621_time      ;init delays
  movwf      ds1621_dly
  movlw      ds1307_time
  movwf      ds1307_dly
  movlw      new_time
  movwf      timeout
  movlw      0x05             ;init mode
  movwf      mode
ifndef   debug
  call       lcd_init         ;initialize LCD
  call       lcd_write_message
  call       config_ds1621    ;configure DS1621
  call       start_conversion ;get first temperature reading ready
  call       read_time        ;initialize registers from ds1307 stored values
  btfsc      flags,ds1307_err ;any errors reading ds1307?
   call      init_time        ;yes, load default values in ds1307

first_temp_read
  call       read_config      ;get conversion complete flag
  btfss      i2c_rcv,7        ;loop until conversion complete
   goto      first_temp_read
  call       read_temperature ;read temperature
endif
  clrf       tmr0             ;init timer

main_routine
  call       kb_read          ;check for key input
  movlw      b'00000111'      ;mask input flags
  andwf      flags,w          
  btfss      status,z         ;any new key input flags set?              
   call      mode_table       ;yes, do key function
  bcf        flags,new_mode   ;clear key function flags
  bcf        flags,new_up
  bcf        flags,new_down
  call       lcd_write_message

timer_delay
  btfss      intcon,t0if      ;test timer overflow
   goto      timer_delay

  bcf        intcon,t0if      ;clear timer overflow
  decfsz     ds1307_dly,f     ;dec count, skip if 0
   goto      get_temperature
  movlw      ds1307_time      ;set time period for DS1307 reads
  movwf      ds1307_dly
  call       read_time        ;get time & register data from ds1307

;
; control outputs
;

get_temperature
  decfsz     ds1621_dly,f     ;get temperature if count exceeded
   goto      get_timeout
  movlw      ds1621_time      ;set time period for temperature reads
  movwf      ds1621_dly
  call       read_config      ;get conversion complete flag, error if clr
  movlw      0x05
  btfss      i2c_rcv,7
   movwf     mode
  call       read_temperature ;get temperature and initiate conversion
  call       start_conversion

get_timeout
  decfsz     timeout,f        ;dec timeout timer, skip if 0
   goto      main_routine        
  movlw      new_time         ;reset timeout value
  movwf      timeout
  clrf       mode             ;specify mode
  goto       main_routine


mode_0                        ;main screen key execution
  incf       mode,f           ;new mode, set thermostat
  movf       setpoint,w       ;load thermostat setting in adjust variable
  movwf      adjust
  return
  

mode_1                        ;set thermostat
  btfsc      flags,new_up
   incf      adjust,f         ;increment adjust if up pressed
  btfsc      flags,new_down
   decf      adjust,f         ;decrement adjust if down pressed
  movlw      setpoint_l
  subwf      adjust,w
  btfss      status,c         ;is adjust > lowest allowable value?
   incf      adjust,f         ;no, increment adjust
  movlw      setpoint_h
  subwf      adjust,w
  btfsc      status,c         ;is adjust < highest allowable value?
   decf      adjust,f         ;no, decrement adjust
  movlw      ds1307_setp      ;save thermostat setting
  movwf      ds1307_addr
  movf       adjust,w
  movwf      ds1307_data      ;in ds_1307 RAM
  movwf      setpoint 
  call       write_ds1307
  btfss      flags,new_mode   ;mode pressed?
   return                     ;no, done here!
  incf       mode,f           ;set new mode
  movf       setspan,w        ;load new value to adjust
  movwf      adjust
  return


mode_2                        ;set span
  btfsc      flags,new_up
   incf      adjust,f         ;increment adjust if up pressed
  btfsc      flags,new_down
   decf      adjust,f         ;decrement adjust if down pressed
  movlw      setspan_l
  subwf      adjust,w
  btfss      status,c         ;is adjust > lowest allowable value?
   incf      adjust,f         ;no, increment adjust
  movlw      setspan_h
  subwf      adjust,w
  btfsc      status,c         ;is adjust < highest allowable value?
   decf      adjust,f         ;no, decrement adjust
  btfss      flags,new_mode   ;mode pressed?
   return                     ;no, done here!
  movlw      ds1307_span      ;save setpoint setting
  movwf      ds1307_addr
  movf       adjust,w
  movwf      ds1307_data
  movwf      setspan
  call       write_ds1307
  incf       mode,f           ;set new mode
  movf       time_min,w       ;load new value to adjust
  movwf      adjust
  return


mode_3                        ;set minutes
  call       change_adjust_bcd
  movf       adjust,w
  sublw      0xf9
  btfsc      status,z         ;w = 0 - 1?
   call      mode_3_59        ;force 59
  movf       adjust,w
  sublw      0x60
  btfsc      status,z         ;w = 60?
   clrf      adjust           ;force 0
  btfss      flags,new_mode   ;mode pressed?
   return                     ;no, done here!
  movlw      ds1307_min       ;save setpoint setting
  movwf      ds1307_addr
  movf       adjust,w
  movwf      ds1307_data
  movwf      time_min
  call       write_ds1307
  incf       mode,f           ;set new mode
  movf       time_hr,w       ;load new value to adjust
  movwf      adjust
  return
mode_3_59                     ;set adjust to 59
  movlw      0x59
  movwf      adjust
  return


mode_4                        ;set hours
  call       change_adjust_bcd
  movf       adjust,w
  sublw      0xf9
  btfsc      status,z         ;w = 0 - 1?
   call      mode_4_23        ;force 23
  movf       adjust,w
  sublw      0x24
  btfsc      status,z         ;w = 24?
   clrf      adjust           ;force 0
  btfss      flags,new_mode   ;mode pressed?
   return                     ;no, done here!
  movlw      ds1307_hr        ;save setpoint setting
  movwf      ds1307_addr
  movf       adjust,w
  movwf      ds1307_data
  movwf      time_hr
  call       write_ds1307
  clrf       mode             ;set new mode
  return
mode_4_23                     ;set adjust to 23
  movlw      0x23
  movwf      adjust
  return


mode_5                        ;about screen
  btfss      flags,new_mode   ;mode pressed?
   return                     ;no, done here!
  clrf       mode             ;set new mode
  return


change_adjust_bcd             ;changes adjust according to key input
  btfsc      flags,new_up
   call      inc_adjust       ;increment adjust if up pressed
  btfsc      flags,new_down
   call      dec_adjust       ;decrement adjust if down pressed
  return
   
   
inc_adjust                    ;increment adjust (bcd value)
  movlw      0x07         
  addwf      adjust,w         
  btfss      status,dc        ;low nibble > 9?
   goto      inc_adjust_low   ;no, inc low nibble
  swapf      adjust,f         ;yes, inc high nibble
  incf       adjust,f
  swapf      adjust,f
  movlw      b'11110000'      ;make low nibble 0
  andwf      adjust,f
  return
inc_adjust_low
  incf       adjust,f         ;increment low nibble
  return
  

dec_adjust                    ;decrement adjust (bcd value)
  movlw      0x0f             ;get lowest low nibble
  addwf      adjust,w
  btfsc      status,dc        ;low nibble > 0?
   goto      dec_adjust_low   ;yes, dec low nibble
  swapf      adjust,f         ;no, dec high nibble
  decf       adjust,f
  swapf      adjust,w
  andlw      b'11110000'      ;make low nibble 9
  iorlw      b'00001001'
  movwf      adjust
  return
dec_adjust_low
  decf       adjust,f         ;decrement low nibble
  return
  

;- Keyboard Routines ------------------------------------------------------

kb_sample                     ;samples kb
                              ;exit with masked result in w
  movlw      kb_in            ;get mask
  bsf        status,rp0       ;bank 1
  movwf      kb_tris          ;make input to prepare for read
  bcf        status,rp0       ;bank 0
  bcf        kb_port,kb_scan  ;pull common low
  andwf      kb_port,w        ;read & condition - mask still in w
  bsf        kb_port,kb_scan  ;set common high
  bsf        status,rp0       ;bank 1
  clrf       kb_tris          ;return to all outputs
  bcf        status,rp0       ;bank 0
  return                      ;return with masked value in w


kb_read                       ;processes key input
                              ;exit with flags set according to keys pressed
  call       kb_sample        ;get key input
  movf       kb_deb,f         ;test kb_deb
  btfss      status,z
   goto      kb_debounce
  movwf      kb_deb           ;store key read
  return                      ;debounce on next execution

kb_debounce
  subwf      kb_deb,w         ;compare reads
  btfss      status,z         ;skip if key input valid
   goto      kb_done
  movf       kb_deb,w         ;is input new?
  subwf      kb_sav,w
  btfss      status,z
   goto      kb_do_key        ;if new process input
  decfsz     kb_dly,f         ;if no decrement repeat timer
   goto      kb_done          ;done if not timed out
kb_do_key
  movlw      kb_repeat        ;set auto-repeat time
  movwf      kb_dly
  movf       kb_deb,w         ;save key input in case it's new
  movwf      kb_sav
  btfss      kb_sav,kb_mode   ;test mode key input
   goto      kb_set_mode
  btfss      kb_sav,kb_down   ;test down key input
   bsf       flags,new_down
  btfss      kb_sav,kb_up     ;test up key input
   bsf       flags,new_up
                              ;if all keys high no key was pressed
kb_done
  clrf       kb_deb
  return

kb_set_mode                   ;do not allow mode and another key at a time
  bsf        flags,new_mode
  bcf        flags,new_up
  bcf        flags,new_down
  goto       kb_done


;- LCD Routines -----------------------------------------------------------
;
; Note: Routine does not read busy flag. Assuming worst case scenario there
;       is a 160us after writes except clear display and courser home.
;
;--------------------------------------------------------------------------

lcd_write_message             ;writes message to display
                              ;message to show in mode
  clrf       cnt
lcd_next_char
  movf       mode,w           ;get message pointer
  call       lcd_msg_table
  incf       cnt,f
  movwf      lcd_sav          ;save read character
  andlw      b'11110000'      ;determine if character or insert command
  xorlw      b'00010000'
  btfsc      status,z
   goto      lcd_ins_table    ;if insert command do so
  movf       lcd_sav,w
  call       lcd_snd_data
  goto       lcd_next_char


lcd_ins_end                   ;end of message
  return


lcd_ins_cr                    ;begining of next 2nd line
  movlw      0xc0
  call       lcd_snd_ins
  goto       lcd_next_char


lcd_ins_home                  ;send cursor home
  movlw      0x80
  call       lcd_snd_ins
  goto       lcd_next_char


lcd_ins_temp                  ;insert current room temperature
  movf       h_temp,w         ;get temperature
  call       bin2bcd_100      ;get 100's
  movf       bin2bcd,w
  call       bin2bcd_10       ;get 10's
  movf       bcd,w
  iorlw      0x30
  call       lcd_snd_data     ;send 10's
  movf       bin2bcd,w        ;get 1's
  iorlw      0x30
  call       lcd_snd_data     ;send 1's
  movlw      0x2e
  call       lcd_snd_data     ;send decimal point
  movlw      0x30
  btfss      flags,l_temp     ;send 0 if l_flag clear
   call      lcd_snd_data
  movlw      0x35
  btfsc      flags,l_temp     ;send 5 if l_flag set
   call      lcd_snd_data
  goto       lcd_next_char


lcd_ins_hr                    ;insert hours
  btfss      flags,ds1307_err ;insert '!' if error flag set
   goto      lcd_ins_hr_high
  movlw      0x21
  call       lcd_snd_data
lcd_ins_hr_high
  swapf      time_hr,w        ;get high nibble only
  andlw      0x0f
  btfsc      status,z         ;skip if hour ten's 0
   goto      lcd_blank_hr     ;blank leading 0
  iorlw      0x30
  call       lcd_snd_data     ;send hour ten's
lcd_ins_hr_low
  movf       time_hr,w        ;get low nibble only
  andlw      0x0f
  iorlw      0x30
  call       lcd_snd_data     ;send hour one's
  goto       lcd_next_char

lcd_blank_hr
  movlw      0x20             ;blank leading 0
  call       lcd_snd_data     ;send space
  goto       lcd_ins_hr_low


lcd_ins_min                   ;insert minutes
  swapf      time_min,w       ;get high nibble only
  andlw      0x0f
  iorlw      0x30
  call       lcd_snd_data     ;send minute ten's
  movf       time_min,w       ;get low nibble only
  andlw      0x0f
  iorlw      0x30
  call       lcd_snd_data     ;send minute one's
  goto       lcd_next_char

  
lcd_ins_hset                  ;insert thermostat setting
  movf       setpoint,w       ;get thermostat setting
  call       bin2bcd_100      ;get 100's
  movf       bin2bcd,w
  call       bin2bcd_10       ;get 10's
  movf       bcd,w
  iorlw      0x30
  call       lcd_snd_data     ;send 10's
  movf       bin2bcd,w        ;get 1's
  iorlw      0x30
  call       lcd_snd_data     ;send 1's
  goto       lcd_next_char


lcd_ins_span                  ;insert thermostat span
  movf       setspan,w        ;get thermostat span
  call       bin2bcd_100      ;get 100's
  movf       bin2bcd,w
  call       bin2bcd_10       ;get 10's
  movf       bcd,w
  iorlw      0x30
  call       lcd_snd_data     ;send 10's
  movf       bin2bcd,w        ;get 1's
  iorlw      0x30
  call       lcd_snd_data     ;send 1's
  goto       lcd_next_char


lcd_ins_low                   ;insert low status
  movlw      0x20             ;blank leading 0
  call       lcd_snd_data     ;send space
  goto       lcd_next_char
  

lcd_ins_high                  ;insert high status
  movlw      0x20             ;blank leading 0
  call       lcd_snd_data     ;send space
  goto       lcd_next_char


lcd_ins_adj_bcd               ;insert adjustment variable in bcd
  swapf      adjust,w         ;get high nibble only
  andlw      0x0f
  iorlw      0x30
  call       lcd_snd_data     ;send minute ten's
  movf       adjust,w         ;get low nibble only
  andlw      0x0f
  iorlw      0x30
  call       lcd_snd_data     ;send minute one's
  goto       lcd_next_char

  
lcd_ins_adj_bin               ;insert adjustment variable in binary
  movf       adjust,w         ;get thermostat setting
  call       bin2bcd_100      ;get 100's
  movf       bin2bcd,w
  call       bin2bcd_10       ;get 10's
  movf       bcd,w
  iorlw      0x30
  call       lcd_snd_data     ;send 10's
  movf       bin2bcd,w        ;get 1's
  iorlw      0x30
  call       lcd_snd_data     ;send 1's
  goto       lcd_next_char


lcd_init                      ;initialize LCD
                              ;requires 15ms delay after power-up. Adjust
  call       delay_20ms       ;depending on prior instructions.
  bcf        flags,lcd_rs
  movlw      0x03
  call       lcd_snd_nib
  call       delay_5ms
  movlw      0x03
  call       lcd_snd_nib
  call       delay_160us
  movlw      0x03
  call       lcd_snd_nib
  call       delay_160us
  movlw      0x02             ;data length 4 bit
  call       lcd_snd_nib
  call       delay_160us
  movlw      0x28             ;5x7 character and 2 line display
  call       lcd_snd_ins
  movlw      0x08             ;display off
  call       lcd_snd_ins
  movlw      0x01             ;clear display, cursor home
  call       lcd_snd_ins
  movlw      0x06             ;increment cursor position
  call       lcd_snd_ins      ;initialization of display is done!
  movlw      0x0c             ;display on
  call       lcd_snd_ins
  return


lcd_snd_data                  ;sends byte in w to lcd

  bsf        flags,lcd_rs     ;specify data write
  movwf      lcd_sav
  swapf      lcd_sav,w
  call       lcd_snd_nib
  movf       lcd_sav,w
  call       lcd_snd_nib
  call       delay_160us
  return


lcd_snd_ins
  bcf        flags,lcd_rs     ;specify instruction write
  movwf      lcd_sav
  swapf      lcd_sav,w
  call       lcd_snd_nib
  movf       lcd_sav,w
  call       lcd_snd_nib
  call       delay_160us
  movlw      0xfc             ;if instruction is clear display or coursor
  addwf      lcd_sav,w        ;home make delay 5ms
  btfss      status,c
   call      delay_5ms
  return


lcd_snd_nib                   ;send nibble to LCD

  iorlw      b'11110000'      ;mask high nibble
  movwf      lcd_port
  btfss      flags,lcd_rs     ;clear r/s pin if writing instruction
   bcf       lcd_port,lcd_rs
  bcf        lcd_port,lcd_e   ;clock enable
  bsf        lcd_port,lcd_e
  return


;- DS1307 routines --------------------------------------------------------

read_ds1307                   ;ds1307_addr contains register address
                              ;ds1307_data contains contents on exit
  call       i2c_start        ;send start condition
  movlw      ds1307_w         ;address DS1307 to write
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  movf       ds1307_addr,w    ;set register address
  movwf      i2c_snd
  call       i2c_byte_snd     ;send register address
  call       i2c_start        ;repeat start condition
  movlw      ds1307_r         ;address DS1307 to read
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  call       i2c_byte_rcv     ;receive data
  call       i2c_noack_snd    ;send no acknowledge
  movf       i2c_rcv,w        ;move received data into ds1307_data
  movwf      ds1307_data
  call       i2c_stop         ;send stop condition, release bus
  return
  

write_ds1307                  ;ds1307_addr contains register to be written
                              ;ds1307_data contains data to be written
  call       i2c_start        ;send start condition
  movlw      ds1307_w         ;address DS1307 to write
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  movf       ds1307_addr,w    ;set register address
  movwf      i2c_snd
  call       i2c_byte_snd     ;send register address
  movf       ds1307_data,w    ;prepare data to send
  movwf      i2c_snd
  call       i2c_byte_snd     ;send data
  call       i2c_stop         ;send stop condition, release bus
  return


read_time                     ;read hours, minutes and RAM locations
                              ;verify DS1307 contains valid data
  movlw      ds1307_sec       ;get seconds
  movwf      ds1307_addr
  call       read_ds1307
  btfsc      ds1307_data,ds1307_ch
   goto      read_error       ;error if clock halt set
  movlw      ds1307_setp      ;get setpoint
  movwf      ds1307_addr
  call       read_ds1307
  movlw      setpoint_l       ;is data > 9 ?
  subwf      ds1307_data,w
  btfss      status,c
   goto      read_error
  movlw      setpoint_h       ;is data < 30 ?
  subwf      ds1307_data,w
  btfsc      status,c
   goto      read_error
  movf       ds1307_data,w    ;store read setpoint setting
  movwf      setpoint
  movlw      ds1307_span      ;get span
  movwf      ds1307_addr
  call       read_ds1307
  movlw      setspan_l        ;is data > 0 ?
  subwf      ds1307_data,w
  btfss      status,c
   goto      read_error
  movlw      setspan_h        ;is data < 4 ?
  subwf      ds1307_data,w
  btfsc      status,c
   goto      read_error
  movf       ds1307_data,w    ;store read span setting
  movwf      setspan
  movlw      ds1307_hr        ;get hours
  movwf      ds1307_addr
  call       read_ds1307
  btfsc      ds1307_data,ds1307_ampm
   goto      read_error       ;error if AM/PM bit is set
  movf       ds1307_data,w    ;store read hours
  movwf      time_hr
  movlw      ds1307_min       ;get minutes
  movwf      ds1307_addr
  call       read_ds1307
  movf       ds1307_data,w    ;store minutes
  movwf      time_min
  bcf        flags,ds1307_err ;clear error flag
  return

read_error
  bsf        flags,ds1307_err ;set error flag
  return


init_time                     ;initialize ds1307
  movlw      ds1307_sec       ;make seconds 0
  movwf      ds1307_addr      ;prepare register address
  clrf       ds1307_data      ;prepare register data
  call       write_ds1307     ;write ds1307 register
  movlw      ds1307_min       ;make minutes 30
  movwf      ds1307_addr      ;prepare register address
  movlw      0x30             ;prepare register data, bcd 30
  movwf      time_min
  movwf      ds1307_data  
  call       write_ds1307     ;write ds1307 register
  movlw      ds1307_hr        ;make hours 6
  movwf      ds1307_addr      ;prepare register address
  movlw      0x06             ;prepare register data, bcd 6
  movwf      time_hr
  movwf      ds1307_data
  call       write_ds1307     ;write ds1307 register
  movlw      ds1307_span      ;make span 2
  movwf      ds1307_addr      ;prepare register address
  movlw      0x02             ;prepare register data, binary 2
  movwf      setspan
  movwf      ds1307_data
  call       write_ds1307     ;write ds1307 register
  movlw      ds1307_setp      ;make setpoint 16
  movwf      ds1307_addr      ;prepare register address
  movlw      0x16             ;prepare register data, binary 16
  movwf      setpoint
  movwf      ds1307_data
  call       write_ds1307     ;write ds1307 register
  bcf        flags,ds1307_err ;clear error flag
  return


;- DS1621 routines --------------------------------------------------------

config_ds1621                 ;used to initialize DS1621 on power-up

  call       i2c_start        ;send start condition
  movlw      ds1621_w         ;address DS1621 to write
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  movlw      0xac             ;command to access configuration register
  movwf      i2c_snd
  call       i2c_byte_snd     ;send command byte
  movlw      b'10011011'      ;configure DS1621
  movwf      i2c_snd
  call       i2c_byte_snd     ;send configuration byte
  call       i2c_stop         ;send stop condition, release bus
  return


read_config                   ;bit 7 is 1 if temperature conversion complete

  call       i2c_start        ;send start condition
  movlw      ds1621_w         ;address DS1621 to write
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  movlw      0xac             ;command to access configuration register
  movwf      i2c_snd
  call       i2c_byte_snd     ;send command byte
  call       i2c_start        ;repeat start condition
  movlw      ds1621_r         ;address DS1621 to read
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  call       i2c_byte_rcv     ;receive byte, result in i2c_rcv
  call       i2c_noack_snd    ;send no acknowledge
  call       i2c_stop         ;send stop condition
  return


read_temperature              ;reads 2 byte temperature information

  call       i2c_start        ;send start condition
  movlw      ds1621_w         ;address DS1621 to write command
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  movlw      0xaa             ;command to access temperature
  movwf      i2c_snd
  call       i2c_byte_snd     ;send command byte
  call       i2c_start        ;repeat start condition
  movlw      ds1621_r         ;address DS1621 to read bytes
  movwf      i2c_snd
  call       i2c_byte_snd     ;send address byte
  call       i2c_byte_rcv     ;receive MSB
  call       i2c_ack_snd      ;send acknowledge
  movf       i2c_rcv,w        ;store received byte
  movwf      h_temp
  call       i2c_byte_rcv     ;receive LSB
  call       i2c_noack_snd    ;send no acknowledge
  bcf        flags,l_temp     ;store received byte
  btfsc      i2c_rcv,l_temp
  bsf        flags,l_temp
  call       i2c_stop         ;send stop condition, release bus
  return


start_conversion              ;starts temperature conversion
                              ;wait for 'DONE' bit to set before reading
  call       i2c_start        ;send start condition
  movlw      ds1621_w         ;address DS1621 to write
  movwf      i2c_snd
  call       i2c_byte_snd
  movlw      0xee             ;send command to start conversion
  movwf      i2c_snd
  call       i2c_byte_snd
  call       i2c_stop         ;send stop condition, release bus
  return


;- I2C Subroutines --------------------------------------------------------

i2c_start                     ;send i2c start condition

  bsf        status,rp0       ;switch to bank 1
  bsf        i2c_tris,i2c_scl ;make clock high to accomodate repeated start
  nop
  bcf        i2c_tris,i2c_sda ;make data line low
  nop
  bcf        i2c_tris,i2c_scl ;make clock low
  bcf        status,rp0       ;switch to bank 0
  return


i2c_stop                      ;send i2c stop condition

  bsf        status,rp0       ;switch to bank 1
  bcf        i2c_tris,i2c_sda ;make data low
  nop
  bsf        i2c_tris,i2c_scl ;make clock high
  nop
  bsf        i2c_tris,i2c_sda ;make data high
  bcf        status,rp0       ;switch to bank 0
  return


i2c_ack_snd                   ;send acknowledge

  clrf       i2c_snd          ;send a single low data bit
  call       i2c_bit_snd
  return


i2c_noack_snd                 ;send no acknowledge to terminate read

  movlw      0xff
  movwf      i2c_snd
  call       i2c_bit_snd
  return


i2c_byte_snd                  ;send byte *** incl. acknowledge receive! ***
                              ;calling code puts byte in i2c_snd
  movlw      0xf8             ;count 8 bits in w
loop_1
  call       i2c_bit_snd      ;send bit 7 of i2c_snd
  rlf        i2c_snd,f
  addlw      0x01

  btfss      status,z
   goto      loop_1           ;loop until all 8 bits send
  call       i2c_bit_rcv      ;receive acknowledge
  return


i2c_byte_rcv                  ;receive byte *** no acknowledge send incl ***
                              ;exits with received byte in i2c_rcv
  movlw      0xf8             ;count 8 bits in w
loop_2
  rlf        i2c_rcv,f
  call       i2c_bit_rcv      ;get bit 0 of i2c_rcv
  nop
  addlw      0x01
  btfss      status,z
   goto      loop_2           ;loop unit 8 bits received
  return


i2c_bit_snd                   ;send i2c bit

  bsf        status,rp0       ;switch to bank 1
  btfsc      i2c_snd,7        ;make data high if send bit is set
   bsf       i2c_tris,i2c_sda
  btfss      i2c_snd,7        ;make data low if send bit is clear
   bcf       i2c_tris,i2c_sda
  bsf        i2c_tris,i2c_scl ;pulse clock
  nop
  nop
  nop
  nop
  bcf        i2c_tris,i2c_scl
  bcf        status,rp0       ;switch to bank 0
  return


i2c_bit_rcv                   ;receive i2c bit
                              ;exit with data low, clock low
  bsf        status,rp0       ;switch to bank 1
  bsf        i2c_tris,i2c_sda ;make data  high (input)
  bsf        i2c_tris,i2c_scl ;make clock high
  bcf        status,rp0       ;switch to bank 0
  btfsc      i2c_port,i2c_sda ;set received bit high if port set
   bsf       i2c_rcv,0
  btfss      i2c_port,i2c_sda ;set received bit low if port clear
   bcf       i2c_rcv,0
  bsf        status,rp0       ;switch to bank 1
  bcf        i2c_tris,i2c_scl ;make clock low
  bcf        status,rp0       ;switch to bank 0
  return

;- Misc. Helper Routines --------------------------------------------------

delay_160us                   ;software delay of 160us
                              ;4MHz - 1us instruction cycle
ifndef   debug
  movlw      53
  movwf      dly_1
dly_loop_1
  decfsz     dly_1,f
   goto      dly_loop_1
endif
  return


delay_5ms                     ;software delay of 5ms
                              ;4Mhz - 1us instruction cycle
ifndef   debug
  movlw      0x7f
  movwf      dly_1
  movlw      0x07
  movwf      dly_2
dly_loop_2
  decfsz     dly_1,f
   goto      dly_loop_2
  decfsz     dly_2,f
   goto      dly_loop_2
endif
  return


delay_20ms                    ;software delay for 20ms
                              ;calls 5ms delay 4 times
  call       delay_5ms
  call       delay_5ms
  call       delay_5ms
  call       delay_5ms
  return


bin2bcd_100                   ;convert binary to bcd 100's
                              ;bin in w
  clrf       bcd              ;result in bcd, remainder in bin2bcd
loop_100
  movwf      bin2bcd
  movlw      100
  subwf      bin2bcd,w
  btfss      status,c
   return
  incf       bcd,f
  goto       loop_100


bin2bcd_10                    ;convert binary to bcd 10's
                              ;bin in w
  clrf       bcd              ;result in bcd, remain in bin2bcd (1's)
loop_10
  movwf      bin2bcd
  movlw      10
  subwf      bin2bcd,w
  btfss      status,c
   return
  incf       bcd,f
  goto       loop_10


;- Revisions --------------------------------------------------------------
;
; 98-07-08 -Finished and debugged DS1307 routines.
;          -Did code to insert variables in LCD.
;          -Still need to produce output signals to control furnace.
;
; 98-07-06 -Wrote DS1307 routines to read and initialize memories.
;          -Changed mode_1 and mode_2 portions to match verify portions in
;           ds1307 read routines.
;
; 98-07-05 -Modified main routine for new delays.
;          -Wrote key input processing portions. Added mode_table.
;          -Started on DS1307 routines.
;
; 98-07-02 -Began to write routines for DS1307. Realtime clock will NOT
;           function without lithium cell connected.
;          -Decided on final display contents and screens.
;
; 98-03-29 -Changed LCD routine to have insert character.
;          -Changed mode register function. Added flags to indicate
;           set mode and error displays.
;
; 98-03-23 -Added code to time main routine execution with tmr0.
;          -Moved code from LCD subroutine section to main routine.
;          -Added flags to pass new key input from keyboard routine to
;           other routines. Eliminated LCD flicker caused by no key press
;           interpreted as new key press continuously.
;
; 98-03-22 -Removed eeprom routines as a Dallas RTC is used with battery
;           backed RAM. This will eliminate max. write cycle restraint.
;           Set points will be written to non-volatile memory upon
;           completion of change.
;          -Re-wrote key input processing routines for smaller code.
;          -Re-wrote LCD output main routine to accomodate 2 line display
;           and improved message tables.
;          -Minor changes to bits assigned to equates. Board layout used
;           mandated use of different pins on portb of PIC for key input.
;


  end

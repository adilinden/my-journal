        LIST
; P16F84.INC  Standard Header File, Version 2.00    Microchip Technology, Inc.
        NOLIST

; This header file defines configurations, registers, and other useful bits of
; information for the PIC16F84 microcontroller.  These names are taken to match 
; the data sheets as closely as possible.  

; Note that the processor must be selected before this file is 
; included.  The processor may be selected the following ways:

;       1. Command line switch:
;               C:\ MPASM MYFILE.ASM /PIC16F84
;       2. LIST directive in the source file
;               LIST   P=PIC16F84
;       3. Processor Type entry in the MPASM full-screen interface

;==========================================================================
;
;       Revision History
;
;==========================================================================

;Rev:   Date:    Reason:

;2.00   07/24/96 Renamed to reflect the name change to PIC16F84.
;1.01   05/17/96 Corrected BADRAM map
;1.00   10/31/95 Initial Release

;==========================================================================
;
;       Verify Processor
;
;==========================================================================

        IFNDEF __16F84
           MESSG "Processor-header file mismatch.  Verify selected processor."
        ENDIF

;==========================================================================
;
;       Register Definitions
;
;==========================================================================

w                            equ     h'0000'
f                            equ     h'0001'

;----- register files------------------------------------------------------

indf                         equ     h'0000'
tmr0                         equ     h'0001'
pcl                          equ     h'0002'
status                       equ     h'0003'
fsr                          equ     h'0004'
porta                        equ     h'0005'
portb                        equ     h'0006'
eedata                       equ     h'0008'
eeadr                        equ     h'0009'
pclath                       equ     h'000a'
intcon                       equ     h'000b'

option_reg                   equ     h'0081'
trisa                        equ     h'0085'
trisb                        equ     h'0086'
eecon1                       equ     h'0088'
eecon2                       equ     h'0089'

;----- status bits --------------------------------------------------------

irp                          equ     h'0007'
rp1                          equ     h'0006'
rp0                          equ     h'0005'
not_to                       equ     h'0004'
not_pd                       equ     h'0003'
z                            equ     h'0002'
dc                           equ     h'0001'
c                            equ     h'0000'

;----- intcon bits --------------------------------------------------------

gie                          equ     h'0007'
eeie                         equ     h'0006'
t0ie                         equ     h'0005'
inte                         equ     h'0004'
rbie                         equ     h'0003'
t0if                         equ     h'0002'
intf                         equ     h'0001'
rbif                         equ     h'0000'

;----- option bits --------------------------------------------------------

not_rbpu                     equ     h'0007'
intedg                       equ     h'0006'
t0cs                         equ     h'0005'
t0se                         equ     h'0004'
psa                          equ     h'0003'
ps2                          equ     h'0002'
ps1                          equ     h'0001'
ps0                          equ     h'0000'

;----- eecon1 bits --------------------------------------------------------

eeif                         equ     h'0004'
wrerr                        equ     h'0003'
wren                         equ     h'0002'
wr                           equ     h'0001'
rd                           equ     h'0000'

;==========================================================================
;
;       ram definition
;
;==========================================================================

        __maxram h'cf'
        __badram h'07', h'50'-h'7f', h'87'

;==========================================================================
;
;       configuration bits
;
;==========================================================================

_cp_on                       equ     h'000f'
_cp_off                      equ     h'3fff'
_pwrte_on                    equ     h'3ff7'
_pwrte_off                   equ     h'3fff'
_wdt_on                      equ     h'3fff'
_wdt_off                     equ     h'3ffb'
_lp_osc                      equ     h'3ffc'
_xt_osc                      equ     h'3ffd'
_hs_osc                      equ     h'3ffe'
_rc_osc                      equ     h'3fff'

        LIST

;==============================================================================
; Name:
; Course:
; Semester:
; Assignment:
; Device:      PIC16F883
; Toolchain:   MPLAB X + pic-as
; Git URL:
;==============================================================================

;------------------------------------------------------------------------------
; Assembler Directives
;------------------------------------------------------------------------------
PROCESSOR 16F883 
RADIX dec

;------------------------------------------------------------------------------
; Include Statements
;------------------------------------------------------------------------------
#include <xc.inc>

;------------------------------------------------------------------------------
; Device Configuration
;------------------------------------------------------------------------------
CONFIG "FOSC = XT"
CONFIG "WDTE = OFF"
CONFIG "PWRTE = OFF"
CONFIG "MCLRE = ON"
CONFIG "CP = OFF"
CONFIG "CPD = OFF"
CONFIG "BOREN = OFF"
CONFIG "IESO = OFF"
CONFIG "FCMEN = OFF"
CONFIG "LVP = OFF"
CONFIG "BOR4V = BOR40V"
CONFIG "WRT = OFF"

;------------------------------------------------------------------------------
; User constants and variables
;------------------------------------------------------------------------------
user_value      EQU 0x20
w_temp          EQU 0x70
status_temp     EQU 0x71
pclath_temp     EQU 0x72

;------------------------------------------------------------------------------
; Reset Vector
;Don't forget to set the linker options: 
;-Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
;------------------------------------------------------------------------------
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup
;------------------------------------------------------------------------------
; Interrupt Vector
;------------------------------------------------------------------------------
PSECT isrVect,class=CODE,delta=2
InterruptVector:
    goto IsrHandler
;------------------------------------------------------------------------------
; Main Code Section
;------------------------------------------------------------------------------
PSECT code,class=CODE,delta=2

Setup:
    ; add device setup here

    goto MainLoop

MainLoop:
    ; add main loop code here
    goto MainLoop

;------------------------------------------------------------------------------
; IsrHandler
; Input:  none
; Output: none
; Uses:   w_temp, status_temp, pclath_temp
; These registers are in common ram so no bank switching is needed.
;------------------------------------------------------------------------------
IsrHandler:
    movwf   w_temp          ; save WREG
    swapf   STATUS,w        ; read STATUS with swap to avoid affecting status flags
    movwf   status_temp     ; save STATUS
    movf    PCLATH,w        
    movwf   pclath_temp     ; save PCLATH

    ; add interrupt source checks and ISR code here

LeaveIsr:
    movf    pclath_temp,w   
    movwf   PCLATH          ; restore PCLATH
    swapf   status_temp,w   ; read saved STATUS swapping nibbles back to original
    movwf   STATUS          ; restore STATUS
    swapf   w_temp,f        ; swap nibbles to prepare for restoring WREG without affecting flags
    swapf   w_temp,w        ; restore WREG without affecting flags
    retfie

END

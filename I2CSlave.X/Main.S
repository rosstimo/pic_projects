;==============================================================================
; Name:
; Course:
; Semester:
; Assignment:
; Device:      PIC16F883
; Toolchain:   MPLAB X + pic-as
; Git URL:
; Linker Options:   -Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
;==============================================================================

RADIX dec
PROCESSOR 16F883

; Include Statements
#include <xc.inc>

;--------------------------------------
; Device Configuration
;--------------------------------------
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

;--------------------------------------
; User constants and variables
;--------------------------------------
user_value      EQU 0x20
w_temp          EQU 0x70
status_temp     EQU 0x71
pclath_temp     EQU 0x72

;------------------------------------------------------------------------------
; Start of Assembly Code
;------------------------------------------------------------------------------

; Reset Vector at 0000h. Execution starts here after reset.
PSECT resetVect,class=CODE,delta=2
ResetVector:            
    goto Setup

; Interrupt Vector at 0004h. Execution starts here after an interrupt.
PSECT isrVect,class=CODE,delta=2
InterruptVector:
    goto IsrHandler

; Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2

;------------------------------------------------------------------------------
; Setup
;------------------------------------------------------------------------------
Setup:
    ; add device setup here
    goto MainLoop

;------------------------------------------------------------------------------
; Main Loop
;------------------------------------------------------------------------------
MainLoop:
    ; add main loop code here
    goto MainLoop

;------------------------------------------------------------------------------
;Subroutines
;------------------------------------------------------------------------------

;--------------------------------------
; ExampleSubroutine
; Input:  none
; Output: none
; Uses:   none
; Stack Depth: 1            ; no nested calls in this subroutine, so depth is 1
;--------------------------------------
ExampleSubroutine:
    ; add subroutine code here
    return
                            
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
    swapf   w_temp,f        ; prepare for restoring WREG without affecting flags
    swapf   w_temp,w        ; restore WREG without affecting flags
    retfie

;------------------------------------------------------------------------------
; Interrupt Service Routines
; These are called from the main ISR handler after checking the interrupt source.
; Each ISR should clear its interrupt flag  
; Exit via 'goto LeaveIsr' to restore registers and return from interrupt.
;------------------------------------------------------------------------------

;--------------------------------------
; Example Timer0 ISR
; Input:  none
; Output: none
; Uses:   none
; Stack Depth: 1 
;--------------------------------------
ExampleTimer0Isr:
    ; add Timer0 ISR code here
    bcf T0IF                ; clear Timer0 interrupt flag
    goto LeaveIsr

END

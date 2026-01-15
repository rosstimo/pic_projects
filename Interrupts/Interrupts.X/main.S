; Tim Rossiter
; Fall 2025
    
; References: 
/*
MPLAB® XC8 PIC® Assembler User's Guide (DS50002974A)
https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User's%20Guide%2050002974A.pdf
     
MPLAB® XC8 PIC Assembler User's Guide for Embedded Engineers

*/
PROCESSOR 16F883             ; Only if code is written specifically for this device

RADIX dec                    ; Set default number base for constant/literal values

; --- PIC16F883 Configuration Bit Settings ---
; CONFIG1
CONFIG  FOSC = XT            ; XT oscillator: Crystal/resonator on RA6/OSC2 and RA7/OSC1
CONFIG  WDTE = OFF           ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE = OFF          ; Power-up Timer Enable bit (disabled)
CONFIG  MCLRE = ON           ; MCLR pin function is MCLR
CONFIG  CP = OFF             ; Program memory code protection is disabled
CONFIG  CPD = OFF            ; Data memory code protection is disabled
CONFIG  BOREN = OFF          ; Brown out Reset disabled
CONFIG  IESO = OFF           ; Internal/External Switchover disabled
CONFIG  FCMEN = OFF          ; Fail-Safe Clock Monitor disabled
CONFIG  LVP = OFF            ; Low Voltage Programming OFF (HV on MCLR for programming)
; CONFIG2
CONFIG  BOR4V = BOR40V
CONFIG  WRT = OFF

; --- Include Device/Tool Definitions ---
#include <xc.inc>
#include <pic16f883.inc>

; --- Variable Definitions ---
SOMEVALUE      EQU 0x20            ; user RAM variable
WTEMP          EQU 0x70            ; WREG save (common RAM)
STATUSTEMP     EQU 0x71            ; STATUS save (common RAM)
     
     
     
;Program Sections (PSECT)

/* The following PSECTs are already defined in pic16f883.inc
     
//Memory Spaces (see Assembler User's Guide Table: 4-11 for for space flags)
#define SPACE_CODE   0
#define SPACE_DATA   1
#define SPACE_EEPROM 3

psect udata_shr,class=COMMON,space=SPACE_DATA,noexec
psect udata,class=RAM,space=SPACE_DATA,noexec
psect udata_bank0,class=BANK0,space=SPACE_DATA,noexec
psect udata_bank1,class=BANK1,space=SPACE_DATA,noexec
psect udata_bank2,class=BANK2,space=SPACE_DATA,noexec
psect code,class=CODE,space=SPACE_CODE,delta=2
psect data,class=STRCODE,space=SPACE_CODE,delta=2,noexec
psect edata,class=EEDATA,space=SPACE_EEPROM,delta=2,noexec
*/
     
;If you want to tell the linker to put the code in a specific program memory address
;terminal option: -Wl,-presetVect=0h,-Wl,-pisrVect=04h,-Wl,-pcode=08h
;MPLABX:
;Project Properties ? pic-as Linker ? General ? ?Custom linker options?:
;Add: -presetVec=0h
;Add: -pisrVec=4h
;and so on...
     
     
; --- Reset and Interrupt Vectors ---
PSECT resetVect,class=CODE,delta=2
    GOTO Setup

PSECT isrVect,class=CODE,delta=2                   
    GOTO ISR_Handler

; --- Main Code Section ---
PSECT code,class=CODE,delta=2

Setup:
    BCF RP1		;Bank 0
    BCF RP0		;Bank 0
    CLRF TMR0		;Clear Timer 0 Count
    
    BSF RP0		;bank 1
    MOVLW 0xc0		;internal clk, rising edge
    ANDWF OPTION_REG,F	;1:2 prescale
    
    BSF T0IE
    BSF PEIE       ; Peripheral Interrupt Enable
    BSF GIE       ; Global Interrupt Enable (Do this last)
    GOTO MainLoop

; --- Interrupt Service Routine: Save/Restore Context (W,STATUS) ---
PSECT code
ISR_Handler:
    MOVWF WTEMP              ; Save WREG (common RAM, so no banking required)

    SWAPF STATUS,W           ; Save STATUS to WREG (swap to avoid affecting flags)
    SWAPF STATUSTEMP,F         ; Save STATUS

    ; (Add interrupt source checks and logic here...)
    ; Example: check TMR0IF and handle; clear flags as needed

    ; --- End of ISR, restore context ---
    SWAPF  STATUSTEMP,W		; Restore STATUS to proper value
    SWAPF  STATUS,F
    SWAPF  WTEMP,F		;Restore W without touching status flags
    SWAPF  WTEMP,W		;Restore W without touching status flags
    BCF T0IF			;clear timer0 interrupt flag
    RETFIE



PSECT code
; --- Main Program Loop (Loops Forever) ---
MainLoop:
    INCF   PORTB,1
    GOTO   MainLoop

END     ; Required by assembler

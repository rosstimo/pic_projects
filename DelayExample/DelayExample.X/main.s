; Tim Rossiter
; Fall 2025
    
; References: 
/*
MPLABX XC8 PIC Assembler User's Guide (DS50002974A)
https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User's%20Guide%2050002974A.pdf
     
MPLABX XC8 PIC Assembler User's Guide for Embedded Engineers

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

; --- Variable/Constant Definitions ---

toggle_mask    EQU 00000001B       ; used with xor i's toggle 0's stay the same
count_inner    EQU 0x20     
    
; --- Reset and Interrupt Vectors ---
PSECT resetVect,class=CODE,space=0,delta=2 ;Linker option -presetVec=0h
    GOTO Start

PSECT isrVect,class=CODE,space=0,delta=2   ;Linker option -pisrVec=4h                   
    ;GOTO ISR_Handler
    RETFIE ; just in case of interupt
    
; --- Main Code Section ---
PSECT code ;Linker option -pcode=8h

Start:
    BANKSEL INTCON
    CLRF   INTCON                           ;Disable all interrupts

    BANKSEL OPTION_REG
    BSF   OPTION_REG,7                       ;Disable PORTB pull-ups

    BANKSEL ANSELH
    CLRF   ANSELH                            ;Set all PORTB pins to digital

    BANKSEL IOCB
    CLRF   IOCB                             ;Disable all PORTB interrupt-on-change

    BANKSEL PORTB
    CLRF   PORTB                            ;Clear all PORTB pins

    BANKSEL TRISB
    CLRF   TRISB                            ;Set all PORTB pins to output

    BCF STATUS,6		;stay in bank 0 for main
    BCF STATUS,5		;stay in bank 0 for main

PSECT code
; --- Main Program Loop (Loops Forever) ---
MainLoop:
    MOVLW toggle_mask		;1
    XORWF PORTB,1		;1
    MOVLW 0x05			;1
    MOVWF count_inner		;1
InnerDelay:			;(1+2)*5-1+1+1+1+1 or (3)n+3 max: min: delta:
    DECFSZ count_inner,1	;1(2)
    GOTO InnerDelay		;2
    GOTO   MainLoop		;2

END     ; Required by assembler

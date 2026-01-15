;Tim Rossiter
;Fall 2025

;ReferencesMPLAB® XC8 PIC® Assembler User's Guide
;https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User's%20Guide%2050002974A.pdf
;
;MPLAB® XC8 PIC Assembler User's Guide for Embedded Engineers
;https://www.google.com/search?q=pic+assembly+user%27s+guide

PROCESSOR 16F883 ; this is only if code is written specifically for this device
    
RADIX dec ;this sets the default number base for constant/literal values. Can be hex, dec, oct. Should be dec if ommited

; PIC16F883 Configuration Bit Settings
; Assembly source line config statements
; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.

;Include Statements
;These contain all the label/keyword definitions
;You may want to find these and have a look inside
#include <xc.inc>
#include <pic16f883.inc>

;Code Section
;-----------------------------------------------------
    
;Register/Variable Setup
    SOMEVALUE EQU 0x20 ; assign a label to a register address
    
;Start of Program

;Reset vector
PSECT resetVect,class=CODE,delta=2
    GOTO Start


       
;Setup Code that runs once at power up/reset
PSECT code,class=CODE,delta=2
Start:
    BANKSEL INTCON
    CLRF INTCON
    
    BANKSEL OPTION_REG
    CLRF OPTION_REG
    
    BANKSEL ANSELH
    CLRF ANSELH
    
    BANKSEL IOCB
    CLRF IOCB
    
    BANKSEL PORTB
    CLRF PORTB
    
    BANKSEL TRISB
    CLRF TRISB
    
    BANKSEL WPUB
    MOVLW 0xFF
    MOVWF WPUB
    
    GOTO MainLoop
    
;Main Program Loop (Loops forever)
MainLoop:
    INCF PORTB,1
    GOTO MainLoop
    
END ; End of code. This is required


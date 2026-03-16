;HEADER
;NAME
;COURSE
;SEMESTER
;Program/Project
;Git URL

;ReferencesMPLAB XC8 PIC Assembler User's Guide
;https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User's%20Guide%2050002974A.pdf
;
;MPLAB XC8 PIC Assembler User's Guide for Embedded Engineers
;https://www.google.com/search?q=pic+assembly+user%27s+guide
;    
;PIC16F882/883/884/886/887 Data Sheet
;https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf
;
;Mid-Range MCU Family Reference Manual
;https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf

PROCESSOR 16F883 ; this is only if code is written specifically for this device
    
RADIX dec ;this sets the default number base for constant/literal values. Can be hex, dec, oct. Should be dec if ommited
    
    
;Device Setup
;-----------------------------------------------------
;PROCESSOR pic16f883 
;Configuration
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
#include <xc.inc>
;#include <pic16f883.inc>  ; choose the .inc that ships with the compilar
;#inclide "pic16f883.inc" ; choose the include file in the project directory

; --- Variable Definitions ---
SOMEVALUE      EQU 0x20            ; user RAM variable
WTEMP          EQU 0x70            ; WREG save (common RAM)
STATUSTEMP     EQU 0x71            ; STATUS save (common RAM)
        
;I have not good results without specifying the address locations for the reset and ISR vectors as follows:
;If you want to tell the linker to put the code in a specific program memory address
;Open your MPLAB X Project:
;Project Properties --> pic-as Linker --> General --> Custom linker options:
;Add: -presetVect=0h
;Add: -pisrVect=4h
;and so on...
;it should look something like: -Wl,-presetVect=0h,-pisrVect=04h,-pcode=08h
     
; --- Reset Vector --- at addess 0000h so add -presetVect=0h to assembler options
PSECT resetVect,class=CODE,delta=2
    GOTO Setup
    

; --- Interrupt Vector --- at addess 0004h so add -pisrVect=04h to assembler options
PSECT isrVect,class=CODE,delta=2
    GOTO ISR_Handler


; --- Main Code Section --- at addess 0008h so add -pcode=08h to assembler options
PSECT code,class=CODE,delta=2

Setup:

    ; ANSELH bits 5..0 = ANS13..ANS8
    ; 1 = Analog input 
    ; 0 = Digital I/O / digital function
    BANKSEL ANSELH
    CLRF  ANSELH              ; ANS13..ANS8 = 0 (all digital)                 


    ; IOCB bits 7..0:
    ; 1 = interrupt-on-change enabled for that RB pin
    ; 0 = interrupt-on-change disabled
    BANKSEL IOCB
    CLRF    IOCB                ; IOCB7..IOCB0 = 0 (IOC disabled)

    ; INTCON bits related to PORTB IOC:
    ; bit 3 RBIE: 1=enable PORTB change interrupt, 0=disable
    ; bit 0 RBIF: 1=flag set (mismatch occurred), 0=flag clear
    BANKSEL INTCON
    BCF     INTCON, 0        ; RBIE = 0 (disable PORTB change interrupt)     
    BCF     INTCON, 3        ; RBIF = 0 (clear pending flag) 

    ; Writing PORTB writes output latch. Reading PORTB reads pin levels.
    BANKSEL PORTB
    CLRF    PORTB               ; RB7..RB0 latch = 0 (start low)

    ; TRISB bits 7..0:
    ; 1 = input (hi-Z), 0 = output (driver enabled)
    BANKSEL TRISB
    CLRF    TRISB               ; TRISB7..TRISB0 = 0 (all outputs)

    ; Leave bank sane for the loop (avoid the classic "increment TRISB by accident" tragedy)
    BANKSEL PORTB
    GOTO    MainLoop

    
;Main Program Loop (Loops forever)
MainLoop:
    INCF PORTB,1
    GOTO MainLoop
    
; --- Interrupt Service Routine: Save and Restore Context (W,STATUS) ---
PSECT code
ISR_Handler:
    MOVWF WTEMP			; Save WREG (common RAM, so no banking required)
    SWAPF STATUS,W		; Save STATUS to WREG (swap to avoid affecting flags)
    MOVWF STATUSTEMP	; Save STATUS (common RAM, so no banking required)
    

    ; (Add interrupt source checks and logic here...)
    ; Example: check TMR0IF and handle; clear flags as needed

    ; --- End of ISR, restore context ---
    SWAPF  STATUSTEMP,W		; Restore STATUS to proper value
    MOVWF  STATUS           
    SWAPF  WTEMP,F		; Restore W without touching status flags
    SWAPF  WTEMP,W		; Restore W without touching status flags
    RETFIE

END ; End of code. This is required

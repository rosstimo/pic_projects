;HEADER
;NAME
;COURSE
;SEMESTER
;Program/Project
;Git URL

;ReferencesMPLAB® XC8 PIC® Assembler User's Guide
;https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User's%20Guide%2050002974A.pdf
;
;MPLAB® XC8 PIC Assembler User's Guide for Embedded Engineers
;https://www.google.com/search?q=pic+assembly+user%27s+guide
;    
;PIC16F882/883/884/886/887 Data Sheet
;https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf

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
     


; --- Reset Vector ---
PSECT resetVect,class=CODE,delta=2
    GOTO Setup
    
; --- Interrupt Vector ---
PSECT isrVect,class=CODE,delta=2                   
    GOTO ISR_Handler

; --- Main Code Section ---
PSECT code,class=CODE,delta=2
Setup:
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
    
; --- Interrupt Service Routine: Save and Restore Context (W,STATUS) ---
PSECT code
ISR_Handler:
    MOVWF WTEMP			; Save WREG (common RAM, so no banking required)
    SWAPF STATUS,W		; Save STATUS to WREG (swap to avoid affecting flags)
    SWAPF STATUSTEMP,F		; Save STATUS

    ; (Add interrupt source checks and logic here...)
    ; Example: check TMR0IF and handle; clear flags as needed

    ; --- End of ISR, restore context ---
    SWAPF  STATUSTEMP,W		; Restore STATUS to proper value
    SWAPF  STATUS,F
    SWAPF  WTEMP,F		; Restore W without touching status flags
    SWAPF  WTEMP,W		; Restore W without touching status flags
    RETFIE

END ; End of code. This is required
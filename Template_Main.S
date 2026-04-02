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
    
RADIX dec ;this sets the default number base for constant/literal values. Can be hex, dec, oct. Should be dec if omitted
    
    
;Device Setup
;-----------------------------------------------------
;PROCESSOR pic16f883 
;Configuration
; CONFIG1
  CONFIG  "FOSC = XT"             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  "WDTE = OFF"            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  "PWRTE = OFF"           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  "MCLRE = ON"            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  "CP = OFF"              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  "CPD = OFF"             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  "BOREN = OFF"           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  "IESO = OFF"            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  "FCMEN = OFF"           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  "LVP = OFF"             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  "BOR4V = BOR40V"        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  "WRT = OFF"             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
;Include Statements
#include <xc.inc>
;#include <pic16f883.inc>       ; choose the .inc that ships with the compiler
;#include "pic16f883.inc"       ; choose the include file in the project directory

; --- Variable Definitions ---
SOMEVALUE       EQU 0x20        ; user RAM variable
W_TEMP          EQU 0x70        ; WREG save (common RAM)
STATUS_TEMP     EQU 0x71        ; STATUS save (common RAM)
PCLATH_TEMP     EQU 0x72        ; PCLATH save (common RAM)

;Tell the linker to put the program section code in a specific program memory address
;Open your MPLAB X Project:
;Project Properties --> pic-as Linker --> General --> Custom linker options:
;Add: -presetVect=0h
;Add: -pisrVect=4h
;and so on...
;it should look something like: -Wl,-presetVect=0h,-pisrVect=04h,-pcode=08h
     
; --- Reset Vector --- at address 0000h so add -presetVect=0h to assembler options
; On any Reset PCL and PCLATH default to all 0
PSECT resetVect,class=CODE,delta=2
    GOTO Setup
    

; --- Interrupt Vector --- at addess 0004h so add -pisrVect=04h to assembler options
PSECT isrVect,class=CODE,delta=2
    GOTO ISR_Handler


; --- Main Code Section --- at address 0008h so add -pcode=08h to assembler options
PSECT code,class=CODE,delta=2

Setup:

    ;setup code here

    GOTO    MainLoop

    
;Main Program Loop (Loops forever)
MainLoop:
    //main code here
    GOTO MainLoop
    
; --- Interrupt Service Routine: Save and Restore Context (W,STATUS) ---
PSECT code
ISR_Handler:
    MOVWF W_TEMP                ; Save WREG (common RAM, so no banking required)
    SWAPF STATUS,W              ; Save STATUS to WREG (swap to avoid affecting flags)
    MOVWF STATUS_TEMP		    ; Save STATUS (common RAM, so no banking required)
    MOVF  PCLATH,w              ; Needed when using calculated jumps like lookup tables
    MOVWF PCLATH_TEMP           ; Save PCLATH (common RAM, so no banking required)

    ; (Add interrupt source checks and logic here...)
    ; Example: check TMR0IF and handle; clear flags as needed

    ; --- End of ISR, restore context ---
LeaveISR:
    MOVF   PCLATH_TEMP,W
    MOVWF  PCLATH               ; Restore PCLATH
    SWAPF  STATUS_TEMP,W		; Restore STATUS to proper value
    MOVWF  STATUS           
    SWAPF  W_TEMP,F             ; Restore W without touching status flags
    SWAPF  W_TEMP,W             ; Restore W without touching status flags
    RETFIE

END ; End of code. This is required

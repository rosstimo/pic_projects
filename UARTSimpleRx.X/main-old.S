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
     

; ------------------------------------------------------------
; PIC16F883
; Simple UART RX test:
; any received byte is copied to PORTB
;
; 4 MHz oscillator assumed
; 9600 baud, async, 8N1
; RX pin = RC7
; PORTB = output display
; ------------------------------------------------------------
; --- Reset Vector --- at addess 0000h so add -presetVect=0h to assembler options
PSECT resetVect,class=CODE,delta=2
resetVec:
    PAGESEL main
    goto    main

PSECT code
main:
    ; -------------------------------
    ; Make PORTB digital outputs
    ; -------------------------------
    BANKSEL ANSELH
    clrf    ANSELH               ; RB<5:0> digital mode

    BANKSEL TRISB
    clrf    TRISB                ; all PORTB pins outputs

    BANKSEL PORTB
    clrf    PORTB                ; start with outputs low

    ; -------------------------------
    ; RC7 is RX input
    ; -------------------------------
    BANKSEL TRISC
    bsf     TRISC7               ; RC7/RX as input

    ; -------------------------------
    ; Baud = 9600 @ 4 MHz
    ; BRGH = 1, BRG16 = 0, SPBRG = 25
    ; -------------------------------
    BANKSEL BAUDCTL
    bcf     BRG16                ; 8-bit baud generator

    BANKSEL SPBRG
    movlw   25
    movwf   BANKMASK(SPBRG)

    ; -------------------------------
    ; Async receive setup
    ; -------------------------------
    BANKSEL TXSTA
    bcf     SYNC                 ; asynchronous mode
    bsf     BRGH                 ; high-speed baud

    BANKSEL RCSTA
    bsf     SPEN                 ; enable serial port
    bcf     RX9                  ; 8-bit receive
    bsf     CREN                 ; continuous receive enable

rx_loop:
    ; Wait for a byte to arrive
    BANKSEL PIR1
    btfss   RCIF
    goto    rx_loop

    ; If overrun error happened, reset receiver
    BANKSEL RCSTA
    btfsc   OERR
    goto    clear_overrun

    ; Read received byte and show it on PORTB
    BANKSEL RCREG
    movf    BANKMASK(RCREG), w

    BANKSEL PORTB
    movwf   PORTB

    goto    rx_loop

clear_overrun:
    ; OERR is cleared by toggling CREN
    BANKSEL RCSTA
    bcf     CREN
    bsf     CREN
    goto    rx_loop

END

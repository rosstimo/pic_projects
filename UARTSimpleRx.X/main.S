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
; Beginner-friendly async serial receive example
; 4 MHz oscillator assumed
; 9600 baud, 8N1
;
; What this program does:
; - waits for a byte to arrive on RC7/RX
; - checks for receive errors
; - reads the received byte
; - uses the byte by putting it on PORTB
; ------------------------------------------------------------

PSECT resetVect,class=CODE,delta=2
    PAGESEL main
    goto    main

PSECT code
main:

    ; Make PORTB easy to observe
    BANKSEL ANSELH
    clrf    ANSELH                  ; make PORTB digital

    BANKSEL TRISB
    clrf    TRISB                   ; make PORTB outputs

    BANKSEL PORTB
    clrf    PORTB                   ; start with PORTB = 0

    BANKSEL TRISC
    bsf     TRISC7                  ; RC7/RX is an input ; may be redundant. datasheet says pin is an input anyway 12.1.2.1

    ; Setup baud rate
    ; 9600 baud at 4 MHz with BRGH = 1, BRG16 = 0, SPBRG = 25
    BANKSEL BAUDCTL
    bcf     BRG16

    BANKSEL SPBRG
    movlw   25
    movwf   BANKMASK(SPBRG)

    ; Setup async serial mode
    BANKSEL TXSTA
    bcf     SYNC    ;async mode
    bsf     BRGH    

    ; Enable serial port
    BANKSEL RCSTA
    bsf     SPEN

    ; Optional: enable interrupts
    ; not used in this program

    ; Optional: enable 9-bit receive
    ; not used in this program, so leave RX9 = 0
    BANKSEL RCSTA
    bcf     RX9

    ; Enable receiver
    BANKSEL RCSTA
    bsf     CREN

MainLoop:

    ; Wait for a byte to arrive
    BANKSEL PIR1
    btfss   RCIF
    goto    MainLoop

    ; Check status and errors
    ; Check for overrun error
    BANKSEL RCSTA
    btfsc   OERR
    goto    ResetReceiver
    
    ; Check for framing error
    BANKSEL RCSTA
    btfsc   FERR
    goto    FramingError

    ; Read received byte
    BANKSEL RCREG
    movf    BANKMASK(RCREG), w

    ; Use the byte
    BANKSEL PORTB
    movwf   BANKMASK(PORTB)

    goto    MainLoop

ResetReceiver:
    ; Reset receiver
    BANKSEL RCSTA
    bcf     CREN
    bsf     CREN
    BANKSEL PORTB
    bsf	    PORTB,0
    goto    MainLoop

FramingError:
    ; Check status and errors
    ; read and throw away the bad byte
    BANKSEL RCREG
    movf    BANKMASK(RCREG), w
    BANKSEL PORTB
    bsf	    PORTB,1
    goto    MainLoop




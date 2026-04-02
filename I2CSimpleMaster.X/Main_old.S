; Simple PIC16F883 I2C master transmit demo
; Sends: START -> 0xA0 -> 0xA5 -> STOP
; Debug on PORTB:
;   RB0 = start complete
;   RB1 = address ACK
;   RB2 = data ACK
;   RB3 = stop complete
;   RB4 = address NACK
;   RB5 = data NACK

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


;Tell the linker to put the program section code in a specific program memory address
; -Wl,-presetVect=0h,-pisrVect=04h,-pcode=08h
     
; --- Reset Vector --- at address 0000h so add -presetVect=0h to assembler options
; On any Reset PCL and PCLATH default to all 0
PSECT resetVect,class=CODE,delta=2
    GOTO Setup
    
; --- Main Code Section --- at address 0008h so add -pcode=08h to assembler options
PSECT code,class=CODE,delta=2

Setup:
    ; Make PORTB digital and outputs for debug
    BANKSEL ANSEL
    clrf    ANSEL
    clrf    ANSELH

    BANKSEL PORTB
    clrf    PORTB

    BANKSEL TRISB
    clrf    TRISB

    ; I2C pins must be inputs so MSSP can control them as open-drain
    BANKSEL TRISC
    bsf     TRISC, 3          ; RC3 = SCL input
    bsf     TRISC, 4          ; RC4 = SDA input

    ; MSSP setup
    BANKSEL SSPCON
    clrf    SSPCON

    BANKSEL SSPCON2
    clrf    SSPCON2

    ; Standard speed I2C
    ; SMP=1, CKE=0
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; 100 kHz @ FOSC = 4 MHz
    ; SCL = FOSC / (4 * (SSPADD + 1))
    ; 100k = 4M / (4 * (9 + 1))
    BANKSEL SSPADD
    movlw   0x09
    movwf   SSPADD

    ; SSPEN=1, SSPM<3:0>=1000 -> I2C Master mode
    BANKSEL SSPCON
    movlw   00101000B
    movwf   SSPCON

    BANKSEL PIR1
    bcf     PIR1, PIR1_SSPIF_POSN

MainLoop:
    call    SendOnce
    goto    MainLoop

SendOnce:
    ; Clear debug bits each pass
    BANKSEL PORTB
    clrf    PORTB

    ; ----- START -----
    BANKSEL PIR1
    bcf     PIR1, PIR1_SSPIF_POSN

    BANKSEL SSPCON2
    bsf     SSPCON2, SSPCON2_SEN_POSN

WaitStart:
    btfsc   SSPCON2, SSPCON2_SEN_POSN
    goto    WaitStart

    BANKSEL PIR1
    bcf     PIR1, PIR1_SSPIF_POSN

    BANKSEL PORTB
    bsf     PORTB, 0          ; start complete

    ; ----- ADDRESS BYTE -----
    ; 7-bit slave address 0x50, write bit = 0
    ; bus byte = 0xA0
    BANKSEL SSPBUF
    movlw   0xA0
    movwf   SSPBUF

WaitAddr:
    BANKSEL PIR1
    btfss   PIR1, PIR1_SSPIF_POSN
    goto    WaitAddr
    bcf     PIR1, PIR1_SSPIF_POSN

    BANKSEL SSPCON2
    btfsc   SSPCON2, SSPCON2_ACKSTAT_POSN
    goto    AddrNack

    BANKSEL PORTB
    bsf     PORTB, 1          ; address ACK
    goto    SendData

AddrNack:
    BANKSEL PORTB
    bsf     PORTB, 4          ; address NACK
    goto    SendStop

SendData:
    ; ----- DATA BYTE -----
    BANKSEL SSPBUF
    movlw   0xA5
    movwf   SSPBUF

WaitData:
    BANKSEL PIR1
    btfss   PIR1, PIR1_SSPIF_POSN
    goto    WaitData
    bcf     PIR1, PIR1_SSPIF_POSN

    BANKSEL SSPCON2
    btfsc   SSPCON2, SSPCON2_ACKSTAT_POSN
    goto    DataNack

    BANKSEL PORTB
    bsf     PORTB, 2          ; data ACK
    goto    SendStop

DataNack:
    BANKSEL PORTB
    bsf     PORTB, 5          ; data NACK

SendStop:
    ; ----- STOP -----
    BANKSEL SSPCON2
    bsf     SSPCON2, SSPCON2_PEN_POSN

WaitStop:
    btfsc   SSPCON2, SSPCON2_PEN_POSN
    goto    WaitStop

    BANKSEL PORTB
    bsf     PORTB, 3          ; stop complete

    return

END
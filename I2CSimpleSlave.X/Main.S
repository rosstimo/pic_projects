;=====================================================
; PIC16F883 ultra-simple I2C slave ACK test
; pic-as
;
; Option A: specific slave address test
;   Slave Address 0x50
;   SSPADD = 0xA0
;   SSPMSK = 11111110B for exact address match
;   GCEN disabled
;   Master must send 0xA0 for write
;
; Option B: general call test
;   GCEN enabled
;   Master can send 0x00
;=====================================================

PROCESSOR 16F883
RADIX dec

#include <xc.inc>

;-----------------------------------------------------
; Configuration
;-----------------------------------------------------
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

dummy           EQU 0x20

PSECT resetVect,class=CODE,delta=2
    goto    Setup

PSECT code,class=CODE,delta=2

Setup:
    ; make ports digital
    BANKSEL ANSEL
    clrf    ANSEL
    clrf    ANSELH

    ; optional debug on PORTB
    BANKSEL PORTB
    clrf    PORTB
    BANKSEL TRISB
    clrf    TRISB

    ; I2C pins must be inputs
    BANKSEL TRISC
    bsf     TRISC, 3            ; RC3 = SCL
    bsf     TRISC, 4            ; RC4 = SDA

    ; clear MSSP registers to ensure known state and ready BUS before configuring
    BANKSEL SSPCON
    clrf    SSPCON              ; Ensure Default state. Specifically clear SSPEN, WCOL, SSPOV

    BANKSEL SSPSTAT             
    clrf    SSPSTAT             ; Ensure Default state.
    movf   SSPBUF, w           ; Explicitly clear BF bit with read of SSPBUF

    BANKSEL SSPCON2
    clrf    SSPCON2             ; Ensure Default state.

    ;---------------------------------------------
    ; choose one test mode
    ;---------------------------------------------

    ; specific 7-bit slave address = 0x50
    BANKSEL SSPADD
    movlw   0xA0                ;bus byte = 0xA0 or 1010000w
    movwf   SSPADD

    ; for GENERAL CALL testing, uncomment this:
    BANKSEL SSPCON2
    bsf     GCEN

    ; SSPEN=1, CKP=1, SSPM<3:0>=0110 -> I2C slave 7-bit
    BANKSEL SSPCON
    movlw   0x36
    movwf   SSPCON

    BANKSEL PIR1
    bcf     SSPIF

MainLoop:
    BANKSEL PIR1
    btfss   SSPIF
    goto    MainLoop

    ; optional debug: show activity
    BANKSEL PORTB
    bsf     PORTB, 0

    ; must read SSPBUF to clear BF
    BANKSEL SSPBUF
    movf    SSPBUF, w
    BANKSEL dummy
    movwf   dummy

    ; if overflow happened, clear it
    BANKSEL SSPCON
    bcf     SSPOV

    ; clear MSSP flag
    BANKSEL PIR1
    bcf     SSPIF

    goto    MainLoop

END
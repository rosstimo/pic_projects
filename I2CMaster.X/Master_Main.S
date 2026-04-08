;==============================================================================
; I2C Master Test Code
; Device:      PIC16F883
; Toolchain:   MPLAB X + pic-as
; Purpose:
;   1. Test addressed write to slave 0x50
;   2. Test addressed read from slave 0x50
;   3. Test general call write
;   4. On a successful read, place the received byte on PORTB
;
; Notes:
;   - 7-bit slave address = 0x50
;   - Write bus byte      = 0xA0
;   - Read bus byte       = 0xA1
;   - General call byte   = 0x00
;   - PORTB shows simple status patterns for write/general-call tests
;   - PORTB shows the actual received data byte after a successful read
;
; Linker Options:
;   -Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
;==============================================================================

PROCESSOR 16F883
RADIX dec

#include <xc.inc>

;------------------------------------------------------------------------------
; Configuration
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; Constants
;------------------------------------------------------------------------------
SLAVE_ADDR_WRITE    EQU 0xA0
SLAVE_ADDR_READ     EQU 0xA1
GENERAL_CALL_ADDR   EQU 0x00
WRITE_TEST_DATA     EQU 0x55
GENERAL_CALL_DATA   EQU 0xA5

WRITE_PASS_PATTERN      EQU 0x11
WRITE_ADDR_NACK_PATTERN EQU 0x10
WRITE_DATA_NACK_PATTERN EQU 0x20
READ_ADDR_NACK_PATTERN  EQU 0x40
GC_PASS_PATTERN         EQU 0x77
GC_ADDR_NACK_PATTERN    EQU 0x80
GC_DATA_NACK_PATTERN    EQU 0x81

;------------------------------------------------------------------------------
; Variables
;------------------------------------------------------------------------------
readByte        EQU 0x20
innerDelay      EQU 0x21
outerDelay      EQU 0x22

;------------------------------------------------------------------------------
; Reset Vector
;------------------------------------------------------------------------------
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto    Setup

;------------------------------------------------------------------------------
; Main Code
;------------------------------------------------------------------------------
PSECT code,class=CODE,delta=2

Setup:
    ; Make PORTB digital outputs
    BANKSEL ANSEL
    clrf    ANSEL
    clrf    ANSELH

    BANKSEL PORTB
    clrf    PORTB

    BANKSEL TRISB
    clrf    TRISB

    ; I2C pins must be inputs so MSSP can control them as open-drain
    BANKSEL TRISC
    bsf     TRISC, 3                  ; RC3 = SCL
    bsf     TRISC, 4                  ; RC4 = SDA

    ; Clear MSSP registers before setup
    BANKSEL SSPCON
    clrf    SSPCON

    BANKSEL SSPCON2
    clrf    SSPCON2

    ; Standard-speed I2C
    ; SSPSTAT.SMP = 1, SSPSTAT.CKE = 0
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; 100 kHz @ FOSC = 4 MHz
    ; SCL = FOSC / (4 * (SSPADD + 1))
    BANKSEL SSPADD
    movlw   0x09
    movwf   SSPADD

    ; SSPEN = 1, SSPM<3:0> = 1000 -> I2C Master mode
    BANKSEL SSPCON
    movlw   0x28
    movwf   SSPCON

    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL readByte
    clrf    readByte

MainLoop:
    call    TestWrite
    call    VisibleDelay

    call    TestGeneralCall
    call    VisibleDelay

    call    TestRead
    call    VisibleDelay

    goto    MainLoop

;------------------------------------------------------------------------------
; Addressed Write Test
; START -> 0xA0 -> 0x55 -> STOP
;------------------------------------------------------------------------------
TestWrite:
    BANKSEL PORTB
    clrf    PORTB

    call    I2cStart

    movlw   SLAVE_ADDR_WRITE
    call    I2cSendByte

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    TestWriteAddrNack

    movlw   WRITE_TEST_DATA
    call    I2cSendByte

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    TestWriteDataNack

    call    I2cStop

    BANKSEL PORTB
    movlw   WRITE_PASS_PATTERN
    movwf   PORTB
    return

TestWriteAddrNack:
    call    I2cStop

    BANKSEL PORTB
    movlw   WRITE_ADDR_NACK_PATTERN
    movwf   PORTB
    return

TestWriteDataNack:
    call    I2cStop

    BANKSEL PORTB
    movlw   WRITE_DATA_NACK_PATTERN
    movwf   PORTB
    return

;------------------------------------------------------------------------------
; Addressed Read Test
; START -> 0xA1 -> READ BYTE -> NACK -> STOP
; On success, received byte is copied to PORTB.
;------------------------------------------------------------------------------
TestRead:
    BANKSEL PORTB
    clrf    PORTB

    call    I2cStart

    movlw   SLAVE_ADDR_READ
    call    I2cSendByte

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    TestReadAddrNack

    call    I2cReceiveByte

    BANKSEL readByte
    movwf   readByte

    call    I2cMasterNack
    call    I2cStop

    BANKSEL readByte
    movf    readByte, w
    BANKSEL PORTB
    movwf   PORTB
    return

TestReadAddrNack:
    call    I2cStop

    BANKSEL PORTB
    movlw   READ_ADDR_NACK_PATTERN
    movwf   PORTB
    return

;------------------------------------------------------------------------------
; General Call Write Test
; START -> 0x00 -> 0xA5 -> STOP
;------------------------------------------------------------------------------
TestGeneralCall:
    BANKSEL PORTB
    clrf    PORTB

    call    I2cStart

    movlw   GENERAL_CALL_ADDR
    call    I2cSendByte

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    TestGeneralCallAddrNack

    movlw   GENERAL_CALL_DATA
    call    I2cSendByte

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    TestGeneralCallDataNack

    call    I2cStop

    BANKSEL PORTB
    movlw   GC_PASS_PATTERN
    movwf   PORTB
    return

TestGeneralCallAddrNack:
    call    I2cStop

    BANKSEL PORTB
    movlw   GC_ADDR_NACK_PATTERN
    movwf   PORTB
    return

TestGeneralCallDataNack:
    call    I2cStop

    BANKSEL PORTB
    movlw   GC_DATA_NACK_PATTERN
    movwf   PORTB
    return

;------------------------------------------------------------------------------
; I2C Helpers
;------------------------------------------------------------------------------
I2cStart:
    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL SSPCON2
    bsf     SEN

I2cStartWait:
    btfsc   SEN
    goto    I2cStartWait

    BANKSEL PIR1
    bcf     SSPIF
    return

I2cStop:
    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL SSPCON2
    bsf     PEN

I2cStopWait:
    btfsc   PEN
    goto    I2cStopWait

    BANKSEL PIR1
    bcf     SSPIF
    return

; Expects transmit byte in W
I2cSendByte:
    BANKSEL SSPBUF
    movwf   SSPBUF

I2cSendByteWait:
    BANKSEL PIR1
    btfss   SSPIF
    goto    I2cSendByteWait

    bcf     SSPIF
    return

; Returns received byte in W
I2cReceiveByte:
    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL SSPCON2
    bsf     RCEN

I2cReceiveByteWait:
    BANKSEL PIR1
    btfss   SSPIF
    goto    I2cReceiveByteWait

    bcf     SSPIF

    BANKSEL SSPBUF
    movf    SSPBUF, w
    return

; Master sends NACK after final received byte
I2cMasterNack:
    BANKSEL SSPCON2
    bsf     ACKDT
    bsf     ACKEN

I2cMasterNackWait:
    btfsc   ACKEN
    goto    I2cMasterNackWait

    return

;------------------------------------------------------------------------------
; Delay for visible LED/display status on PORTB
;------------------------------------------------------------------------------
VisibleDelay:
    BANKSEL outerDelay
    movlw   0x05
    movwf   outerDelay

VisibleDelayOuter:
    movlw   0x05
    movwf   innerDelay

VisibleDelayInner:
    decfsz  innerDelay, f
    goto    VisibleDelayInner

    decfsz  outerDelay, f
    goto    VisibleDelayOuter

    return

END

;=====================================================
; Simple PIC16F883 I2C master transmit demo (corrected)
; Sends: START -> 0xA0 -> 0xA5 -> STOP
;
; Assumptions:
;   - PIC16F883
;   - FOSC = 4 MHz external crystal (XT)
;   - Standard-mode I2C at 100 kHz
;   - External pull-up resistors are present on RC3/SCL and RC4/SDA
;
; Debug on PORTB:
;   RB0 = start complete
;   RB1 = address ACK
;   RB2 = data ACK
;   RB3 = stop complete
;   RB4 = address NACK
;   RB5 = data NACK
;   RB6 = timeout / bus not idle
;   RB7 = bus collision / WCOL
;=====================================================

PROCESSOR 16F883
RADIX dec

CONFIG  "FOSC = XT"
CONFIG  "WDTE = OFF"
CONFIG  "PWRTE = OFF"
CONFIG  "MCLRE = ON"
CONFIG  "CP = OFF"
CONFIG  "CPD = OFF"
CONFIG  "BOREN = OFF"
CONFIG  "IESO = OFF"
CONFIG  "FCMEN = OFF"
CONFIG  "LVP = OFF"
CONFIG  "BOR4V = BOR40V"
CONFIG  "WRT = OFF"

#include <xc.inc>

;-----------------------------------------------------
; RAM variables
;-----------------------------------------------------
timeout_count   EQU 0x20
result_code     EQU 0x21
tx_byte         EQU 0x22
delay_count     EQU 0x23

TIMEOUT_MAX     EQU 200
INTERPASS_DELAY EQU 250

;-----------------------------------------------------
; Linker note:
; use custom linker options such as:
;   -Wl,-presetVect=0h,-pcode=08h
;-----------------------------------------------------

PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup

PSECT code,class=CODE,delta=2

Setup:
    ; Make all shared analog pins digital so PORTB debug works cleanly.
    BANKSEL ANSEL
    clrf    ANSEL
    clrf    ANSELH

    ; PORTB = debug outputs.
    BANKSEL PORTB
    clrf    PORTB

    BANKSEL TRISB
    clrf    TRISB

    ; RC3/SCL and RC4/SDA must be inputs for MSSP I2C operation.
    BANKSEL TRISC
    bsf     TRISC, 3
    bsf     TRISC, 4

    ; Clear MSSP control/status registers before configuration.
    BANKSEL SSPCON
    clrf    SSPCON

    BANKSEL SSPCON2
    clrf    SSPCON2

    ; Standard-speed I2C.
    ; SMP = 1, CKE = 0
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; 100 kHz @ FOSC = 4 MHz
    ; SCL = FOSC / (4 * (SSPADD + 1))
    ; 100k = 4M / (4 * (9 + 1))
    BANKSEL SSPADD
    movlw   0x09
    movwf   SSPADD

    ; SSPEN = 1, SSPM<3:0> = 1000 -> I2C Master mode
    BANKSEL SSPCON
    movlw   0x28
    movwf   SSPCON

    ; Clear interrupt/status flags that matter to this demo.
    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON
    bcf     WCOL

MainLoop:
    call    SendOnce
    call    DelayBetweenPasses
    goto    MainLoop

;-----------------------------------------------------
; Send one transaction:
;   START -> 0xA0 -> 0xA5 -> STOP
;-----------------------------------------------------
SendOnce:
    BANKSEL PORTB
    clrf    PORTB

    call    StartCondition
    iorlw   0x00
    btfss   STATUS, STATUS_Z_POSN
    return

    movlw   0xA0
    call    WriteByte
    movwf   result_code

    movf    result_code, w
    iorlw   0x00
    btfsc   STATUS, STATUS_Z_POSN
    goto    AddressAck

    movf    result_code, w
    xorlw   0x01
    btfsc   STATUS, STATUS_Z_POSN
    goto    AddressNack

    ; Any other return value means timeout/collision/write-collision.
    return

AddressAck:
    BANKSEL PORTB
    bsf     PORTB, 1

    movlw   0xA5
    call    WriteByte
    movwf   result_code

    movf    result_code, w
    iorlw   0x00
    btfsc   STATUS, STATUS_Z_POSN
    goto    DataAck

    movf    result_code, w
    xorlw   0x01
    btfsc   STATUS, STATUS_Z_POSN
    goto    DataNack

    return

AddressNack:
    BANKSEL PORTB
    bsf     PORTB, 4
    call    StopCondition
    return

DataAck:
    BANKSEL PORTB
    bsf     PORTB, 2
    call    StopCondition
    return

DataNack:
    BANKSEL PORTB
    bsf     PORTB, 5
    call    StopCondition
    return

;-----------------------------------------------------
; Wait until the I2C module is idle.
; Returns:
;   W = 0x00 on success
;   W = 0xFF on timeout / bus busy
;-----------------------------------------------------
WaitI2cIdle:
    movlw   TIMEOUT_MAX
    BANKSEL timeout_count
    movwf   timeout_count

WaitI2cIdleLoop:
    movlw   0x1F
    BANKSEL SSPCON2
    andwf   SSPCON2, w
    btfss   STATUS, STATUS_Z_POSN
    goto    WaitI2cIdleBusy

    BANKSEL SSPSTAT
    btfsc   R_W
    goto    WaitI2cIdleBusy

    movlw   0x00
    return

WaitI2cIdleBusy:
    BANKSEL timeout_count
    decfsz  timeout_count, f
    goto    WaitI2cIdleLoop

    BANKSEL PORTB
    bsf     PORTB, 6
    movlw   0xFF
    return

;-----------------------------------------------------
; Generate START condition.
; Returns:
;   W = 0x00 on success
;   W = 0xFF on timeout / collision
;-----------------------------------------------------
StartCondition:
    call    WaitI2cIdle
    iorlw   0x00
    btfss   STATUS, STATUS_Z_POSN
    return

    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON
    bcf     WCOL

    BANKSEL SSPCON2
    bsf     SEN

    movlw   TIMEOUT_MAX
    BANKSEL timeout_count
    movwf   timeout_count

WaitStart:
    BANKSEL PIR2
    btfsc   BCLIF
    goto    StartCollision

    BANKSEL SSPCON2
    btfss   SEN
    goto    StartDone

    BANKSEL timeout_count
    decfsz  timeout_count, f
    goto    WaitStart

    BANKSEL PORTB
    bsf     PORTB, 6
    movlw   0xFF
    return

StartCollision:
    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON
    bcf     WCOL

    BANKSEL PORTB
    bsf     PORTB, 7
    movlw   0xFF
    return

StartDone:
    BANKSEL PORTB
    bsf     PORTB, 0
    movlw   0x00
    return

;-----------------------------------------------------
; Write byte in W to SSPBUF and wait for completion.
; Returns:
;   W = 0x00 on ACK
;   W = 0x01 on NACK
;   W = 0xFF on timeout / collision / WCOL
;-----------------------------------------------------
WriteByte:
    BANKSEL tx_byte
    movwf   tx_byte

    call    WaitI2cIdle
    iorlw   0x00
    btfss   STATUS, STATUS_Z_POSN
    return

    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON
    bcf     WCOL

    BANKSEL SSPBUF
    movf    tx_byte, w
    movwf   SSPBUF

    BANKSEL SSPCON
    btfsc   WCOL
    goto    WriteByteCollision

    movlw   TIMEOUT_MAX
    BANKSEL timeout_count
    movwf   timeout_count

WaitWriteComplete:
    BANKSEL PIR2
    btfsc   BCLIF
    goto    WriteByteCollision

    BANKSEL PIR1
    btfsc   SSPIF
    goto    WriteByteDone

    BANKSEL timeout_count
    decfsz  timeout_count, f
    goto    WaitWriteComplete

    BANKSEL PORTB
    bsf     PORTB, 6
    movlw   0xFF
    return

WriteByteDone:
    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL SSPCON2
    btfsc   ACKSTAT
    goto    WriteByteNack

    movlw   0x00
    return

WriteByteNack:
    movlw   0x01
    return

WriteByteCollision:
    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON
    bcf     WCOL

    BANKSEL PORTB
    bsf     PORTB, 7
    movlw   0xFF
    return

;-----------------------------------------------------
; Generate STOP condition.
; Returns:
;   W = 0x00 on success
;   W = 0xFF on timeout / collision
;-----------------------------------------------------
StopCondition:
    call    WaitI2cIdle
    iorlw   0x00
    btfss   STATUS, STATUS_Z_POSN
    return

    BANKSEL PIR1
    bcf     SSPIF

    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL SSPCON2
    bsf     PEN

    movlw   TIMEOUT_MAX
    BANKSEL timeout_count
    movwf   timeout_count

WaitStop:
    BANKSEL PIR2
    btfsc   BCLIF
    goto    StopCollision

    BANKSEL SSPCON2
    btfss   PEN
    goto    StopDone

    BANKSEL timeout_count
    decfsz  timeout_count, f
    goto    WaitStop

    BANKSEL PORTB
    bsf     PORTB, 6
    movlw   0xFF
    return

StopCollision:
    BANKSEL PIR2
    bcf     BCLIF

    BANKSEL PORTB
    bsf     PORTB, 7
    movlw   0xFF
    return

StopDone:
    BANKSEL PORTB
    bsf     PORTB, 3
    movlw   0x00
    return

;-----------------------------------------------------
; Small delay so LEDs / scope state changes are easier to see.
;-----------------------------------------------------
DelayBetweenPasses:
    movlw   INTERPASS_DELAY
    BANKSEL delay_count
    movwf   delay_count

DelayLoop:
    nop
    decfsz  delay_count, f
    goto    DelayLoop
    return

END

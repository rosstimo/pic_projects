; Simple PIC16F883 I2C master transmit demo
; Sends: START -> 0xA0 -> 0xA5 -> STOP
; Debug on PORTB:
;   RB0 = start complete
;   RB1 = address ACK
;   RB2 = data ACK
;   RB3 = stop complete
;   RB4 = address NACK
;   RB5 = data NACK

PROCESSOR 16F883
RADIX dec 
        
;------------------------------------------------------------------------------
;Configuration
;------------------------------------------------------------------------------
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
  CONFIG  "BOR4V = BOR40V"        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  "WRT = OFF"             ; Flash Program Memory Self Write Enable bits (Write protection off)

;Include Statements
#include <xc.inc>

; --- Variable Definitions ---


;Tell the linker to put the program section code in a specific program memory address
; -Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
     
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
    bsf     TRISC, 3        ; RC3 = SCL input
    bsf     TRISC, 4        ; RC4 = SDA input

    ; MSSP setup
    BANKSEL SSPCON          
    clrf    SSPCON                  ;Clear SSPCON before configuring
    BANKSEL SSPCON2
    clrf    SSPCON2                 ;Clear SSPCON2 before configuring

    ; Standard speed I2C
    ; SMP=1, CKE=0
    BANKSEL SSPSTAT
    movlw   0x80                    ;Slew rate control disabled for standard speed mode (100 kHz and 1 MHz)
    movwf   SSPSTAT

    ; 100 kHz @ FOSC = 4 MHz
    ; SCL = FOSC / (4 * (SSPADD + 1))
    ; 100k = 4M / (4 * (9 + 1))
    BANKSEL SSPADD
    movlw   0x09
    movwf   SSPADD

    ; SSPEN=1, SSPM<3:0>=1000 -> I2C Master mode
    BANKSEL SSPCON
    movlw   00101000B           ;enable MSSP, I2C Master mode 
    movwf   SSPCON

    BANKSEL PIR1
    bcf     SSPIF               ;clear MSSP interrupt flag again

MainLoop:
    call    SendOnce
Wait:
    ;goto    Wait
    goto    MainLoop

SendOnce:
    BANKSEL PORTB
    clrf    PORTB               ; Clear debug bits each pass
    BANKSEL PIR1
    bcf     SSPIF               ;clear MSSP interrupt flag before starting
    BANKSEL SSPCON2
    bsf     SEN                 ;Initiate START condition on the bus
WaitStart:
    btfsc   SEN                 ;Wait for START condition to complete
    goto    WaitStart
    BANKSEL PIR1
    bcf     SSPIF               ;clear MSSP interrupt flag again
    BANKSEL PORTB
    bsf     PORTB, 0            ;set start complete
    BANKSEL SSPBUF              ; ADDRESS BYTE: 7-bit slave address 0x50, write bit = 0
    movlw   0xA1                ; bus byte = 0xA0 or 1010000w
    movwf   SSPBUF              ;Load the address byte into the SSPBUF to start transmission
WaitAddr:
    BANKSEL PIR1
    btfss   SSPIF               ;Wait for address byte to be sent
    goto    WaitAddr
    bcf     SSPIF               ;Clear MSSP interrupt flag
    BANKSEL SSPCON2
    btfsc   ACKSTAT             ;Check ACK/NACK from slave after address byte
    goto    AddrNack            ;If NACK, skip to stop condition
    BANKSEL PORTB
    bsf     PORTB, 1            ;else set address ACK and continue to data byte
    goto    SendData

AddrNack:
    BANKSEL PORTB
    bsf     PORTB, 4            ;set address NACK
    goto    SendStop

SendData:
    BANKSEL SSPBUF
    movlw   0x55                ;Data byte to send
    movwf   SSPBUF              ;Load the data byte into the SSPBUF to start transmission

WaitData:
    BANKSEL PIR1
    btfss   SSPIF               ;wait for data byte to be sent
    goto    WaitData
    bcf     SSPIF               ;clear MSSP interrupt flag
    BANKSEL SSPCON2             
    btfsc   ACKSTAT             ;check ACK/NACK from slave    
    goto    DataNack            ;if NACK, skip to stop condition
    BANKSEL PORTB
    bsf     PORTB, 2            ;else set data ACK
    goto    SendStop            ;continue to stop condition

DataNack:
    BANKSEL PORTB
    bsf     PORTB, 5            ; set data NACK
SendStop:
    BANKSEL SSPCON2
    bsf     PEN                 ;Initiate STOP condition on the bus
WaitStop:
    btfsc   PEN                 ;Wait for STOP condition to complete
    goto    WaitStop
    BANKSEL PORTB
    bsf     PORTB, 3            ; set stop complete

    return                      

END
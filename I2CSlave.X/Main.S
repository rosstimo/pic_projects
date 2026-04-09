;==============================================================================
; Name:
; Course:
; Semester:
; Assignment:
; Device:      PIC16F883
; Toolchain:   MPLAB X + pic-as
; Git URL:
; Linker Options:   -Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
;==============================================================================

RADIX dec
PROCESSOR 16F883

; Include Statements
#include <xc.inc>

;--------------------------------------
; Device Configuration
;--------------------------------------
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

;--------------------------------------
; User constants and variables
;--------------------------------------

I2C_SLAVE_ADDRESS   EQU 0x50          ; example 7-bit slave address. will be shifted left by 1 bit when implemented in SSPADD<7:1>
;-----------------------------------------------------
; I2C flag bits for i2c_flags
;-----------------------------------------------------
I2CF_D0             EQU 0            ; count consecutive data bytes received or transmitted, can be used for tracking position in a multi-byte transfer
I2CF_D1             EQU 1            ; count consecutive data bytes received or transmitted, can be used for tracking position in a multi-byte transfer
I2CF_D2             EQU 2            ; count consecutive data bytes received or transmitted, can be used for tracking position in a multi-byte transfer
I2CF_D_A            EQU 3            ; data/address bit
I2CF_R_W            EQU 4            ; read/write bit
I2CF_GENERAL_CALL   EQU 5            ; general call bit
I2CF_OVERFLOW       EQU 6            ; overflow bit
I2CF_COLLISION      EQU 7            ; collision bit

;-----------------------------------------------------
; I2C SSPSTAT bits in i2c_status_snapshot
;-----------------------------------------------------
STAT_R_W         EQU 2               ;descriptive name for read/write bit
STAT_D_A         EQU 5               ;descriptive name for data/address bit
;-----------------------------------------------------
; Shared / common RAM 0x70 to 0x7F. All Banks can access.
;-----------------------------------------------------
PSECT udata_shr
w_temp:
    DS 1
status_temp:
    DS 1
pclath_temp:
    DS 1

;-----------------------------------------------------
; Banked RAM used by this module
;-----------------------------------------------------
PSECT udata_bank0
i2c_flags:
    DS 1
i2c_status_snapshot:
    DS 1
i2c_last_address_byte:
    DS 1
i2c_byte_index:
    DS 1
i2c_rx_byte_0:
    DS 1
i2c_rx_byte_1:
    DS 1
i2c_rx_byte_2:
    DS 1
i2c_tx_byte_0:
    DS 1
i2c_tx_byte_1:
    DS 1
i2c_tx_byte_2:
    DS 1
i2c_dummy:
    DS 1
;------------------------------------------------------------------------------
; Start of Assembly Code
;------------------------------------------------------------------------------

; Reset Vector at 0000h. Execution starts here after reset.
PSECT resetVect,class=CODE,delta=2
ResetVector:            
    goto Setup

; Interrupt Vector at 0004h. Execution starts here after an interrupt.
PSECT isrVect,class=CODE,delta=2
InterruptVector:
    goto IsrHandler

; Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2

;------------------------------------------------------------------------------
; Start of Setup
;------------------------------------------------------------------------------
Setup:

;----------------------------------
; Setup PORTB for debug output
;----------------------------------
    BANKSEL ANSEL
    clrf    ANSEL
    BANKSEL ANSELH
    clrf    ANSELH
    BANKSEL PORTB
    clrf    PORTB
    BANKSEL TRISB
    clrf    TRISB

;----------------------------------
; I2C slave testing setup
; not needed for production code.
;----------------------------------
    BANKSEL i2c_tx_byte_0
    movlw   0x11
    movwf   i2c_tx_byte_0
    movlw   0x22
    movwf   i2c_tx_byte_1
    movlw   0x33
    movwf   i2c_tx_byte_2

    clrf    i2c_byte_index
;----------------------------------
; I2C slave setup
;----------------------------------

    ; I2C pins must be inputs
    BANKSEL TRISC
    bsf     TRISC, 3            ; RC3 = SCL
    bsf     TRISC, 4            ; RC4 = SDA

    ; clear MSSP registers to ensure known state and ready BUS before configuring
    BANKSEL SSPCON
    clrf    SSPCON              ; Ensure Default state. Specifically clear SSPEN, WCOL, SSPOV

    BANKSEL SSPSTAT             
    clrf    SSPSTAT             ; Ensure Default state.
    movf    SSPBUF, w           ; Explicitly clear BF bit with read of SSPBUF

    BANKSEL SSPCON2
    clrf    SSPCON2             ; Ensure Default state.

    BANKSEL PIR1
    bcf     SSPIF               ; Clear MSSP interrupt flag

    ; set slave address in SSPADD<7:1> register. Bit 0 is not used for address.
    BANKSEL i2c_dummy
    movlw   I2C_SLAVE_ADDRESS
    movwf   i2c_dummy           ; move 7-bit slave address to temporary register
    rlf     i2c_dummy, w        ; shift left by 1 bit because SSPADD<7:1> holds the 7-bit slave address.
    BANKSEL SSPADD              ; bit 7 = 1, respond to general call address 0x00
    movwf   SSPADD              ; Set slave address in SSPADD register. Bit 0 is not used for address.

    ; Set SSPCON2 Slave options
    BANKSEL SSPCON2
    bsf     GCEN                ; GCEN = 1, enable general call address 0x00
    bsf     SEN                 ; SEN = 1, slave clock stretching enabled

    ; SSPEN=0, CKP=0, SSPM<3:0>=0110 -> I2C slave 7-bit
    ; keep MSSP disabled until we finish configuring to avoid unintended behavior on the bus
    ; hold the bus with clock stretching until we're done configuring
    BANKSEL SSPCON
    movlw   0x06
    movwf   SSPCON

    ;Enable MSSP module
    bsf     SSPEN
    ;Release the bus after MSSP is enabled
    bsf     CKP
    BANKSEL PIR1
    bcf     SSPIF               ; Clear MSSP interrupt flag
    BANKSEL PIE1
    bsf     SSPIE               ; Enable MSSP interrupt
;----------------------------------
;   Enable Interrupts
;----------------------------------
    BANKSEL INTCON
    bsf     PEIE                ; peripheral interrupts enabled
    bsf     GIE                 ; global interrupts enabled
    goto    MainLoop

;------------------------------------------------------------------------------
; Main Loop
;------------------------------------------------------------------------------
MainLoop:
    ; add main loop code here
    ; move isc_flags to PORTB for debug output
    BANKSEL i2c_flags
    movf    i2c_flags, w
    BANKSEL PORTB
    movwf   PORTB
    goto MainLoop

;------------------------------------------------------------------------------
;Subroutines
;------------------------------------------------------------------------------

;------------------------------
; ResetI2c
; Input:  none
; Output: none
; Uses:   none
; Stack Depth: 1           
; Description:
; Call this subroutine to reset the I2C slave state after an
; error condition or to return the bus to a known state. 
;------------------------------
ResetI2c:
    ; add code to reset I2C slave state here
    BANKSEL SSPCON
    bcf     WCOL            ; clear WCOL to allow new transmission
    bcf     SSPOV           ; clear SSPOV to allow new reception
    movf    SSPBUF, w       ; clear BF bit by reading SSPBUF
    BANKSEL PIR1
    bcf     SSPIF           ; clear MSSP interrupt flag
    return
                            
;------------------------------------------------------------------------------
; IsrHandler
; Input:  none
; Output: none
; Uses:   w_temp, status_temp, pclath_temp
; These registers are in common ram so no bank switching is needed.
;------------------------------------------------------------------------------
IsrHandler:
    movwf   w_temp          ; save WREG
    swapf   STATUS,w        ; read STATUS with swap to avoid affecting status flags
    movwf   status_temp     ; save STATUS
    movf    PCLATH,w        
    movwf   pclath_temp     ; save PCLATH

    BANKSEL PIR1
    btfsc   SSPIF           ; check if MSSP interrupt
    goto    ServiceI2cSlave

LeaveIsr:
    movf    pclath_temp,w   
    movwf   PCLATH          ; restore PCLATH
    swapf   status_temp,w   ; read saved STATUS swapping nibbles back to original
    movwf   STATUS          ; restore STATUS
    swapf   w_temp,f        ; prepare for restoring WREG without affecting flags
    swapf   w_temp,w        ; restore WREG without affecting flags
    retfie

;------------------------------------------------------------------------------
; Interrupt Service Routines
;------------------------------------------------------------------------------

;--------------------------------------
; I2C Slave ISR
; Input:  i2c_flags, i2c_tx_byte
; Output: i2c_flags, i2c_rx_byte
; Uses:   i2c_flags, i2c_status_snapshot, i2c_last_address_byte, i2c_rx_byte, i2c_tx_byte
; Stack Depth: 1
;--------------------------------------
ServiceI2cSlave:
CheckOverflow:
    BANKSEL SSPCON
    btfss   SSPOV                           ; check for receive overflow error
    goto    CheckCollision                  ; if no overflow, check for collision error
    BANKSEL i2c_flags
    bsf     i2c_flags, I2CF_OVERFLOW
    goto    ResetBus                        ; reset bus and leave
CheckCollision:
    BANKSEL SSPCON
    btfss   WCOL                            ; check for write collision error
    goto    SaveSSPSTAT                     ; if no collision, continue
    BANKSEL i2c_flags
    bsf     i2c_flags, I2CF_COLLISION
    goto    ResetBus                        ; reset bus and leave
    SaveSSPSTAT:
    BANKSEL SSPSTAT
    movf    SSPSTAT, w                      ;Snapshot SSPSTAT so decisions are stable.
    BANKSEL i2c_status_snapshot
    movwf   i2c_status_snapshot
    btfss   i2c_status_snapshot, STAT_D_A   ; if this is an address or data byte
    goto    IsAddressByte                   ; if D/A=0, this is an address byte
    goto    IsDataByte                      ; if D/A=1, this is a data byte

IsAddressByte:
    BANKSEL i2c_flags
    bcf     i2c_flags, I2CF_D_A             ; clear D/A
    BANKSEL SSPBUF
    movf    SSPBUF, w                       ; read address byte to clear BF bit and get address
    BANKSEL i2c_last_address_byte
    movwf   i2c_last_address_byte
CheckGeneralCall:
    movlw   0x00
    xorwf   i2c_last_address_byte, w
    btfsc   ZERO                            ; check if STATUS ZERO bit is set 
    goto    ServiceGeneralCall              ; is general call address 0x00
    goto    ServiceAddressMatch             ; not general call

ServiceGeneralCall:
    BANKSEL i2c_flags
    bsf     i2c_flags, I2CF_GENERAL_CALL    ; set general call flag
    goto    LeaveI2cSlave                   ; for now we just set the flag and leave

ServiceAddressMatch:
    ; additional address matching can be done here if desired, 
    ; but for now we just assume any non-general call address is a match
    goto    CheckReadWrite                  ; continue
CheckReadWrite:
    BANKSEL i2c_status_snapshot
    btfsc   i2c_status_snapshot, STAT_R_W   ; check R/W bit
    goto    ReadRequestFromMaster           ; if R/W=1, master is requesting to read from slave
    goto    WriteRequestFromMaster          ; if R/W=0, master is requesting to write to slave

ReadRequestFromMaster:
    BANKSEL i2c_flags
    bsf     i2c_flags, I2CF_R_W             ; set R/W flag to indicate read request from master
    BANKSEL i2c_byte_index
    clrf    i2c_byte_index                  ; reset byte index for tracking multi-byte reads from master  
    BANKSEL i2c_tx_byte_0
    movf    i2c_tx_byte_0, w                ; first byte to send
    BANKSEL SSPBUF
    movwf   SSPBUF                          ; queue first transmit byte now
    BANKSEL i2c_byte_index
    incf    i2c_byte_index, f               ; next transmit will be byte 1
    goto    LeaveI2cSlave                   ; for now we just set the flag and leave.

WriteRequestFromMaster:
    BANKSEL i2c_flags
    bcf     i2c_flags, I2CF_R_W             ; clear R/W flag to indicate write request from master 
    BANKSEL i2c_byte_index
    clrf    i2c_byte_index                  ; reset byte index for tracking multi-byte writes from master
    goto    LeaveI2cSlave                   ; for now we just clear the flag and leave.

IsDataByte:
    BANKSEL i2c_flags                   
    bsf     i2c_flags, I2CF_D_A             ; set D/A flag to indicate this is a data byte
    btfsc   i2c_flags, I2CF_R_W             ; check R/W bit to determine if master is requesting a read or write
    goto    DataReadFromSlave               ; master is requesting to read from slave
    goto    DataWriteToSlave                ; master is writing data to slave

DataReadFromSlave:
    BANKSEL i2c_byte_index
    movf    i2c_byte_index, w
    xorlw   1
    btfsc   ZERO
    goto    SendTx1

    movf    i2c_byte_index, w
    xorlw   2
    btfsc   ZERO
    goto    SendTx2

    ; default: repeat last byte if master keeps reading
    BANKSEL i2c_tx_byte_2
    movf    i2c_tx_byte_2, w
    goto    QueueTxByte

SendTx1:
    BANKSEL i2c_tx_byte_1
    movf    i2c_tx_byte_1, w
    goto    QueueTxByte

SendTx2:
    BANKSEL i2c_tx_byte_2
    movf    i2c_tx_byte_2, w

QueueTxByte:
    BANKSEL SSPBUF
    movwf   SSPBUF

    BANKSEL i2c_byte_index
    incf    i2c_byte_index, f

    goto    LeaveI2cSlave

DataWriteToSlave:
    BANKSEL SSPBUF
    movf    SSPBUF, w                  ; read once only

    BANKSEL i2c_dummy
    movwf   i2c_dummy                  ; temporary holding register

    BANKSEL i2c_byte_index
    movf    i2c_byte_index, w
    xorlw   0
    btfsc   ZERO
    goto    StoreRx0

    movf    i2c_byte_index, w
    xorlw   1
    btfsc   ZERO
    goto    StoreRx1

    goto    StoreRx2

StoreRx0:
    BANKSEL i2c_dummy
    movf    i2c_dummy, w
    BANKSEL i2c_rx_byte_0
    movwf   i2c_rx_byte_0
    goto    BumpRxIndex

StoreRx1:
    BANKSEL i2c_dummy
    movf    i2c_dummy, w
    BANKSEL i2c_rx_byte_1
    movwf   i2c_rx_byte_1
    goto    BumpRxIndex

StoreRx2:
    BANKSEL i2c_dummy
    movf    i2c_dummy, w
    BANKSEL i2c_rx_byte_2
    movwf   i2c_rx_byte_2

BumpRxIndex:
    BANKSEL i2c_byte_index
    incf    i2c_byte_index, f
    goto    LeaveI2cSlave

ResetBus:
    BANKSEL SSPCON
    bcf     WCOL                            ; clear WCOL to allow new transmission
    bcf     SSPOV                           ; clear SSPOV to allow new reception
    BANKSEL SSPBUF
    movf    SSPBUF, w                       ; clear BF bit by reading SSPBUF
LeaveI2cSlave:
    BANKSEL PIR1
    bcf     SSPIF                           ; clear MSSP interrupt flag
    BANKSEL SSPCON
    bsf   CKP                               ;release the clock if clock stretching is enabled
    goto LeaveIsr
END

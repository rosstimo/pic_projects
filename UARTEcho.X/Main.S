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
; W_TEMP          EQU 0x70        ; WREG save (common RAM)
; STATUS_TEMP     EQU 0x71        ; STATUS save (common RAM)
; PCLATH_TEMP     EQU 0x72        ; PCLATH save (common RAM)

; -------------------------
; Status flag bit numbers
; -------------------------
;rxStatus
RX_READY_BIT       EQU 0
RX_FERR_BIT        EQU 1
RX_OERR_BIT        EQU 2
RX_SOFTOVF_BIT     EQU 3

; -------------------------
; RAM objects
; -------------------------
PSECT udata_shr
W_TEMP:                         ; WREG save (common RAM)
    DS 1                            
STATUS_TEMP:                     ; STATUS save (common RAM)
    DS 1
PCLATH_TEMP:                     ; PCLATH save (common RAM)
    DS 1

PSECT udata_bank0
rxByte:
    DS 1                        ; latest good Rx byte
rxStatus:
    DS 1                        ; Rx status flags
txByteTemp:
    Ds 1                        ; Tx byte temporary storage

;Linker Options: -Wl,-presetVect=0h,-pisrVect=04h,-pcode=08h
     
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


; ------------------------------------------------------------
; Serial Port Setup
; Setup UART common code for both transmit and receive
; ------------------------------------------------------------
    ; Setup baud rate
    ; 9600 baud at 4 MHz with BRGH = 1, BRG16 = 0, SPBRG = 25
    BANKSEL BAUDCTL
    BCF     BRG16

    BANKSEL SPBRG
    MOVLW   25
    MOVWF   BANKMASK(SPBRG)

    ; Setup async serial mode
    BANKSEL TXSTA
    BCF     SYNC
    BSF     BRGH

    ; Enable serial port
    BANKSEL RCSTA
    BSF     SPEN

; ------------------------------------------------------------
; SerialTxSetup
; Set up UART transmit for 9600 baud at 4 MHz
; ------------------------------------------------------------
    ; RC6/TX is used by the serial port
    BANKSEL TRISC
    BCF     TRISC6

    ; Enable transmitter
    BANKSEL TXSTA
    BCF     TX9
    BSF     TXEN

; ------------------------------------------------------------
; SerialRxIntSetup
; Set up UART receive interrupt for 9600 baud at 4 MHz
; ------------------------------------------------------------
    ; RC7/RX is an input
    BANKSEL TRISC
    BSF     TRISC7

    ; Enable serial port, 8-bit receive, continuous receive
    BANKSEL RCSTA
    BCF     RX9
    BSF     CREN

    ; Clear software status flags
    BANKSEL rxStatus
    CLRF    BANKMASK(rxStatus)

    ; Enable UART receive interrupt only
    BANKSEL PIE1
    BSF     RCIE

    ; Enable interrupts at the end of setup after all configuration is done
    BANKSEL INTCON
    BSF     PEIE                ; Enable peripheral interrupts
    BSF     GIE                 ; Enable global interrupts    
    GOTO    MainLoop

    
; ------------------------------------------------------------
;Main Program Loop (Loops forever)
; ------------------------------------------------------------
MainLoop:
    ; Check for a new received byte
    BANKSEL rxStatus
    BTFSC   BANKMASK(rxStatus), RX_READY_BIT
    CALL ProcessRxByte
    GOTO MainLoop

ProcessRxByte:
    ; Get the received byte
    BANKSEL rxByte
    MOVF    BANKMASK(rxByte), W

    ; Process byte here
    CALL    TxByte        ; Echo byte back

    ; Mark the byte as consumed
    BANKSEL rxStatus
    BCF     BANKMASK(rxStatus), RX_READY_BIT
    RETURN

; ------------------------------------------------------------
; TxByte
; Send one byte
; Input: W = byte to send
; ------------------------------------------------------------
TxByte:
    ; Save the byte to send
    BANKSEL txByteTemp
    MOVWF   BANKMASK(txByteTemp)

TxByteWait:
    ; Wait for TXREG to be empty
    BANKSEL PIR1
    BTFSS   TXIF
    GOTO    TxByteWait

    ; Send the byte
    BANKSEL txByteTemp
    MOVF    BANKMASK(txByteTemp), w

    BANKSEL TXREG
    MOVWF   BANKMASK(TXREG)

    RETURN

; ------------------------------------------------------------
; Interrupt Service Routine
; ------------------------------------------------------------
PSECT code
ISR_Handler:
    ; Save context (WREG, STATUS, PCLATH)
    BANKSEL W_TEMP
    MOVWF W_TEMP                    ; Save WREG
    SWAPF STATUS,W              ; Save STATUS to WREG
    MOVWF STATUS_TEMP		    ; Save STATUS
    MOVF  PCLATH,w              ; Needed when using calculated jumps like lookup tables
    MOVWF PCLATH_TEMP           ; Save PCLATH
    ; Determine interrupt. Highest priority top down.

    ; Is this a UART receive interrupt?
    BANKSEL PIR1
    BTFSC   RCIF
    GOTO    SerialRx

    ;----------------------------------------------------------
LeaveISR:
    ; Restore context (WREG, STATUS, PCLATH) and return from interrupt
    BANKSEL W_TEMP
    MOVF   PCLATH_TEMP,W
    MOVWF  PCLATH               ; Restore PCLATH
    SWAPF  STATUS_TEMP,W		
    MOVWF  STATUS               ; Restore STATUS to proper value
    SWAPF  W_TEMP,F             ; Restore W without touching status flags
    SWAPF  W_TEMP,W             ; Restore W without touching status flags
    RETFIE

; ------------------------------------------------------------
; SerialRx
; Call this from your ISR after saving context
;
; Good byte:
;   - stores byte in rxByte
;   - sets RX_READY
;
; Error handling:
;   - framing error: discard bad byte, set RX_FERR
;   - overrun error: reset receiver, set RX_OERR
;   - software overflow: discard new byte, set RX_SOFTOVF
; ------------------------------------------------------------
SerialRx:
    ; Hardware overrun error?
    BANKSEL RCSTA
    BTFSC   OERR
    GOTO    SerialRx_HandleOverrun

    ; Framing error?
    BTFSC   FERR
    GOTO    SerialRx_HandleFraming

    ; Mailbox already full?
    BANKSEL rxStatus
    BTFSC   BANKMASK(rxStatus), RX_READY_BIT
    GOTO    SerialRx_HandleSoftOverflow

    ; Read the good byte and store it
    BANKSEL RCREG
    MOVF    BANKMASK(RCREG), W

    BANKSEL rxByte
    MOVWF   BANKMASK(rxByte)

    BANKSEL rxStatus
    BSF     BANKMASK(rxStatus), RX_READY_BIT
    GOTO    LeaveISR

SerialRx_HandleSoftOverflow:
    ; Keep old byte, discard new byte
    BANKSEL RCREG
    MOVF    BANKMASK(RCREG), W

    BANKSEL rxStatus
    BSF     BANKMASK(rxStatus), RX_SOFTOVF_BIT
    GOTO LeaveISR

SerialRx_HandleFraming:
    ; Read and discard bad byte
    BANKSEL RCREG
    MOVF    BANKMASK(RCREG), W

    BANKSEL rxStatus
    BSF     BANKMASK(rxStatus), RX_FERR_BIT
    GOTO LeaveISR

SerialRx_HandleOverrun:
    ; Reset receiver to clear OERR
    BANKSEL RCSTA
    BCF     CREN
    BSF     CREN

    BANKSEL rxStatus
    BSF     BANKMASK(rxStatus), RX_OERR_BIT
    GOTO LeaveISR

END ; End of code. This is required

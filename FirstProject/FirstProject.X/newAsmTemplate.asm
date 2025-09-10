;HEADER
;NAME
;COURSE
;SEMESTER
;Program/Project
;Git URL

;Device Setup
;-----------------------------------------------------
    
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
#include <pic16f883.inc>


;Code Section
;-----------------------------------------------------
    
;Register/Variable Setup
    SOMEVALUE EQU 0x5f ; asign a value to a variable
    
;Start of Program
    ORG 0x0000           ; Reset vector address
    GOTO Start
    
    ORG 0x0004
    RETFIE
    
;Setup Code that runs once at power up/reset
Start:
    BANKSEL INTCON
    CLRF INTCON
    
    BANKSEL OPTION_REG
    CLRF OPTION_REG
    
    BANKSEL ANSELH
    CLRF ANSELH
    
    BANKSEL IOCB
    CLRF IOCB
    
    BANKSEL PORTB
    CLRF PORTB
    
    BANKSEL TRISB
    CLRF TRISB
    
    BANKSEL WPUB
    MOVLW 0xFF
    MOVWF WPUB
    
    GOTO MainLoop
    
;Main Program Loop (Loops forever)
MainLoop:
    INCF PORTB,1
    GOTO MainLoop
    
END ; End of code. This is required
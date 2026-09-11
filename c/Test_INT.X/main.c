/*
 * File:   main.c
 * Author: tim
 *
 * Created on September 11, 2026, 3:40 PM
 */


// PIC16F883 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = XT        // Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.


#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 4000000UL

// Configuration bits here...

volatile uint8_t count = 0;

void __interrupt() ISR(void)
{
    if (INTCONbits.INTF)
    {
        count++;

        // RB0 is the external interrupt input.
        // Display the count on RB1-RB7.
        PORTB = count << 1;

        // Clear external interrupt flag
        INTCONbits.INTF = 0;
    }
}

int main(void)
{
    // Make PORTB pins digital
    ANSELH = 0x00;

    // Start outputs low
    PORTB = 0x00;

    // RB0 = input, RB1-RB7 = outputs
    TRISB = 0x01;

    // Interrupt on rising edge of RB0/INT
    OPTION_REGbits.INTEDG = 1;

    // Clear the flag before enabling the interrupt
    INTCONbits.INTF = 0;

    // Enable external interrupt
    INTCONbits.INTE = 1;

    // Enable global interrupts
    INTCONbits.GIE = 1;

    while (1)
    {
        // Main program does nothing.
        // PORTB changes only when an INT interrupt occurs.
     }

    return 0;
}
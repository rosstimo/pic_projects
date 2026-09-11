EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "PICkit 3 to PIC16F883 ICSP / Reset"
Date "2026-09-11"
Rev "1"
Comp "Idaho State University - RCET"
Comment1 "PIC16F883 28-pin PDIP programming reference"
Comment2 "High-voltage ICSP course default; LVP disabled"
Comment3 "Based on Microchip DS51795A and DS41287A"
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_01x06 J1
U 1 1 68C3A001
P 2450 3200
F 0 "J1" H 2368 3617 50  0000 C CNN
F 1 "PICkit_3_ICSP" H 2368 3526 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 2450 3200 50  0001 C CNN
F 3 "~" H 2450 3200 50  0001 C CNN
	1    2450 3200
	-1   0    0    -1
$EndComp
$Comp
L Connector_Generic:Conn_01x06 J2
U 1 1 68C3A002
P 7350 3200
F 0 "J2" H 7430 3192 50  0000 L CNN
F 1 "PIC16F883_ICSP_POINTS" H 7430 3101 50  0000 L CNN
F 2 "" H 7350 3200 50  0001 C CNN
F 3 "~" H 7350 3200 50  0001 C CNN
	1    7350 3200
	1    0    0    -1
$EndComp
Wire Wire Line
	2650 3000 7150 3000
Wire Wire Line
	2650 3100 7150 3100
Wire Wire Line
	2650 3200 7150 3200
Wire Wire Line
	2650 3300 7150 3300
Wire Wire Line
	2650 3400 7150 3400
Text Label 3300 3000 0    50   ~ 0
MCLR_VPP
Text Label 3300 3100 0    50   ~ 0
VDD_TARGET
Text Label 3300 3200 0    50   ~ 0
VSS
Text Label 3300 3300 0    50   ~ 0
ICSPDAT_PGD
Text Label 3300 3400 0    50   ~ 0
ICSPCLK_PGC
NoConn ~ 2650 3500
NoConn ~ 7150 3500
$Comp
L Device:R R1
U 1 1 68C3A003
P 4800 2150
F 0 "R1" V 4593 2150 50  0000 C CNN
F 1 "10k" V 4684 2150 50  0000 C CNN
F 2 "" V 4730 2150 50  0001 C CNN
F 3 "~" H 4800 2150 50  0001 C CNN
	1    4800 2150
	0    1    1    0
$EndComp
Wire Wire Line
	4400 2150 4650 2150
Wire Wire Line
	4950 2150 5200 2150
Text Label 4200 2150 2    50   ~ 0
MCLR_VPP
Text Label 5400 2150 0    50   ~ 0
VDD_TARGET
Wire Wire Line
	4200 2150 4400 2150
Wire Wire Line
	5200 2150 5400 2150
Text Notes 2050 2700 0    70   ~ 12
PICkit 3 header
Text Notes 7100 2700 0    70   ~ 12
PIC16F883 programming points
Text Notes 7600 3000 0    50   ~ 0
1: MCLR/VPP  (PDIP pin 1)
Text Notes 7600 3100 0    50   ~ 0
2: VDD       (PDIP pin 20)
Text Notes 7600 3200 0    50   ~ 0
3: VSS       (PDIP pins 8 and 19)
Text Notes 7600 3300 0    50   ~ 0
4: RB7/ICSPDAT (PDIP pin 28)
Text Notes 7600 3400 0    50   ~ 0
5: RB6/ICSPCLK (PDIP pin 27)
Text Notes 7600 3500 0    50   ~ 0
6: RB3/PGM optional for LVP (PDIP pin 24)
Text Notes 2900 1850 0    60   ~ 12
MCLR / reset pull-up
Text Notes 3650 2400 0    50   ~ 0
Microchip recommends roughly 4.7k-10k from MCLR/VPP to VDD.
Text Notes 3650 2500 0    50   ~ 0
10k shown here. Do not place a capacitor directly on MCLR for PICkit 3 use.
Text Notes 2900 3900 0    55   ~ 12
Programming/debug design rules
Text Notes 2900 4100 0    50   ~ 0
- Keep PGC/PGD free of pull-ups, capacitors, and diodes that disturb PICkit signaling.
Text Notes 2900 4250 0    50   ~ 0
- External target power is preferred for general use; PICkit pin 2 senses target VDD.
Text Notes 2900 4400 0    50   ~ 0
- Connect both PIC16F883 VSS pins (8 and 19) to ground.
Text Notes 2900 4550 0    50   ~ 0
- RCET default: high-voltage ICSP with LVP disabled, so PICkit pin 6 is left unconnected.
Text Notes 2900 4800 0    50   ~ 0
PICkit 3 pin order: 1 VPP/MCLR, 2 VDD, 3 VSS, 4 PGD, 5 PGC, 6 LVP.
Text Notes 2900 4950 0    50   ~ 0
Source: Microchip PICkit 3 User's Guide DS51795A, Fig. 1-2 and Sec. 2.4.2-2.4.5.
Text Notes 2900 5100 0    50   ~ 0
Device pins: Microchip PIC16F88X Programming Specification DS41287A, Fig. 1-1.
$EndSCHEMATC

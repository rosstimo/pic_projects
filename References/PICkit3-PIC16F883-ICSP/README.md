# PICkit 3 ↔ PIC16F883 ICSP / Reset Reference

This reference captures the programming and reset connections used for the RCET PIC16F883 work. The editable KiCad schematic is intentionally small so the programming path is easy to inspect in a lab book or on the bench.

## PICkit 3 six-pin header

| PICkit 3 pin | Function | PIC16F883 connection for 28-pin PDIP |
| --- | --- | --- |
| 1 | VPP / MCLR | pin 1, `RE3/MCLR/VPP` |
| 2 | VDD Target | pin 20, `VDD` |
| 3 | VSS | pins 8 and 19, `VSS` |
| 4 | ICSPDAT / PGD | pin 28, `RB7/ICSPDAT` |
| 5 | ICSPCLK / PGC | pin 27, `RB6/ICSPCLK` |
| 6 | LVP | optional `RB3/PGM`, pin 24, only when low-voltage programming is deliberately used |

The normal RCET path uses high-voltage ICSP and disables LVP, so PICkit pin 6 is not part of the required programming connection.

## MCLR / reset network

Use a simple pull-up from `MCLR/VPP` to target `VDD`. Microchip shows a 4.7 kΩ to 10 kΩ pull-up; this schematic uses 10 kΩ.

Do **not** place a capacitor directly on MCLR for this PICkit 3 programming/debug connection. The programmer must move VPP/MCLR quickly.

## PGC / PGD rules

Keep `RB6/ICSPCLK` and `RB7/ICSPDAT` free of circuitry that interferes with programming/debug communication. In particular, the PICkit 3 guide warns against pull-ups, capacitors, and diodes on PGC/PGD.

If those pins are also used by the application, verify that the attached circuitry does not load or clamp the programming signals.

## Target power

The PICkit 3 guide recommends externally powered target hardware for general use. PICkit pin 2 still connects to target VDD so the programmer can sense the target level. Connect both PIC16F883 VSS pins to ground.

## Schematic file and review artifact

- `PICkit3-PIC16F883-ICSP.kicad_sch` is the canonical editable KiCad schematic source.
- GitHub Actions opens that exact source with `kicad-cli` and renders a PDF plus contact-sheet preview.
- Treat a green render workflow as machine verification that the checked-in source is a valid KiCad schematic. Human review still confirms that the drawing is legible and communicates the intended bench wiring clearly.

## Authoritative sources

- Microchip, *PICkit 3 Programmer/Debugger User's Guide*, DS51795A, Figure 1-2 and Sections 2.4.2 through 2.4.5.
- Microchip, *PIC16F88X Memory Programming Specification*, DS41287A, Section 1 and Figure 1-1.
- Microchip, *PIC16F883/884/886/887 Data Sheet*, device pin diagrams and pin summary.

The schematic is a course wiring reference, not a substitute for checking the current device and programmer documentation before changing the hardware design.

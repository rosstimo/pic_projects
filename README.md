# RCET PIC Projects and References

This repository is the shared RCET home for PIC16F883 assembly examples and technical references used by RCET 3373 and RCET 3375.

## Start here

- [`References/Microchip-Documentation-Guide.md`](References/Microchip-Documentation-Guide.md) - categorized student/instructor index of relevant official Microchip data sheets, errata, family manuals, toolchain guides, application notes, technical briefs, Tips 'N Tricks, and other supplemental documentation.
- [`Template_Main.S`](Template_Main.S) - canonical PIC16F883 PIC Assembler starter source.
- [`RCET_PIC-AS_Style_Guide.md`](RCET_PIC-AS_Style_Guide.md) - required RCET PIC-AS formatting, naming, banking, PSECT, subroutine, and ISR conventions.
- [`References/MPLAB-PICkit3-Setup.md`](References/MPLAB-PICkit3-Setup.md) - supported MPLAB X/PICkit 3 version path and first-project setup.
- [`References/MPLAB-Simulator-Checklist.md`](References/MPLAB-Simulator-Checklist.md) - short simulator workflow for stepping, registers, breakpoints, and program-memory verification.
- [`References/PIC16F883-Subroutines-Stack.md`](References/PIC16F883-Subroutines-Stack.md) - CALL/RETURN, Program Counter, return stack, and timing checklist.
- [`References/PIC16F883-Interrupts.md`](References/PIC16F883-Interrupts.md) - interrupt reasoning checklist, context save/restore, vector placement, and RB0/INT worked path.
- [`References/PIC16F883-Computed-GOTO.md`](References/PIC16F883-Computed-GOTO.md) - ADDWF PCL/RETLW lookup tables and the 256-word PCL boundary hazard.

## Canonical starter rule

`Template_Main.S` is the current shared starter source. Existing project folders in this repository are examples and historical working projects. Do not treat an older project folder as the course starter unless an assignment explicitly says to use it.

The current course linker placement used with the template is:

```text
-Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
```

After building, verify the linked result in MPLAB X Program Memory rather than assuming the requested placement occurred.

## Authority

For PIC16F883 device behavior, use the current PIC16F882/883/884/886/887 data sheet together with the current silicon errata. Use the PICmicro Mid-Range MCU Family Reference Manual for architecture and broader family explanations, and the MPLAB XC8 PIC Assembler documentation for assembler/linker behavior.

The canonical external-document index is [`References/Microchip-Documentation-Guide.md`](References/Microchip-Documentation-Guide.md). Add useful official Microchip sources there as they are discovered rather than creating separate document lists in individual courses.

Course examples are references, not replacements for those documents.
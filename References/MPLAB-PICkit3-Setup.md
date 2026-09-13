# MPLAB X + PICkit 3 Setup for RCET PIC16F883 Projects

## Supported course tool path

RCET currently uses PICkit 3 hardware. Microchip states that **MPLAB X IDE v6.20 is the final MPLAB X release with PICkit 3 support**. MPLAB X v6.25 and later do not support PICkit 3.

Official Microchip pages:

- MPLAB X IDE: https://www.microchip.com/en-us/development-tool/MPLAB-X-IDE
- MPLAB ecosystem archive: https://www.microchip.com/en-us/tools-resources/archives/mplab-ecosystem

Use the archived **MPLAB X IDE v6.20** installer for the classroom PICkit 3 workflow.

## First-project checklist

1. Install MPLAB X IDE v6.20.
2. Install the current XC8 toolchain that provides PIC Assembler (`pic-as`) and the PIC16F883 device support required by the course.
3. Create a PIC16F883 standalone project using PIC Assembler.
4. Add a preprocessed assembly source named `main.S`.
5. Start from [`../Template_Main.S`](../Template_Main.S) rather than copying a random older project.
6. Keep the course configuration-bit block visible near the top of the source and verify it against the actual hardware used for the assignment.
7. Add the course linker placement options:

```text
-Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h
```

8. Build the project.
9. Open Program Memory and verify that reset entry begins at `0000h`, interrupt entry begins at `0004h`, and ordinary course code is linked at `0008h` as intended.
10. Select the PICkit 3 and target device only after the project builds cleanly.

## Why the linker check matters

The vector addresses are hardware-defined, but the names `resetVect`, `isrVect`, and `code` are course/source choices. The linker options connect those named PSECTs to the intended addresses. Do not treat an IDE property remembered from lecture as invisible magic. Keep the command in the source header or project documentation and verify the linked result.

## PICkit 3 troubleshooting boundary

If the project builds but the PICkit 3 does not appear in MPLAB X, separate tool detection from source/build problems. On a virtual machine, check USB passthrough and whether the host has claimed the programmer before changing project source or configuration bits.
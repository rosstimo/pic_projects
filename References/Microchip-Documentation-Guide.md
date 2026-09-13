# Microchip Documentation Guide for PIC16F883

Last reviewed: 2026-09-13

This is the shared RCET index to official Microchip documentation relevant to the PIC16F883, the classic mid-range PIC architecture, MPLAB X, PIC Assembler (`pic-as`), XC8 C, programming/debugging, and the peripherals used in RCET 3373/3375.

Use this page to find the right source quickly. It is not a replacement for the source documents.

## How to use this guide

Documents are labeled by how directly they apply to the PIC16F883:

- **Primary device source** - device-specific documentation. Use this first for PIC16F883 behavior.
- **Family reference** - broader classic mid-range PIC architecture and peripheral explanations. Useful for understanding, but verify device-specific details in the PIC16F883 data sheet.
- **Toolchain reference** - authoritative for assembler, compiler, linker, IDE, programmer, or debugger behavior.
- **Supplemental** - useful Microchip application notes, technical briefs, tutorials, and design guides.
- **Legacy supplemental** - written for older or different PIC devices, but still useful for concepts. Never let one override the PIC16F883 data sheet or errata.

For device behavior, use the **current data sheet together with the current silicon errata**. If they conflict with an older family manual or application note, the device-specific documents win.

---

# 1. PIC16F883 primary device documentation

## PIC16F883 product page

**Type:** Primary device source / discovery hub  
**URL:** https://www.microchip.com/en-us/product/PIC16F883

Microchip's current product page. Use it to locate the current data sheet, product status, packaging information, CAD resources, and other device-specific material.

## PIC16F882/883/884/886/887 Data Sheet - DS40001291H

**Type:** Primary device source  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf

The main authority for PIC16F883 hardware behavior. It contains memory organization, instruction behavior, SFRs, I/O, oscillator configuration, timers, interrupts, ADC, comparators, EUSART, MSSP/I2C/SPI, EEPROM, electrical specifications, and device timing.

For RCET work, this should normally be the first technical source opened when beginning a new peripheral.

## PIC16F88X Family Silicon Errata and Data Sheet Clarifications - DS80000302

**Type:** Primary device source  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/Errata/PIC16F88X-Family-Si-Errata-Data-Sheet-Clarifications-DS80000302.pdf

Documents known silicon anomalies, affected silicon revisions, workarounds, and data-sheet clarifications. Check this whenever hardware behavior does not match the data sheet or before relying heavily on a peripheral in a design.

The errata is part of the authoritative device documentation, not optional background reading.

## PIC16F88X Memory Programming Specification - DS41287D

**Type:** Primary device source  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/ProgrammingSpecifications/41287D.pdf

Describes how the PIC16F88X family is programmed and verified, including ICSP signals, programming modes, configuration memory, Device ID, and programming timing. Most students will not implement a programmer, but this document is valuable when reasoning about PICkit wiring, ICSP pins, LVP, MCLR/VPP, or programming failures.

---

# 2. Classic mid-range PIC architecture

## PICmicro Mid-Range MCU Family Reference Manual - DS33023A

**Type:** Family reference  
**URL:** https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf

A broad architectural reference for classic mid-range PIC MCUs. It explains the CPU, memory organization, instruction set behavior, interrupts, timers, I/O, serial peripherals, ADC, EEPROM, and other modules in more depth than many individual data sheets.

This manual predates the PIC16F883 and sometimes describes older implementations. Use it for architecture and explanation, then verify registers, pins, bit names, and peripheral behavior in the PIC16F883 data sheet.

## Compiled Tips 'N Tricks Guide - DS01146B

**Type:** Supplemental  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/SupportingCollateral/01146B.pdf

A large collection of practical Microchip hardware and software design ideas. Topics include delay techniques, bit manipulation, sensor interfacing, low-power design, comparators, CCP/PWM, motor control, level shifting, state-machine ideas, and other embedded design patterns.

Not every example targets the PIC16F883, but it is a useful idea/reference book for labs and projects.

---

# 3. PIC Assembler, XC8 C, and linker documentation

## MPLAB XC8 PIC Assembler User's Guide - DS50002974

**Type:** Toolchain reference  
**URL:** https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB_XC8_PIC_Assembler_Users_Guide_50002974.pdf

The authoritative reference for `pic-as`. Use it for assembler syntax, directives, options, PSECTs, linker behavior, map/listing files, macros, symbols, data allocation, banking, paging, and command-line behavior.

When the question is "what does `pic-as` do with this source?", this guide is more authoritative than an old MPASM example.

## MPLAB XC8 PIC Assembler User's Guide for Embedded Engineers

**Type:** Toolchain reference / tutorial  
**URL:** https://onlinedocs.microchip.com/oxy/GUID-205B1F42-0E06-45E1-8D34-E3D05C15710F-en-US-3/index.html

A more example-driven companion to the full assembler manual. It includes basic mid-range projects, `xc.inc`, macros, PSECTs, banking, multiple source files, paging, linear memory, and build examples. This is often a better first stop for students than the full reference manual.

## MPASM to MPLAB XC8 PIC Assembler Migration Guide

**Type:** Toolchain reference  
**URL:** https://onlinedocs.microchip.com/oxy/GUID-6EF91A11-1A5C-4C0A-8A18-67AD6D50B17B-en-US-2/index.html

Maps legacy MPASM constructs to PIC Assembler equivalents and explains differences in directives, memory placement, linking, and project structure. Use this when reading inherited RCET source or older Microchip examples written for MPASM.

## MPLAB XC8 C Compiler User's Guide for PIC MCU - DS50002737

**Type:** Toolchain reference  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/ReferenceManuals/MPLAB-XC8-C-Compiler-Users-Guide-for-PIC-DS50002737.pdf

The main XC8 C reference for 8-bit PIC targets. Use it for device headers, data types, memory model, interrupt syntax, compiler behavior, optimization, libraries, pragmas, and generated-code questions when RCET work moves from assembly into embedded C.

## MPLAB XC8 documentation/download hub

**Type:** Toolchain discovery hub  
**URL:** https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers/xc8

Microchip's current XC8 page. It links the current C compiler guide, PIC Assembler guide, embedded-engineer guides, migration guides, release notes, and downloads.

---

# 4. MPLAB X, PICkit 3, ICSP, and debugging

## MPLAB X IDE product/documentation page

**Type:** Toolchain discovery hub  
**URL:** https://www.microchip.com/en-us/development-tool/MPLAB-X-IDE

Current MPLAB X downloads, release notes, user documentation, simulator/device support documents, and archive links. Tool behavior changes over time, so use the current page and installed release notes for version-specific questions.

## MPLAB X IDE User's Guide - DS50002027

**Type:** Toolchain reference  
**URL:** https://ww1.microchip.com/downloads/en/DeviceDoc/50002027D.pdf

General guide to projects, build settings, debugging, programming, memory views, breakpoints, and IDE workflows. Some screenshots and menus are older than current MPLAB X releases, so pair it with current IDE help/release notes.

## PICkit 3 In-Circuit Debugger/Programmer User's Guide for MPLAB X IDE - DS52116A

**Type:** Toolchain/hardware reference  
**URL:** https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/UserGuides/52116A.pdf

Covers PICkit 3 connections, target-board requirements, programming, debugging, troubleshooting, power considerations, and hardware specifications. Particularly useful when the tool connects intermittently, programming fails, or a target circuit may be interfering with ICSP.

## PICkit 3 product/documentation page

**Type:** Toolchain discovery hub  
**URL:** https://www.microchip.com/en-us/development-tool/pg164130

Current Microchip landing page for the legacy PICkit 3. It links the user guide and older software/archive material. Microchip no longer recommends PICkit 3 for new designs, but it remains the RCET course programmer/debugger.

## In-Circuit Serial Programming (ICSP) Guide - DS30277D

**Type:** Supplemental hardware reference  
**URL:** https://ww1.microchip.com/downloads/en/DeviceDoc/30277d.pdf

Explains ICSP design and wiring considerations. Useful for understanding why MCLR/VPP, ICSPCLK, ICSPDAT, VDD, and VSS must be wired carefully and why application circuitry on programming pins can interfere with programming.

## Development Tools Design Advisory / Multi-Tool Design Advisory - DS51764

**Type:** Supplemental hardware reference  
**Current web version:** https://developerhelp.microchip.com/xwiki/bin/view/software-tools/programmers-and-debuggers/design-advisory/  
**PDF:** https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/UserGuides/51764C.pdf

Design guidance for connecting Microchip programmers/debuggers to target hardware. It covers ICSP signal loading, MCLR/VPP, PGC/PGD connections, isolation, target power, and common circuit problems. The current web version is preferred when it differs from the older PDF.

---

# 5. Interrupts and PORTB interrupt-on-change

## Interrupt-on-Change Operation for Mid-Range Microcontrollers - TB3061

**Type:** Supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/tb3061

Explains IOC timing in detail, including cases where an IOC event can be missed depending on the relationship between the input change and the instruction/clock cycle. Useful when a PORTB IOC design behaves correctly most of the time but occasionally appears to miss an event.

## Using the PORTB Interrupt on Change as an External Interrupt - AN566

**Type:** Legacy supplemental  
**URL:** https://ww1.microchip.com/downloads/en/appnotes/00566b.pdf

Shows how PORTB IOC can be used as additional external interrupt sources and how software can determine which pin changed. The examples target older PIC16C devices where IOC behavior/pin coverage differs from the PIC16F883. Use the algorithmic ideas, but use the PIC16F883 data sheet for actual `IOCB`, `RBIF`, pin coverage, and clearing behavior.

---

# 6. Program memory, tables, PCL, and PCLATH

## Implementing a Table Read - AN556

**Type:** Legacy supplemental  
**URL:** https://ww1.microchip.com/downloads/en/AppNotes/00556e.pdf

Explains `CALL`, `GOTO`, `PCL`, `PCLATH`, computed `GOTO` using `ADDWF PCL`, `RETLW` lookup tables, page selection, and the 256-word low-PCL boundary problem. This is the main supplemental source for understanding why computed lookup tables require more care than a simple sequential branch.

Use this alongside the PIC16F883 data sheet's Program Counter/PCL/PCLATH discussion and the RCET computed-GOTO reference.

---

# 7. Oscillators and instruction timing

## Basic PICmicro Oscillator Design - AN849

**Type:** Supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/an849

Explains crystal/resonator oscillator operation, component selection, startup margin, temperature/supply effects, crystal drive, and practical oscillator design. Useful when selecting the external 4 MHz crystal capacitors or diagnosing startup/frequency problems.

For final component values and operating limits, use the crystal manufacturer's data sheet together with the PIC16F883 oscillator/electrical sections.

---

# 8. Analog-to-digital conversion

## Mastering the PIC16C7X A/D Converter - FACT002

**Type:** Legacy supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/fact002

A practical discussion of 10-bit PIC ADC design issues such as source impedance, acquisition time, reference quality, noise, and obtaining useful conversion accuracy. It targets an older PIC family, so use it for concepts and use the PIC16F883 data sheet for actual ADC registers and timing requirements.

## ADC Acquisition Time - Microchip Developer Help

**Type:** Supplemental  
**URL:** https://developerhelp.microchip.com/xwiki/bin/view/products/data-converters/adc-specs/acquisition-time/

A current explanation of sample/hold acquisition time and why source impedance affects ADC accuracy. Useful background before working through the PIC16F883 data sheet's device-specific acquisition-time equation.

---

# 9. EUSART / asynchronous serial communication

## Asynchronous Communications with the PICmicro USART - AN774

**Type:** Supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/an774

Explains asynchronous USART operation, baud rate, transmit/receive behavior, errors, and common serial communication design issues. The examples are older, but the concepts map well to the PIC16F883 EUSART. Verify all registers and bit names in the PIC16F883 data sheet.

---

# 10. MSSP, I2C, and external serial EEPROM

## Using the PICmicro MSSP Module for I2C Communications - AN735

**Type:** Supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/an735

Explains hardware MSSP operation in I2C master mode and the transaction sequence required to communicate with I2C devices. Useful conceptual background for the RCET I2C lab.

## Using the Mid-Range PIC16 MSSP Module for Slave I2C Communication - AN734

**Type:** Supplemental / device-family caution  
**URL:** https://www.microchip.com/en-us/application-notes/an734

Explains I2C slave operation using PIC MSSP hardware. It is useful for understanding start/address/data/ACK behavior and slave state handling, but its target devices are not the PIC16F883. Verify all implementation details against the PIC16F883 MSSP chapter.

## Using the MSSP Module to Interface I2C Serial EEPROMs with PIC16 Devices - AN976

**Type:** Supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/an976

A focused example of using a PIC16 MSSP peripheral to communicate with 24XX-series I2C EEPROM. Useful when the lab combines MSSP/I2C transactions with an external EEPROM device.

---

# 11. EEPROM endurance and nonvolatile memory

## EEPROM Endurance Tutorial - AN1019

**Type:** Supplemental / general EEPROM  
**URL:** https://www.microchip.com/en-us/application-notes/an1019

Explains EEPROM write endurance, cycling, retention, and factors affecting lifetime. It is primarily a general EEPROM/serial-memory reference rather than a PIC16F883 internal-EEPROM programming guide. Use the PIC16F883 data sheet for the internal Data EEPROM write sequence and this document for broader endurance concepts.

---

# 12. PID and control-system examples

## Software PID Control of an Inverted Pendulum Using the PIC16F684 - AN964

**Type:** Supplemental / related PIC16 device  
**URL:** https://www.microchip.com/en-us/application-notes/an964

A complete PIC16 example of implementing a positional PID controller on an unstable physical system. Useful for connecting proportional, integral, and derivative terms to actual sampled embedded control code.

## Digital Signal Processing with the PIC16C74 - AN616

**Type:** Legacy supplemental  
**URL:** https://www.microchip.com/en-us/application-notes/an616

Contains several small DSP/control examples, including a simple PID compensator. It is useful for algorithm ideas and fixed-resource implementation thinking, but its device and peripherals differ from the PIC16F883.

---

# 13. CCP/PWM and practical peripheral ideas

## PIC MCU CCP and ECCP Tips 'n Tricks - DS41214B

**Type:** Supplemental  
**URL:** https://ww1.microchip.com/downloads/en/devicedoc/41214b.pdf

A practical collection of Capture/Compare/PWM techniques. Useful for PWM generation, measurement, timing, and later project work. Verify which CCP/ECCP features actually exist on the PIC16F883 before using an example.

The broader [Compiled Tips 'N Tricks Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/SupportingCollateral/01146B.pdf) also contains hardware/software ideas relevant to RCET projects.

---

# 14. Finding additional official Microchip material

## Microchip application-note library

**URL:** https://www.microchip.com/en-us/application-notes

Searchable catalog of Microchip application notes and technical briefs. Search by peripheral or concept such as `PIC16 I2C`, `USART`, `ADC acquisition`, `interrupt`, `PID`, `EEPROM`, or `oscillator`.

## Microchip Developer Help

**URL:** https://developerhelp.microchip.com/

Current web-based explanations for Microchip devices and development tools. These pages can be easier to navigate than older PDF manuals and are often useful for concepts, but device-specific data-sheet values still control.

---

# Maintenance rule for this guide

This is a living RCET reference.

When a useful official Microchip document is discovered while developing a lab, teaching a topic, troubleshooting hardware, or reviewing inherited material:

1. add it to the most appropriate category here;
2. use the official Microchip URL when one is available;
3. include the document number when known;
4. summarize what problem the document helps solve;
5. identify whether it is device-specific, family-level, toolchain, supplemental, or legacy supplemental;
6. state any important applicability warning when the example targets a different device or older PIC generation;
7. keep old documents when they remain educationally useful, but mark them clearly rather than allowing them to appear equally authoritative with current PIC16F883 documentation.

If a course-specific reference page grows from one of these documents, link the RCET reference back to this guide rather than creating another independent Microchip-document list.

# PIC16F883 Interrupt Reference

Use this as a reasoning checklist, not a register recipe.

## Interrupt path

For every interrupt source, identify:

1. What event sets the flag?
2. Which flag records the event?
3. Which source-enable bit permits that event to request service?
4. Is `PEIE` required for this source?
5. Is `GIE` enabled?
6. Where does the CPU enter the interrupt vector?
7. How will the handler identify the active source?
8. Which flag must software clear, and when?
9. Which CPU context must be saved and restored?
10. How will the code leave the ISR with `RETFIE`?
11. What latency is added between the event and ISR execution?
12. How will the behavior be verified in the simulator or on hardware?

For the PIC16F883, the hardware interrupt vector is `0004h`. The RCET starter template uses an `isrVect` PSECT placed there by the linker.

## Context save/restore

The shared [`../Template_Main.S`](../Template_Main.S) preserves WREG, STATUS, and PCLATH in common RAM and restores them before `RETFIE`.

The STATUS-save sequence is deliberate. `MOVF` affects the Z flag, while `MOVWF` and `SWAPF` do not. Do not replace the swap-based STATUS handling with a superficially simpler sequence unless you have checked which flags that sequence changes.

## Worked external RB0/INT path

The PIC16F883 pin is multiplexed as `RB0/AN12/INT`. To use it as the external interrupt input:

1. Configure **AN12 as digital** by clearing the corresponding `ANSELH` selection bit (`ANS12`).
2. Configure `RB0` as an input with `TRISB0 = 1`.
3. Choose the active edge with `OPTION_REG.INTEDG`:
   - set for rising edge;
   - clear for falling edge.
4. Clear a stale `INTCON.INTF` before enabling the interrupt.
5. Set `INTCON.INTE` to enable the external INT source.
6. Set `INTCON.GIE` last, after source setup is complete.
7. On the selected edge, hardware sets `INTF`; with `INTE` and `GIE` enabled, execution transfers to the interrupt vector.
8. The ISR identifies the source, performs minimal service work, clears `INTF`, restores context, and exits with `RETFIE`.

`PEIE` is not part of the RB0/INT enable path. It applies to peripheral interrupt sources that use the peripheral-interrupt enable structure.

## Skeleton

```assembly
SetupExternalInt:
    BANKSEL ANSELH
    bcf     ANS12           ; RB0/AN12 becomes digital

    BANKSEL TRISB
    bsf     TRISB,0         ; RB0 input

    BANKSEL OPTION_REG
    bsf     INTEDG          ; example: rising-edge interrupt

    BANKSEL INTCON
    bcf     INTF            ; discard stale request
    bsf     INTE            ; enable external INT source
    bsf     GIE             ; global enable last
    return
```

Use the Microchip-provided bit helper symbols available through `<xc.inc>` when they expand to the intended register/bit form in the current toolchain. If a helper is uncertain, verify the generated/listing output rather than guessing.

## Timing

Treat interrupt latency as part of any edge-to-edge timing model. The PIC16F883 documentation describes asynchronous INT/PORTB interrupt latency in the range of roughly 3 to 4 instruction cycles depending on when the event arrives relative to the clock. Do not model the ISR as beginning at the exact instant of the external edge.

For timing-sensitive work, include:

```text
event -> interrupt latency -> vector transfer -> context save -> source test/service -> flag clear -> context restore -> RETFIE -> resumed code
```

## Verification

### Simulator

- place a breakpoint at the interrupt vector and handler;
- establish the expected flag/enable state;
- stimulate or set the interrupt condition;
- verify entry at `0004h`;
- step through context save and restore;
- confirm the source flag is cleared before `RETFIE`.

### Hardware

Use a clean, observable input edge and a separate output marker if practical. Predict the expected response timing before measuring it. If the measured response differs, separate interrupt latency, ISR work, main-loop work, and instrument resolution before changing code.

## Primary device checks

Use the PIC16F882/883/884/886/887 data sheet for the final word on:

- `RB0/AN12/INT` pin multiplexing;
- `ANSELH` / `ANS12`;
- `TRISB0`;
- `OPTION_REG.INTEDG`;
- `INTCON` bits `GIE`, `INTE`, and `INTF`;
- vector and latency behavior.
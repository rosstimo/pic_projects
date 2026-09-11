# PIC16F883 Subroutines and Return Stack

## Core model

`CALL` changes program flow to a subroutine and saves the return address in the PIC16F883 hardware return stack. `RETURN` restores that saved address to the Program Counter so execution resumes after the original `CALL`.

The PIC16F883 hardware return stack has **eight levels**. Count **nested** calls, not the total number of subroutine calls over time.

```text
Main
  CALL A        depth 1
    A: CALL B   depth 2
       B: ...
       RETURN   depth 1
    RETURN      depth 0
```

Calling the same one-level subroutine thousands of times sequentially does not accumulate thousands of stack entries because each call returns before the next one begins.

## Timing rule

When a subroutine is part of a timing calculation, include the caller and control-transfer path, not only the instructions inside the named delay routine.

For a waveform produced by code such as:

```assembly
    ; toggle output
    call    Delay
    goto    MainLoop
```

an edge-to-edge calculation must include the instructions between the two observed edges, including `CALL`, the delay routine, `RETURN`, branch/control instructions, and any input/lookup work that occurs on that path.

## Documentation block

For non-trivial RCET subroutines, record:

```text
Input:
Output:
Uses / clobbers:
Maximum added stack depth:
Timing boundary when timing matters:
```

## Return instructions

- `RETURN` returns from an ordinary subroutine.
- `RETLW k` returns from a subroutine while loading literal `k` into WREG. This is useful for lookup tables.
- `RETFIE` returns from an interrupt service routine and restores interrupt enable behavior. Do not use it as an ordinary `RETURN`.

## Checklist

Before using a subroutine in a lab calculation:

- [ ] identify every possible caller;
- [ ] identify nested calls made by the routine;
- [ ] confirm maximum nested depth stays within the eight-level hardware stack;
- [ ] document registers/variables changed by the routine;
- [ ] include `CALL`/return-path overhead in complete-path timing;
- [ ] trace a short example in MPLAB X Simulator before relying on the routine in hardware.
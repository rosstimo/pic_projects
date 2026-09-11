# MPLAB X Simulator Checklist

Use the simulator to prove execution before blaming hardware.

1. Build the PIC16F883 project successfully.
2. Select **Simulator** as the debug tool.
3. Start a debug session and halt at reset/setup.
4. Open Program Memory and confirm the reset and interrupt-vector locations expected by the project.
5. Open the relevant SFR/register view and add any GPR variables used by the code.
6. Step one instruction at a time through the section being studied.
7. Before each step, predict the next Program Counter location, WREG value, relevant STATUS bits, and changed file register.
8. Use breakpoints to skip repetitive loop iterations only after the first few iterations have been traced manually.
9. For delay loops, verify the normal iteration and final `DECFSZ` skip path separately.
10. For subroutines, watch the control transfer into `CALL` and back through `RETURN`; count nested calls conceptually against the eight-level hardware return stack.
11. For computed-GOTO tables, watch PCL/PCLATH and the actual target reached after `ADDWF PCL`.
12. For interrupts, set or stimulate the source condition, verify the flag/enable path, confirm entry at `0004h`, then trace context save, source handling, flag clearing, context restore, and `RETFIE`.
13. Record the observed execution path when it differs from the prediction. The mismatch is the debugging evidence.

The simulator proves the instruction path and register effects. It does not prove analog behavior, oscillator loading, programmer wiring, or physical timing on the bench.
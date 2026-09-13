# PIC16F883 Computed GOTO and `RETLW` Tables

A common classic mid-range PIC lookup-table pattern uses the table index in WREG, adds it to PCL, and returns the selected literal with `RETLW`.

```assembly
Lookup:
    addwf   PCL,f
    retlw   0x10
    retlw   0x20
    retlw   0x30
    retlw   0x40
```

The important mental model is:

```text
index in WREG
-> ADDWF PCL changes the low Program Counter byte
-> execution lands on one RETLW entry
-> RETLW loads WREG and returns through the hardware return stack
```

## The 256-word boundary hazard

A table does **not** become safe merely because it has fewer than 256 entries.

Writing PCL uses PCLATH to supply the upper Program Counter bits. If the table begins near the end of a low-PCL block, adding the index can cross the `0xFF -> 0x00` low-byte boundary without automatically carrying into the next upper block the way a normal full-width integer addition would.

For beginner RCET work, use this rule:

> Keep the entire `ADDWF PCL` + `RETLW` table within one 256-word low-PCL block unless the assignment explicitly teaches the required PCLATH handling.

That means placement matters. A 20-entry table beginning at low address `0xF8` crosses the boundary even though 20 is far less than 256.

## What to verify

Before trusting a computed-GOTO table:

1. build the project;
2. inspect Program Memory or the map/listing;
3. record the actual address of `ADDWF PCL` and the final `RETLW` entry;
4. confirm their low-byte address range does not cross `xxFF -> (xx+1)00` unless the code explicitly handles PCLATH;
5. simulate the first, middle, and last valid indices;
6. test at least one out-of-range index path if the calling code can produce one.

## Simulator demonstration

A useful deliberate-failure exercise is:

1. place a short table so its entries straddle a 256-word low-byte boundary;
2. run an index that should reach an entry beyond the boundary;
3. observe the unintended target after `ADDWF PCL`;
4. move the table wholly inside one low-byte block or implement the correct PCLATH handling;
5. rebuild and verify the corrected target in Program Memory and Simulator.

Do not describe the bad jump as harmless padding or as guaranteed to wrap through NOPs. The CPU executes whatever instruction actually exists at the unintended address.

## Timing use

For tone/delay lookup work, include the lookup path in complete timing calculations:

```text
input/branch path
-> CALL lookup
-> ADDWF PCL
-> selected RETLW
-> store/use returned count
-> CALL delay
-> delay body
-> RETURN
-> remaining main-loop/output path
```

When several input paths are possible, compare their total path times. The difference can appear as output jitter even if the named delay routine itself is perfectly repeatable.
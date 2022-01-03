    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

reset:  
    CLEAN_START
    ldx #$FF    ;load stack pointer into X at $FF
    txs         ;transfer contents of X into the stack pointer

    ;push 4 values to the stack
    lda #$AA
    
    pha         ;push acc value to stack
    pha         ;push acc value to stack
    pha         ;push acc value to stack
    pha         ;push acc value to stack

    ;pop values from stack

    pla         ;pop value from stack to acc
    pla         ;pop value from stack to acc
    pla         ;pop value from stack to acc
    pla         ;pop value from stack to acc

    ;end of rom
    org $FFFC
    .word reset
    .word reset
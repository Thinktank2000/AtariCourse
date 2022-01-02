    processor 6502 ;Define processor as 6502

    seg code       ;sets a code segment
    org $F000      ;defines code origin at $F000

Start:
    lda #$82       ;loads the literal hexadecimal number $82 into the a register
    ldx #82        ;loads the decimal number 82 into the x register
    ldy $82        ;loads the memory address $82 into the y register

    org $FFFC      ;end the rom by setting specific values at memory address $FFFC
    .word Start    ;put 2 bytes for the reset vector at $FFFC (Where the program starts)
    .word Start    ;put 2 bytes with the break address $FFFE

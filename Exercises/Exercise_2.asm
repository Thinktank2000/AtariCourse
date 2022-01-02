    processor 6502

    seg code
    org $F000

Start:
    lda $a          ;loads memory address $A into the a register
    ldx %11111111   ;loads binary %11111111 into the x register
    sta $80         ;stores the contents of the a register at memory address $80
    stx $81         ;stores the contents of the x register at memory address $81

    org $FFFC
    .word Start
    .word Start
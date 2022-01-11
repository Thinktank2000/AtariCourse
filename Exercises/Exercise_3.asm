    processor 6502

    seg code
    org $F000

Start:
    lda #15 ;load 15 into the a register
    tax     ;transfer A to X
    tay     ;transfer A to Y
    txa     ;transfer X to A
    tya     ;transfer Y to A

    ldx #6  ;load 6 into the X register
    txa     ;transfer X to A

    org $FFFC
    .word Start
    .word Start

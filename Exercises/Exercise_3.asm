    processor 6502

    seg code
    org $F000

Start:
    lda #15
    tax 
    tay 
    txa 
    tya

    ldx #6
    txa 

    org $FFFC
    .word Start
    .word Start

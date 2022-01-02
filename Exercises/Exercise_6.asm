    processor 6502

    seg code
    org $F000

Start:
    lda #1
    ldx #2
    ldy #3

    inx 
    iny 

    dex 
    dey 

    org $FFFC
    .word Start
    .word Start
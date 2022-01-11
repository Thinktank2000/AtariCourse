    processor 6502

    seg code
    org $F000

Start:
    lda #1   ;load A with 1
    ldx #2   ;load X with 2
    ldy #3   ;load Y with 3

    inx      ;increment X by 1
    iny      ;increment Y by 2

    dex      ;decrement X by 1
    dey      ;decrement Y by 1

    org $FFFC
    .word Start
    .word Start
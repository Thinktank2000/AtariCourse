    processor 6502

    seg code
    org $F000

Start:
    lda #10     ;load 10 into A
    sta $80     ;store A at $80

    inc $80     ;increment the contents of $80 by one
    dec $80     ;decrement the contents of $80 by one

    org $FFFC
    .word Start
    .word Start
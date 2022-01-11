    processor 6502

    seg code
    org $F000

Start:
    lda #100 ;load 100 into A register

    adc #5   ;add 5 to A
    sbc #10  ;subtract 10 from A

    org $FFFC
    .word Start
    .word Start
    processor 6502

    seg code
    org $F000

Start:
    lda $a     ;load $A into the A register
    ldx %1010  ;load 1010 into the X register

    sta $80    ;store the contents of A at $80
    stx $81    ;store the contents of X at $81

    lda #10    ;load 10 into A
    adc $80    ;add the contents of address $80 to A
    adc $81    ;add the contents of address $81 into A

    sta $82    ;store the contents of A in $82

    org $FFFC
    .word Start
    .word Start

;Housekeeping code
    processor 6502 ;defines the processor as 6502

    seg code
    org $F000 ;Define code origin at $F000

Start:
    sei         ;disable interrupts
    cld         ;disable BCD decimal map mode
    ldx #$FF    ;loads X register with #$FF
    txs         ;transfer the X register to the stack pointer (SP) register
;Clear the page zero reigon of memory ($00 to $FF)
;Entire RAM space and TIA register
    lda #0       ;A = 0
    ldx #$FF     ;X = #$FF
    sta $FF      ;zeroes $FF before the loop starts
MemLoop:
    dex          ;X--
    sta $0,X     ;store the value of a in address $0 + the value within X
    bne MemLoop  ;Loop until X = 0
    
;fill the rom space to exactly 4kb
    org $FFFC    ;End of ROM space
    .word Start  ;Reset vector at $FFFC (where the program starts)
    .word Start  ;Interrupt vector at $FFFE (unused despite required :( )

 Processor 6502

    include "macro.h"
    include "vcs.h"

    seg code
    org $F000

Reset:
    CLEAN_START

    ldx #$50        ;purple background colour
    stx COLUBK

    lda #$70
    sta COLUPF      ;blue playfield colour

;start a new frame by configuring VSYNC and VBLANK
StartFrame:
    lda #2
    sta VSYNC
    sta VBLANK

;generate 3 lines of VSYNC
    REPEAT 3
        sta WSYNC  ;repeats 3 VSYNC scanlines
    REPEND

    lda #0
    sta VSYNC      ;turn off VSYNC

;generate 37 scanlines of VBLANK
    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK     ;turn off VBLANK

;set the CTRLPF register to allow playfield reflection
    ldx #%00000001 ;CTRLPF register (D0 means reflect)
    stx CTRLPF

;draw the 192 visible scanlines
    ldx #0
    stx PF0        ;disable the PF0, 1 and 2 registers
    stx PF1
    stx PF2
    REPEAT 7       ;disable the PF registers for 7 scanlines
        sta WSYNC
    REPEND

;set the PF0 to 1110 (LSB first) and PF1 and 2 to 1111 1111
    ldx #%11100000
    stx PF0

    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
    sta WSYNC
    REPEND

;set the next 164 lines with only the PF0 third bit enabled
    ldx #%01100000
    stx PF0
    
    ldx #%10000000
    stx PF2
    
    ldx #0
    stx PF1

    REPEAT 164
        stx WSYNC
    REPEND

;set the PF0 to 1110 (LSB first) and PF1 and 2 to 1111 1111
    ldx #%11100000
    stx PF0

    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
    sta WSYNC
    REPEND

;skip 7 lines with no PF set
    ldx #0
    stx PF0        ;disable the PF0, 1 and 2 registers
    stx PF1
    stx PF2
    REPEAT 7       ;disable the PF registers for 7 scanlines
        sta WSYNC
    REPEND

;generate 30 lines of VBLANK overscan
    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

;jump back to the beginning for next frame
    jmp StartFrame

;ROM Padding and end
    org $FFFC
    .word Reset
    .word Reset
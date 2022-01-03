    processor 6502

    ;include required files
    include "vcs.h"
    include "macro.h"

    ;segment for uninitialized variables starting at $80
    seg.u variables
    org $80

P0XPos   byte       ;player 0 X position
P0YPos   byte       ;player 0 Y position
P1XPos   byte       ;player 1 X position
P1YPos   byte       ;player 1 Y position

    ;start of ROM at $F000
    seg code
    org $F000

reset:
    CLEAN_START     ;call macro to reset memory and registers

    ;initialize variables
    lda #10
    sta P0XPos      ;P0XPos = 10
    lda #60
    sta P0YPos      ;P0YPos = 60

    ;start main display loop
StartFrame:

    ;display VSYNC and VBLANK
    lda #2
    sta VSYNC
    sta VBLANK

    ;generate 3 lines of VSYNC
    REPEAT 3
        sta WSYNC
    REPEND 

    ;turn off VSYNC
    lda #0
    sta VSYNC

    ;generate 37 lines of VBLANK
    REPEAT 37
        sta WSYNC
    REPEND

    ;turn off VBLANK
    lda #0
    sta VBLANK


    ;display 192 visible scanlines
VisibleLine:
    lda #$84
    sta COLUBK    ;set background to pale blue

    lda #$C2
    sta COLUPF    ;set playfield to green

    lda %00000001
    sta CTRLPF    ;enable playfield reflection

    lda #$F0
    sta PF0
                  ; setting PF0 bit pattern
    lda #$FC
    sta PF1
                  ; setting PF1 bit pattern
    lda #0
    sta PF2       ; setting PF2 bit pattern

    ldx #192      ;X counts the remaining number of scanlines
LineLoop:
    sta WSYNC
    dex           ;X--
    bne LineLoop  ;repeat next visible scanline until finished

    ;display 30 lines of overscan
    lda #2
    sta VBLANK    ;turn on VBLANK

    REPEAT 30
        sta WSYNC ;display 30 lines of overscan
    REPEND

    lda #0
    sta VBLANK    ;turn off VBLANK

    ;loop new frame
    jmp StartFrame

    ;end of ROM
    org $FFFC
    .word reset
    .word reset
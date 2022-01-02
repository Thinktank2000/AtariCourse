    processor 6502

    include "vcs.h"
    include "macro.h"

    ;uninitialized segment for variables
    seg.u variables
    org $80
P0XPos byte         ;Player 0 X coordinate variable

    seg code
    org $F000

reset:
    CLEAN_START

    ldx #$00        ;black background colour
    stx COLUBK

;initialize variables
    lda #50
    sta P0XPos


StartFrame:
    ;configure VSYNC and VBLANK
    lda #2
    sta VSYNC
    sta VBLANK

    ;generate 3 lines of VSYNC
    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC      ;turn VSYNC off

    ;set player 0 horizontal position during VBLANK
    lda P0XPos     ;load a with desired X position
    and #$7F       ;forces bit 8 to 0 making a an unsigned integer (always positive)

    sta WSYNC      ;wait for fresh scanline
    sta HMCLR      ;clears old Horizontal position values

    sec            ;set carry flag before subtraction
DivideLoop:
    sbc #15        ;subtract 15 from A
    bcs DivideLoop ;loop while carry flag is still set

    eor #7         ;adjust the remainder to between -8 and 7
    asl            ;shift left by 4 bits (HMP0 only uses the top 4 bits)
    asl
    asl
    asl
    sta HMP0       ;set fine position
    sta RESP0      ;reset x15 rough position
    sta WSYNC      ;wait for new scanline
    sta HMOVE      ;apply new fine position offset

    ;generate 37(-2) VBLANK lines (2 scanlines were wasted due to the 2 WSYNC instructions used)
    REPEAT 35
        sta VBLANK
    REPEND

    lda #0
    sta VBLANK

    ;draw 192 visible scanlines
    REPEAT 60
        sta WSYNC   ;wait for 60 empty scanlines
    REPEND

    ldy #8           ;counter to draw 8 bitmap rows
DrawBitmap
    lda P0Bitmap,Y  ;load slice of bitmap
    sta GRP0        ;set graphics for player 0

    lda P0Colour,Y 
    sta COLUP0      ;set colour for player 0

    sta WSYNC       ;wait for next scanline

    dey 
    bne DrawBitmap  ;repeat next scanline until finished

    lda #0
    sta GRP0        ;disable player 0 graphics

    REPEAT 124
        sta WSYNC   ;wait for the remaining 124 scanlines
    REPEND

    ;draw 30 lines of overscan
    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    ;increment X coordinate for sweeping animation
    inc P0XPos

    ;loop next frame
    jmp StartFrame

    ;player graphics bitmap

P0Bitmap:
    .byte #%00000000
    .byte #%00010000
    .byte #%00001000
    .byte #%00011100
    .byte #%00110110
    .byte #%00101110
    .byte #%00111110
    .byte #%00011100

P0Colour:
    .byte #$00
    .byte #$02
    .byte #$02
    .byte #$52
    .byte #$52
    .byte #$52
    .byte #$52
    .byte #$52

    ;end of rom
    org $FFFC
    .word reset
    .word reset

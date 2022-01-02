    processor 6502

    include "vcs.h"
    include "macro.h"

    ;uninitialized segment for variables
    seg.u variables
    org $80
P0XPos byte             ;Player 0 X position

    seg code
    org $F000

reset:
    CLEAN_START

    lda #$80
    sta COLUBK          ;blue background

    lda #$C3
    sta COLUPF          ;green playfield

    ;initialize variables
    lda #10
    sta P0XPos

StartFrame:
    ;start VSYNC and VBLANK
    lda #2
    sta VSYNC
    sta VBLANK

    ;generate 3 lines of VSYNC
    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC           ;turn off VSYNC

    ;set horizontal position while in VBLANK
    lda P0XPos          ;load a with desired X position
    and #$7F            ;force bit 8 off to make an unsigned integer

    sta WSYNC           ;wait for a new scanline
    sta HMCLR           ;clear any previous horizontal positioning

    sec                 ;set carry flag
DivLoop:
    sbc #15             ;subtract 15 from a
    bcs DivLoop         ;loop while carry flag is still set

    eor #7              ;adjust remainder to a range of -8 to 7
    asl                 ;shift the result left by 4 bits (HMP0 only uses the top 4 bits)
    asl
    asl
    asl
    sta HMP0            ;set fine position
    sta RESP0           ;set rough position
    sta WSYNC           ;wait for a new scanline
    sta HMOVE           ;apply new fine offset

    ;draw 35 (subtract previous used scanlines during horizontal position) VBLANK lines
    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK          ;turn VBLANK off

    ;Draw 192 visible scanlines
    REPEAT 160          ;wait 160 lines
        sta WSYNC
    REPEND

    ldy #17             ;counter to draw 17 lines of bitmap
DrawBitmap:
    lda P0Bitmap,Y      ;load slice of bitmap
    sta GRP0            ;set graphics for player 0

    lda P0Colour,Y      ;set colour for player 0
    sta COLUP0

    sta WSYNC           ;wait for next scanline

    dey
    bne DrawBitmap      ;repeat next scanline until finished

    lda #0
    sta GRP0            ;disable player 0 graphics

    lda #$FF            ;enable playfield
    sta PF0
    sta PF1
    sta PF2

    REPEAT 15           ;wait remaining 15 scanlines
        sta WSYNC
    REPEND

    lda #0              ;disable playfield
    sta PF0
    sta PF1
    sta PF2

    ;draw 30 lines of overscan
    lda #2
    sta VBLANK

    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    ;joystick test for P0 Left/Right/Up/Down
CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    inc P0XPos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec P0XPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec P0XPos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc P0XPos

NoInput:
    ;Fallback if no input is detected



    ;loop to next frame
    jmp StartFrame


P0Bitmap:
    .byte #%00000000
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00011100
    .byte #%01011101
    .byte #%01011101
    .byte #%01011101
    .byte #%01011101
    .byte #%01111111
    .byte #%00111110
    .byte #%00010000
    .byte #%00011100
    .byte #%00011100
    .byte #%00011100

P0Colour:
    .byte #$00
    .byte #$F6
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$3E
    .byte #$3E
    .byte #$3E
    .byte #$24


    ;end of ROM
    org $FFFC
    .word reset 
    .word reset
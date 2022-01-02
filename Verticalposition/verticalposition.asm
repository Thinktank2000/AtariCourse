    processor 6502

    include "macro.h"
    include "vcs.h"

;start an uninitialized segment for variable declaration ($80 to $FF can be used, minus a few at the end for the stack)
    seg.u Variables
    org $80
P0Height   byte    ;Player sprite height
PlayerYPos byte    ;Y position of player

;start ROM code segment
    seg code
    org $F000

reset:
    CLEAN_START

    ldx #$00        ;black background
    stx COLUBK

    ;initialize variables
    lda #180
    sta PlayerYPos  ;PlayerYPos = 180

    lda #9
    sta P0Height    ;P0Height = 9

    ;start a new frame by configuring VSYNC and VBLANK
StartFrame:
    lda #2
    sta VSYNC
    sta VBLANK

    ;generate 3 lines of VSYNC
    REPEAT 3        
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    ;generate 37 lines of VBLANK
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    ;Draw 192 visible scanlines
    ldx #192

Scanline:
    txa               ;transfer X to A
    sec               ;make sure the carry flag is set
    sbc PlayerYPos    ;subtract sprite Y coordinate
    cmp P0Height      ;are we in the sprites bounding box?
    bcc LoadBitmap    ;if result < P0Height, call subroutine
    lda #0            ;else, load 0

LoadBitmap:
    tay               ;transfer A to Y
    lda P0Bitmap,Y    ;loads player 0 bitmap slice of data
    sta WSYNC         ;wait for next scanline
    sta GRP0          ;set graphics for player 0 slice
    lda P0Colour,Y    ;loads player 0 colour from table
    sta COLUP0        ;set colour for player 0 slice
    dex               ; X--
    bne Scanline      ;repeat next scanline until finished

    ;draw 30 lines of overscan
Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND


    dec PlayerYPos

    ;loop
    jmp StartFrame

    ;player graphics bitmap
P0Bitmap:
    .byte #%00000000
    .byte #%00101000
    .byte #%01110100
    .byte #%11111010
    .byte #%11111010
    .byte #%11111010
    .byte #%11111110
    .byte #%01101100
    .byte #%00110000

    ;player colours table
P0Colour:
    .byte #$00
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$42
    .byte #$42
    .byte #$44
    .byte #$D2

    ;end of ROM
    org $FFFC
    .word reset
    .word reset
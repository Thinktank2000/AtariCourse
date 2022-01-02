    processor 6502

    include "macro.h"
    include "vcs.h"

    ;start an uninitalized segment for variable declaration
    seg.u variables
    org $80
P0Height ds 1      ;defines 1 bytes for player 0 height
P1Height ds 1      ;defines 1 bytes for player 1 height


    seg code
    org $F000

    ;clean memory and set colours for playfield and background
reset:
    CLEAN_START

    lda #$24
    sta COLUBK

    ldx #$70
    stx COLUPF

    lda #10
    sta P0Height   ;P0 Height = 10
    sta P1Height   ;P1 Height = 10

    ;set player colours

    lda #$48
    sta COLUP0

    lda #$C6
    sta COLUP1

    ldy #%00000010 ;CTRLPF D1 set to 1 means Score
    sty CTRLPF

StartFrame:
    ;turn on VBLANK and VSYNC
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

StartVisible:
    ;draw 10 empty scanlines at top of picture
    REPEAT 10
        sta WSYNC
    REPEND

    ;defines 10 scanlines for the scoreboard with the sprite being stored as an array of bytes at the end of the ROM
    ldy #0
ScoreboardLoop:
    lda NumberBitmap,Y
    sta PF1
    sta WSYNC
    iny 
    cpy #10
    bne ScoreboardLoop

    ;disable playfield
    lda #0
    sta PF1

    ;draw 50 empty scanlines between bottom of scoreboard and player 0
    REPEAT 50
        sta WSYNC
    REPEND

    ;draws 10 scanlines for the player 0 with the sprite being stored as an array of bytes at the end of the ROM
    ldy #0
Player0Loop:
    lda PlayerBitmap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy P0Height
    bne Player0Loop

    lda #0
    sta GRP0

    ;draws 10 scanlines for the player 1 with the sprite being stored as an array of bytes at the end of the ROM
    ldy #0
Player1Loop:
    lda PlayerBitmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy P1Height
    bne Player1Loop

    lda #0
    sta GRP1

    ;draw the remaining 102 scanlines as we already drew 90 (192 - 90 = 102)
    REPEAT 102
    sta WSYNC
    REPEND

    ;draw the 30 VBLANK overscan lines
    lda #2
    sta VBLANK
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    ;loop to next frame
    jmp StartFrame

    ;define an array of bytes to draw the scoreboard number
    org $FFE8
NumberBitmap:
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00000010   ;      ###
    .byte #%00000010   ;      ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00001000   ; ###
    .byte #%00001000   ; ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########

    ;define an array of bytes to draw the player sprite
    org $FFF2
PlayerBitmap:
    .byte #%01111110   ;  ######
    .byte #%11111111   ; ########
    .byte #%10011001   ; #  ##  #
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%10111101   ; # #### #
    .byte #%11000011   ; ##    ##
    .byte #%11111111   ; ########
    .byte #%01111110   ;  ######

    ;end of ROM
    org $FFFC
    .word reset
    .word reset
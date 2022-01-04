    processor 6502

    ;include required files
    include "vcs.h"
    include "macro.h"

    ;segment for uninitialized variables starting at $80
    seg.u variables
    org $80

JetXPos         byte       ;player 0 X position
JetYPos         byte       ;player 0 Y position
BomberXPos      byte       ;player 1 X position
BomberYPos      byte       ;player 1 Y position
JetSpritePtr    word       ;Player 0 sprite pointer
JetColourPtr    word       ;player 0 colour pointer
BomberSpritePtr word       ;Player 1 sprite pointer
BomberColourPtr word       ;player 1 colour pointer

    ;define constants
JET_HEIGHT = 9             ;Player 0 sprite height
BOMBER_HEIGHT = 9          ;PLayer 1 sprite height


    ;start of ROM at $F000
    seg code
    org $F000

reset:
    CLEAN_START     ;call macro to reset memory and registers

    ;initialize variables
    lda #10
    sta JetXPos      ;JetXPos = 10
    lda #5
    sta JetYPos      ;JetYPos = 60
    lda #83
    sta BomberYPos   ;BomberYPos = 83
    lda #54
    sta BomberXPos   ;BomberXPos = 54

    ;initialize pointers
    lda #<JetSprite
    sta JetSpritePtr        ;low byte pointer to jet sprite lookup table
    lda #>JetSprite
    sta JetSpritePtr+1      ;high byte pointer to jet sprite lookup table (plus one)

    lda #<JetColour
    sta JetColourPtr        ;low byte pointer to jet colour lookup table
    lda #>JetColour
    sta JetColourPtr+1      ;high byte pointer to jet colour lookup table (plus one)

    lda #<BomberSprite
    sta BomberSpritePtr       ;low byte pointer to jet sprite lookup table
    lda #>BomberSprite
    sta BomberSpritePtr+1      ;high byte pointer to jet sprite lookup table (plus one)

    lda #<BomberColour
    sta BomberColourPtr        ;low byte pointer to jet colour lookup table
    lda #>BomberColour
    sta BomberColourPtr+1      ;high byte pointer to jet colour lookup table (plus one)



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


    ;display 96 visible scanlines (2 line kernel)
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

    ldx #96      ;X counts the remaining number of scanlines
LineLoop:
InsideJetSprite:
    txa                     ;transfer x to acc
    sec                     ;set carry flag for subtraction
    sbc JetYPos             ;subtract sprite Y coord
    cmp JET_HEIGHT          ;compare with jet height
    bcc DrawSpriteP0        ;if result < SpriteHeight call draw routine
    lda #0                  ;else, load 0

DrawSpriteP0:
    tay                     ;Load Y so pointer can be worked with
    lda (JetSpritePtr),Y    ;Load P0 Bitmap data
    sta WSYNC               ;wait for next scanline
    sta GRP0                ;set graphics for P0
    lda (JetColourPtr),Y    ;load P0 Colour data
    sta COLUP0              ;set colour of P0

InsideBomberSprite:
    txa                     ;transfer x to acc
    sec                     ;set carry flag for subtraction
    sbc BomberYPos             ;subtract sprite Y coord
    cmp BOMBER_HEIGHT     ;compare with jet height
    bcc DrawSpriteP1        ;if result < SpriteHeight call draw routine
    lda #0                  ;else, load 0

DrawSpriteP1:
    tay                     ;Load Y so pointer can be worked with
    lda (BomberSpritePtr),Y    ;Load P0 Bitmap data
    sta WSYNC               ;wait for next scanline
    sta GRP1                ;set graphics for P0
    lda (BomberColourPtr),Y    ;load P0 Colour data
    sta COLUP1              ;set colour of P0



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

    ;ROM lookup tables
JetSprite:
    .byte #%00000000
    .byte #%01010100;$1E
    .byte #%01010100;$1E
    .byte #%01111100;$1E
    .byte #%00111000;$1E
    .byte #%00111000;$1E
    .byte #%00111000;$1E
    .byte #%00010000;$1E
    .byte #%00010000;$1E

BomberSprite:
    .byte #%00000000
    .byte #%00000000
    .byte #%00001000
    .byte #%00010100
    .byte #%00101010
    .byte #%00101010
    .byte #%01111111
    .byte #%01001001
    .byte #%01001001

JetColour:
    .byte #$00
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40

BomberColour:
    .byte #$00
    .byte #$1E
    .byte #$1E
    .byte #$1E
    .byte #$1E
    .byte #$1E
    .byte #$1E
    .byte #$1E
    .byte #$1E



    ;end of ROM
    org $FFFC
    .word reset
    .word reset
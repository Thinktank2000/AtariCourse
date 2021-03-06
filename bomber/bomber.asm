    processor 6502

    ;include required files
    include "vcs.h"
    include "macro.h"

    ;segment for uninitialized variables starting at $80
    seg.u variables
    org $80

JetXPos            byte       ;player 0 X position
JetYPos            byte       ;player 0 Y position
BomberXPos         byte       ;player 1 X position
BomberYPos         byte       ;player 1 Y position
MissileXPos        byte       ;missile X position
MissileYPos        byte       ;missile Y position
JetSpritePtr       word       ;Player 0 sprite pointer
JetColourPtr       word       ;player 0 colour pointer
BomberSpritePtr    word       ;Player 1 sprite pointer
BomberColourPtr    word       ;player 1 colour pointer
JetAnimOffset      byte       ;player 0 frame offset
Random             byte       ;set random number
ScoreSprite        byte       ;store the bit pattern for the score sprite
TimerSprite        byte       ;score the bit pattern for the timer sprite
Score              byte       ;2 digit score variable stored as BCD
Timer              byte       ;2 digit timer variable stored as BCD
Temp               byte       ;Temporary variable
OnesDigitOffset    word       ;offset for score ones digit
TensDigitOffset    word       ;offset for score tens digit
TerrainColour      byte       ;grass pattern colour
RiverColour        byte       ;river pattern colour

    ;define constants
JET_HEIGHT = 9             ;Player 0 sprite height
BOMBER_HEIGHT = 9          ;Player 1 sprite height
DIGIT_HEIGHT = 5           ;Scoreboard height


    ;start of ROM at $F000
    seg code
    org $F000

reset:
    CLEAN_START     ;call macro to reset memory and registers

    ;initialize variables-----------------------------------------------
    lda #65
    sta JetXPos      ;JetXPos = 65
    lda #5
    sta JetYPos      ;JetYPos = 5
    lda #83
    sta BomberYPos   ;BomberYPos = 83
    lda #65
    sta BomberXPos   ;BomberXPos = 65
    lda #%11010100
    sta Random       ;Random = $D4
    lda #0
    sta Score
    sta Timer        ;score and timer = 0

    ;declare missile macro-----------------------------------------------
    MAC DRAW_MISSILE
        lda #%00000000
        cpx MissileYPos          ;compare current scanline to missile y position
        bne SkipMissileDraw      ;skip draw if not equal
DrawMissile:
        lda #%00000010           ;enable missile 0 display
        inc MissileYPos     
SkipMissileDraw:                
        sta ENAM0 ;store the value in the missile 0 TIA register
    ENDM

    ;initialize pointers------------------------------------------------
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

    ;start main display loop--------------------------------------------
StartFrame:
    ;display VSYNC and VBLANK-------------------------------------------
    lda #2
    sta VSYNC
    sta VBLANK
    ;generate 3 lines of VSYNC------------------------------------------
    REPEAT 3
        sta WSYNC
    REPEND 
    ;turn off VSYNC-----------------------------------------------------
    lda #0
    sta VSYNC

    ;generate 37 lines of VBLANK----------------------------------------
    REPEAT 33
        sta WSYNC
    REPEND

    ;calculations and tasks in VBLANK-----------------------------------
    lda JetXPos
    ldy #0
    jsr SetObjectXPos          ;set player 0 horizontal position

    lda BomberXPos
    ldy #1
    jsr SetObjectXPos          ;set player 1 horizontal position

    lda MissileXPos
    ldy #2
    jsr SetObjectXPos          ;set missile horizontal position

    jsr CalculateDigitOffset   ;calculate the scoreboard offset

    jsr GenerateJetSound

    sta WSYNC
    sta HMOVE                  ;apply the horizontal offsets previously set

    ;turn off VBLANK---------------------------------------------------
    lda #0
    sta VBLANK
    
    ;clear TIA registers-----------------------------------------------
    lda #0              ;clear TIA registers
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta COLUBK
    lda #$1C            ;set scoreboard colour to white
    sta COLUPF
    lda #%00000000
    sta CTRLPF          ;disable playfield reflection

    ;display scoreboard lines------------------------------------------
    ldx #DIGIT_HEIGHT   ;store 5 in X
ScoreDigitLoop:
    ldy TensDigitOffset ;get the tens digit offset for the score
    lda Digits,Y        ;load sprite
    and #$F0            ;mask the graphics for ones digit
    sta ScoreSprite     ;score the tens digit pattern

    ldy OnesDigitOffset
    lda Digits,Y 
    and #$0F
    ora ScoreSprite     ;merge ones and tens into one sprite
    sta ScoreSprite
    sta WSYNC           ;wait for new scanline
    sta PF1             ;update the playfield

    ldy TensDigitOffset+1
    lda Digits,Y 
    and #$F0
    sta TimerSprite

    ldy OnesDigitOffset+1
    lda Digits,Y 
    and #$0F
    ora TimerSprite
    sta TimerSprite

    jsr Sleep12Cycles
    sta PF1
    ldy ScoreSprite
    sta WSYNC

    sty PF1
    inc TensDigitOffset
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1

    jsr Sleep12Cycles

    dex                 ;X--
    sta PF1
    bne ScoreDigitLoop  ;branch back to ScoreDigitLoop if dex != 0
    sta WSYNC

    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta WSYNC
    sta WSYNC
    sta WSYNC

    ;display 96 visible scanlines (2 line kernel)-----------------------------
VisibleLine:
    lda TerrainColour
    sta COLUPF    ;set the terrain colour to TerrainColour

    lda RiverColour
    sta COLUBK    ;set the river colour to RiverColour  

    lda %00000001
    sta CTRLPF    ;enable playfield reflection
    lda #$F0
    sta PF0       ; setting PF0 bit pattern
    lda #$FC
    sta PF1       ; setting PF1 bit pattern
    lda #0
    sta PF2       ; setting PF2 bit pattern

    ldx #85      ;X counts the remaining number of scanlines

LineLoop:
    DRAW_MISSILE    ;assembler macro to draw missile

InsideJetSprite:
    txa                     ;transfer x to acc
    sec                     ;set carry flag for subtraction
    sbc JetYPos             ;subtract sprite Y coord
    cmp #JET_HEIGHT          ;compare with jet height
    bcc DrawSpriteP0        ;if result < SpriteHeight call draw routine
    lda #0                  ;else, load 0

DrawSpriteP0:
    clc                     ;clear carry before addition
    adc JetAnimOffset       ;jump to the sprite frame in memory

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
    cmp #BOMBER_HEIGHT     ;compare with jet height
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

    lda #0
    sta JetAnimOffset       ;reset jet animation


    lda #2
    sta VBLANK    ;turn on VBLANK

    REPEAT 30
        sta WSYNC ;display 30 lines of overscan
    REPEND

    lda #0
    sta VBLANK    ;turn off VBLANK

    ;process joystick input for P0--------------------------------------------------------------------
CheckP0Up:
    lda #%00010000      ;player 0 joystick up
    bit SWCHA
    bne CheckP0Down
    lda JetYPos     ;if up isnt being pressed skip to down
    cmp #70
    bpl CheckP0Right
P0UpPressed:
    inc JetYPos
    lda #0
    sta JetAnimOffset   ;reset animation

CheckP0Down:
    lda #%00100000      ;Player 0 joystick down
    bit SWCHA
    bne CheckP0Left     ;skip to left if not pressed
    lda JetYPos
    cmp #5
    bmi CheckP0Left
P0DownPressed:
    dec JetYPos
    lda #0
    sta JetAnimOffset   ;reset animation

CheckP0Left:
    lda #%01000000      ;Player 0 joystick left
    bit SWCHA
    bne CheckP0Right    ;skip to right if not pressed
    lda JetXPos
    cmp #35
    bmi CheckP0Right
P0LeftPressed:
    dec JetXPos
    lda #JET_HEIGHT      ;9
    sta JetAnimOffset   ;set the animation offset to the next frame

CheckP0Right:
    lda #%10000000      ;player 0 joystick right
    bit SWCHA
    bne CheckButtonPressed         ;fallback to button press
    lda JetXPos
    cmp #100
    bpl CheckButtonPressed
P0RightPressed:
    inc JetXPos
    lda #JET_HEIGHT      ;9
    sta JetAnimOffset   ;set the animation offset to the next frame

CheckButtonPressed:
    lda #%10000000
    bit INPT4           ;if button is pressed and not equal end input check
    bne NoInput
ButtonPressed:
    lda JetXPos
    clc
    adc #4 
    sta MissileXPos     ;spawn missile at jet x position
    lda JetYPos
    clc
    adc #5
    sta MissileYPos     ;spawn missile at jet y position

NoInput:

    ;calculations to update position for next frame--------------------------------------------------
UpdateBomberPosition:
    lda BomberYPos              ;load Bomber Y position to acc
    clc                         ;clear the carry flag
    cmp #0                      ;compare Y position to 0
    bmi ResetBomberPosition     ;branch to ResetBomberPosition if the number is a negative
    dec BomberYPos              ;decrement the bomber y position
    jmp EndPositionUpdate       ;jump to fallback

ResetBomberPosition:            ;resets Bomber Y position back to the top of the screen
    jsr GetRandomBomberPosition ;call subroutine for random bomber x position

EndPositionUpdate:      ;fallback for position update code

    ;check for object collision----------------------------------------------------------------------
CheckCollisionP0P1:
    lda #%10000000      ;CXPPMM bit 7 detects P0 and P1 collision
    bit CXPPMM          ;check CXPPMM with the above pattern
    bne CollisionP0P1   ;collision between P0 and P1
    jsr SetTerrainRiverColour
    jmp CheckCollisionM0P1

CollisionP0P1:
    jsr GameOver        ;game over

CheckCollisionM0P1:
    lda #%10000000
    bit CXM0P
    bne M0P1Collided
    jmp EndCollisionCheck

M0P1Collided:
    sed
    lda Score
    clc
    adc #1
    sta Score
    cld
    lda #0
    sta MissileYPos

EndCollisionCheck:      ;collision check fallback
    sta CXCLR

    ;loop new frame
    jmp StartFrame

    ;subroutine to handle sprite X offset----------------------------------------------------------
    ;A is the target offset position, 
    ;Y is the object type (0: Player0 1: Player1 2: missile0 3: missile1 4: ball)
SetObjectXPos subroutine
    sta WSYNC       ;wait for fresh scanline
    sec             ;carry flag for subtraction
DivideLoop
    sbc #15         ;subtract 15 from acc
    bcs DivideLoop  ;loop until carry flag is clear
    eor #7          ;adjust remainder to -8 to 7
    asl
    asl
    asl
    asl             ;four left shifts as HMP0 only targets the top 4 bits
    sta HMP0,Y      ;store the fine offset
    sta RESP0,Y     ;fix object in 15 step intervals
    rts

    ;Game over Subroutine-------------------------------------------------------------------------
GameOver subroutine
    lda #$30
    sta TerrainColour              ;set terrain colour to red
    sta RiverColour                ;set river colour to red
    lda #0
    sta Score                      ;score = 0
    rts

    ;subroutine to generate Linear Feedback Shift Register random number--------------------------
    ;generate a random number
    ;divide the random by 4 to match river width
    ;add 30 to compensate for left playfield
GetRandomBomberPosition subroutine
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random               ; performs a series of shifts and bit operations

    lsr
    lsr                      ; divide the value by 4 with 2 right shifts
    sta BomberXPos           ; save it to the variable BomberXPos
    lda #30
    adc BomberXPos           ; adds 30 + BomberXPos to compensate for left PF
    sta BomberXPos           ; and sets the new value to the bomber x-position

    lda #96
    sta BomberYPos           ; set the y-position to the top of the screen

SetScoreValues:
    sed                     ;set decimal mode
    lda Timer
    clc
    adc #1
    sta Timer               ;add 1 to timer

    cld                     ;disable BCD mode      

    ;Subroutine to handle scoreboard digits---------------------------------------------------------------------
    ;convert the top and bottom nybbles into the score and timer offset
    ;each digit is 5 bytes tall
    ;for low nybble multiplication of 5 is required
    ;left shift to multiply by two
    ;right shift to divide

CalculateDigitOffset subroutine
    ldx #1                    ;loop counter
PrepareScoreLoop:             ;loop twice, first 1 then 0
    lda Score,X               ;Score + 1 = timer
    and #$0F                  ;remove the tens digit by masking 4 bits
    sta Temp                  ;Save the value in a temporary variable
    asl                       ;shift left twice and add N for multiplication by 5
    asl
    adc Temp
    sta OnesDigitOffset,X 

    lda Score,X 
    and #$F0
    lsr 
    lsr
    sta Temp 
    lsr
    lsr
    adc Temp
    sta TensDigitOffset,X          

    dex
    bpl PrepareScoreLoop      ;to prepare score loop
    rts

Sleep12Cycles subroutine
    rts

SetTerrainRiverColour subroutine
    lda #$C2
    sta TerrainColour       ;set colour to green
    lda #$84
    sta RiverColour         ;set river to blue
    rts

GenerateJetSound subroutine
    lda #1
    sta AUDV0               ;set volume register to 1

    lda JetYPos             ;load y position into A
    lsr
    lsr
    lsr                     ;divide JetYPos by 8
    sta Temp                ;store in Temp
    lda #31                 ;load 31 into A
    sec                     ;set carry flag
    sbc Temp                ;subtract JetYPos from 31
    sta AUDF0               ;set new pitch

    lda #8 
    sta AUDC0               ;set tone register to 4


    rts
    ;ROM lookup tables-----------------------------------------------------------------------
JetSprite:
    .byte #%00000000
    .byte #%01010100;$1E
    .byte #%01010100;$40
    .byte #%01111100;$40
    .byte #%00111000;$40
    .byte #%00111000;$40
    .byte #%00111000;$40
    .byte #%00010000;$40
    .byte #%00010000;$40


JetSpriteTurn:
    .byte #%00000000;$1E
    .byte #%00101000;$1E
    .byte #%00111000;$40
    .byte #%00111000;$40
    .byte #%00010000;$40
    .byte #%00010000;$40
    .byte #%00010000;$40
    .byte #%00010000;$40

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
    .byte #$1E
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40

JetTurnColour:
    .byte #$1E;
    .byte #$1E;
    .byte #$40;
    .byte #$40;
    .byte #$40;
    .byte #$40;
    .byte #$40;
    .byte #$40;
    .byte #$40;

BomberColour:
    .byte #$00
    .byte #$00
    .byte #$FF
    .byte #$FF
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$0F

Digits:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #

    ;end of ROM------------------------------------------------------------------
    org $FFFC
    .word reset
    .word reset
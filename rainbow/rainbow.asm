    Processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

Start:
    CLEAN_START             ;macro to safely clear PIA RAM and TIA

;start a new frame by generating the VSYNC and VBLANK scanlines
NextFrame:
    lda #2                  ;starts VSYNC and VBLANK, same as binary %00000010
    sta VBLANK              ;turn on vblank
    sta VSYNC               ;turn on vsync

;generate the three vsync scanlines
;WSYNC = wait for sync of scanline
    sta WSYNC               ;first scanline
    sta WSYNC               ;second scanline
    sta WSYNC               ;third scanline

    lda #0
    sta VSYNC               ;turn off vsync

;let the TIA output the 37 VBLANK scanlines
    ldx #37                 ;X = 37 (to count 37 scanlines)

LoopVBLANK:
    sta WSYNC               ;hit WSYNC wait for the next scanline
    dex                     ;X--
    bne LoopVBLANK          ;loop while X != 0

    lda #0
    sta VBLANK              ;turn off VBLANK

;Draw 192 visible scanlines
    ldx #192                ;counter for 192 visible scanlines

LoopVisible:
    stx COLUBK              ;set the background colour
    sta WSYNC               ;wait for the next scanline
    dex                     ;X--
    bne LoopVisible

;Draw 30 overscan VBLANK scanlines to finish the frame
    lda #2                  ;hit and turn on VBLANK again
    sta VBLANK

    ldx #30                 ;counter for 30 overscan lines

LoopOverscan:
    sta WSYNC               ;wait for next scanline
    dex                     ;X--
    bne LoopOverscan        ;loop while X != 0

    jmp NextFrame

;complete rom
    org $FFFC
    .word Start
    .word Start
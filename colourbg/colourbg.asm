    Processor 6502      ;defines the processor as 6502

    include "vcs.h"     ;includes the vch header file
    include "macro.h"   ;includes the macro header file

    seg code            ;starts a segment named code
    org $F000           ;defines the origin of the ROM

Start:
    CLEAN_START         ;Macro to safely clear the memory

    ;Set background luminescence (colour) to red
    lda #$44            ;load  the acc with the colour code for orange ($44 is ntsc orange)
    sta COLUBK          ;store acc to background colour address (alias to $09)
    jmp Start           ;loop back to start

    ;fill rom size to 4k
    org $FFFC
    .word Start        ;reset vector
    .word Start        ;interrupt break vector (unused in VCS)
;Processor = MOS 6507
;Graphics chip = TIA (Television Interface Adapter)

;Place makefile into project directory and assembly using the command "make all"

;(x+68)/3 clock cycles with X being the horizontal position you want your sprite to be

LDX ;loads a value into the X register
LDA ;loads a value into the A register
LDY ;loads a value into the Y register

STA ;stores a value in the A register into a defined memory address
STX ;stores a value in the X register into a defined memory address
STY ;stores a value in the Y register into a defined memory address

ADC ;add a value to the A register (with the carry flag)
SBC ;subtract a value from the A register (with the carry flag)

CLC ;clears the carry flag (usually used before addition)
SEC ;sets the carry flag (usually used before subtraction)

INC ;increment value in a memory address by one
INX ;increment the value in register X by one
INY ;increment the value in register Y by one

DEC ;decrement value in a memory address by one
DEX ;decrememnt value in register X by one
DEY ;decrement value in register Y by one

Z=1 ;if the result of a decremation is 0 set the Z flag to 1, otherwise set it to 0
N=1 ;if the sign bit (most significant bit) is 1 set the N flag to 1, otherwise set to 0

JMP ;jump to another ROM address

;branches are similar to conditional jumps in x86

BCC ;branch on carry clear         C=0
BCS ;branch on carry set           C=1
BEQ ;branch on equal to zero       Z=1
BNE ;branch on not equal to zero   Z=0
BMI ;branch on minus               N=1
BPL ;branch on plus                N=0
BVC ;branch on overflow clear      V=0
BVS ;branch on overflow set        V=1

;Loop example;
    LDY #100 ;set Y register to 100
Loop:        ;label (basically a function)
    DEY      ;decrement Y register by one (Y = 99)
    BNE Loop ;repeat loop until Y = 0

TAX ;transfer accumulator to X
TAY ;transfer accumulator to Y
TSX ;transfer stack pointer to X
TXA ;transfer X to accumulator
TXS ;transfer X to stack pointer
TYA ;transfer Y to accumulator

;VCS Memory map
$00 - $7F ;TIA registers
$80 - $FF ;memory addresses for PIA RAM
$F000 - $FFFF ;ROM space
$FFFC ;Reset vector
$FFFE ;interrupt break



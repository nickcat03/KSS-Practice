;KSS Practice Hack

; compile to FastROM
!_F = $800000

; give the cartridge more SRAM
ORG !_F+$00FFD8
        db $07

; include other files
incsrc "defines.asm"
incsrc "everyframe.asm"


; make sure the ROM is expanded to the full 1MBit
ORG !_F+$1FFFFF
        db $EA

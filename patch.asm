;KSS Practice Hack

; compile to FastROM
!_F = $800000

; give the cartridge more SRAM
ORG !_F+$00FFD8
        db $08

; include other files
incsrc "defines.asm"
incsrc "hex_edits.asm"
incsrc "sa1.asm"
incsrc "mww_map.asm"
incsrc "abilities.asm"
incsrc "subroutines.asm"
incsrc "tables.asm"
incsrc "room_reload.asm"
;incsrc "hblank.asm"
incsrc "nmi.asm"
incsrc "qsql.asm"

; make sure the ROM is expanded to the full 1MBit
ORG !_F+$1FFFFF
        db $EA
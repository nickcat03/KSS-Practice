;KSS Practice Hack

; compile to FastROM
!_F = $800000

; give the cartridge more SRAM
ORG !_F+$00FFD8
        db $08

; These are ran first because they are not part of the main code block
incsrc "src/defines.asm"
incsrc "src/hex_edits.asm"
incsrc "src/hijacks.asm"
incsrc "src/hud.asm"

; These are all graphics inserts, all of them are compressed graphics. They have minor edits but the entire graphics section needs to be reinserted because of the compression.
incsrc "graphics/graphics.asm"
incsrc "graphics/hud_layouts.asm"

; All of these are ran together because they are all going to be placed in the blank space in ROM
ORG $00F140
;incsrc "src/cpu.asm"
incsrc "src/sa1.asm"
incsrc "src/mww_map.asm"
incsrc "src/free_movement.asm"
incsrc "src/abilities.asm"
incsrc "src/kirby_colors.asm"
incsrc "src/subroutines.asm"
incsrc "src/tables.asm"
incsrc "src/room_reload.asm"
;incsrc "src/hblank.asm"
incsrc "src/nmi.asm"
incsrc "src/qsql.asm"
incsrc "src/mute_toggle.asm"

; make sure the ROM is expanded to the full 1MBit
ORG !_F+$1FFFFF
        db $EA
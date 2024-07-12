; MWW ability autoselect tables
; Each bit in the following RAM values are responsible for each ability:
;$7B1B:                 $7B1C:                  $7B1D: 
;7 - none?              7 - Wheel               7 - none?
;6 - Hammer             6 - Ninja               6 - none?
;5 - Plasma             5 - Mirror              5 - none?
;4 - Sword              4 - Parasol             4 - Suplex
;3 - Bomb               3 - Jet                 3 - Copy
;2 - Fighter            2 - Ice                 2 - Stone
;1 - Beam               1 - Fire                1 - Wing
;0 - none?              0 - Cutter              0 - Yo-yo 

; Values for each planet: 
; 00 - Floria           05 - Mecheye
; 01 - Hotbeat          06 - Halfmoon 
; 02 - Skyhigh          07 - ???
; 03 - Cavios           08 - Nova
; 04 - Aqualis          09 - Popstar 

; Tables for converting planet number to proper any% order

;mww_planets_rta_order: db $05, $01, $00, $03, $04, $02, $06, $08, $07
;mww_planets_orig_order: db $00, $01, $02, $03, $04, $05, $06, $07, $08

; These tables are explicitly for 100% route.
;                   Floria     Hotbeat    Skyhigh    Cavios     Aqualis    Mecheye    Halfmoon   ???        Nova
ability_table_1: db %01101000, %00000000, %00000000, %00000000, %01101100, %00000000, %01111110, %01101000, %11111111
ability_table_2: db %10001010, %10001000, %00000000, %10001010, %10001111, %10001010, %10011111, %10001010, %11111111
ability_table_3: db %00011111, %00000010, %00000000, %00010010, %00011111, %00010010, %11111111, %00010111, %11111111

; For any%, the only RAM value that needs to be changed is the one with Hammer and Plasma ($7B1B)
;                     Floria     Hotbeat    Skyhigh    Cavios     Aqualis    Mecheye    Halfmoon   ???        Nova
ability_table_any: db %01100000, %00000000, %00000000, %01000000, %01100000, %00000000, %01100000, %01100000, %01100000
ability_amount_any: db $02, $01, $00, $01, $02, $01, $02, $02, $02


; Table for "Off" audio button graphics
off_button_graphics: db $B4, $06, $B5, $06, $B6, $06, $B7, $06, $B8, $06, $B9, $06, $BA, $06, $BB, $06, $BC, $06


; Custom Colors
palette_table: dw palette_flash, palette_pink, palette_red, palette_yellow, palette_light_blue, palette_blue, palette_sapphire, palette_purple, palette_brown, palette_chalk

palette_flash: db $00, $00, $FF, $7F, $BF, $77, $9F, $76, $1E, $72, $9D, $6D, $1B, $65, $DF, $49, $5F, $4A, $8C, $31, $08, $21
palette_pink: db $00, $00, $FF, $7F, $9F, $76, $DE, $71, $1C, $69, $58, $58, $0E, $2C, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_red: db $00, $00, $FF, $7F, $9F, $45, $3D, $39, $DA, $2C, $78, $24, $15, $18, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_yellow: db $00, $00, $FF, $7F, $9F, $4B, $DF, $32, $FE, $1D, $3C, $09, $B2, $08, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_light_blue: db $00, $00, $FF, $7F, $D2, $7F, $49, $7F, $80, $7E, $CB, $7C, $0A, $18, $0D, $2C, $0F, $44, $C6, $18, $00, $00
palette_blue: db $00, $00, $F4, $7F, $71, $7F, $ED, $7E, $6A, $7E, $E5, $7D, $82, $61, $C5, $3C, $6C, $7D, $09, $6D, $66, $58
palette_sapphire: db $00, $00, $36, $7F, $6F, $76, $0C, $6E, $CA, $65, $40, $59, $E0, $4C, $80, $3C, $0A, $5C, $08, $48, $07, $34
palette_purple: db $00, $00, $FF, $7F, $1C, $76, $9B, $71, $F9, $68, $56, $5C, $0F, $3C, $16, $18, $5C, $24, $C6, $18, $00, $00
palette_brown: db $00, $00, $FF, $7F, $5B, $42, $FA, $3D, $99, $39, $37, $31, $13, $1D, $98, $04, $BE, $10, $C6, $18, $00, $00
palette_chalk: db $00, $00, $FF, $7F, $7B, $6F, $F7, $5E, $73, $4E, $CE, $39, $4A, $29, $C6, $18, $EF, $3D, $6B, $2D, $08, $21


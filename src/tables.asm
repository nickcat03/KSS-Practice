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
;                   Floria      Hotbeat     Skyhigh     Cavios      Aqualis     Mecheye     Halfmoon    ???         Nova
ability_table_1: db %01101000, %00000000, %00000000, %00000000, %01101100, %00000000, %01111110, %01101000, %11111111
ability_table_2: db %10001010, %10001000, %00000000, %10001010, %10001111, %10001010, %10011111, %10001010, %11111111
ability_table_3: db %00011111, %00000010, %00000000, %00010010, %00011111, %00010010, %11111111, %00010111, %11111111

; For any%, the only RAM value that needs to be changed is the one with Hammer and Plasma ($7B1B)
;                     Floria      Hotbeat     Skyhigh     Cavios      Aqualis     Mecheye     Halfmoon    ???         Nova
ability_table_any: db %01100000, %00000000, %00000000, %01000000, %01100000, %00000000, %01100000, %01100000, %01100000
ability_amount_any: db $02, $01, $00, $01, $02, $01, $02, $02, $02


; Table for "Off" audio button graphics
off_button_graphics: db $B4, $06, $B5, $06, $B6, $06, $B7, $06, $B8, $06, $B9, $06, $BA, $06, $BB, $06, $BC, $06











; This file is for inserting custom HUD tile layouts into the ROM
; The HUD layout uses the same compression as game graphics

; Some notes on where certain tileset properties are located in RAM:
; $7E0500 colors for all the background elements if you wanted to green screen or something
; $7E1520 HUD color palettes
; $7E1617 HUD tile art
; $7E16F7 HUD tile palette/rotation

; Note that this script is replacing only the tile art and palette/rotation info. This is what is compressed in the ROM.

check bankcross off

; All below are HUD changes to fix RNG display having flipped tiles
; RoMK HUD overrides (Boss HUD does not require edits)
ORG $56B494
    incbin "graphics/bin/hud/romk_default.bin"
ORG $56BC07
    incbin "graphics/bin/hud/romk_helper.bin"

; MWW HUD overrides
ORG $55BB34
    incbin "graphics/bin/hud/mww_default.bin"
ORG $55E7F8
    incbin "graphics/bin/hud/mww_helper.bin"
ORG $55B89B
    incbin "graphics/bin/hud/mww_boss.bin"
ORG $55DE46
    incbin "graphics/bin/hud/mww_helper_boss.bin"
; This file is for inserting graphics files into the ROM

; Some notes on where certain graphics are located (all PC address):
; Kirby Sprite graphics start at $2D0000 (uncompressed)
; Possible title screen graphics start at $354A00
; Title Screen graphic at $038CFD 
; HALKEN logo graphic at $1EC5CD

check bankcross off

; Corkboard graphics, specifically for the "Off" graphic on Stereo/Mono button.
ORG $2CDED4
    incbin "corkboard.bin"
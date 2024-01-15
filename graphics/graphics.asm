; This file is for inserting graphics files into the ROM

check bankcross off

; Corkboard graphics, specifically for the "Off" graphic on Stereo/Mono button.
ORG $2CDED4
    incbin "corkboard.bin"
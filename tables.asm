; pointer table for all of the below abilities
ability_pointers: dw normal_ability, plasma_ability, wheel_ability

; data for each ability, and where to write the data
write_ability_to: dw $749E, $7590, $3778, $377E, $3784, $3786, $378A, $378C, $3790, $3792
normal_ability: dw $00C0, $20FF, $9598, $014E, $0000, $FF00, $0000, $0000, $0000, $AD00
plasma_ability: dw $0CC0, $62FF, $99FC, $0380, $F150, $FFC5, $C336, $00C4, $6AA1, $ADC7
wheel_ability: dw $0DC0, $64FF, $96E4, $01F4, $D9F4, $FFC5, $9DB6, $00C4, $33AE, $ADC7
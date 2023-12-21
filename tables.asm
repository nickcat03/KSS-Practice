; pointer table for all of the below abilities
;ability_pointers: dw normal_ability, plasma_ability, wheel_ability, jet_ability, hammer_ability, wing_ability, cutter_ability

; data for each ability, and where to write the data
;write_ability_to: dw $749E, $7590, $3778, $377E, $3784, $3786, $378A, $378C, $3790, $3792
;normal_ability: dw $0000, $20FF, $9598, $014E, $0000, $FF00, $0000, $0000, $0000, $AD00
;plasma_ability: dw $0C00, $62FF, $99FC, $0380, $F150, $FFC5, $C336, $00C4, $6AA1, $ADC7
;wheel_ability: dw $0D00, $64FF, $96E4, $01F4, $D9F4, $FFC5, $9DB6, $00C4, $33AE, $ADC7
;jet_ability: dw $0700, $2EFF, $9918, $030E, $EB28, $FFC5, $B6FE, $00C4, $57B7, $ADC7
;hammer_ability: dw $1200, $A2FF, $9BA4, $0454, $F6C8, $FFC5, $CA46, $00C4, $7B11, $ADC7
;wing_ability: dw $0500, $2A00, $9830, $029A, $E468, $FFC5, $AABE, $00C4, $4628, $DBC7
;cutter_ability: dw $0100, $2200, $9614, $018C, $D384, $FFC5...
; Make file deletion instant
; LDA #$00B4 -> LDA #$0000
ORG !_F+$078736
    dw $0000

; No game over in Arena
; CMP #$0006 -> CMP #$00FF
ORG !_F+$0387F4
    db $FF

; Checkpoints in all rooms
; At a later point, this should have the option of being disabled by holding a button upon dying
; BEQ -> BRA
ORG !_F+$01813D
    db $80

; Always have MWW cursor highlight "Continue"
; BEQ -> BRA
ORG !_F+$07DA3E
    db $80

; Never display subgame cutscene after inactivity
; BNE -> BRA
ORG !_F+$07DD67
    db $80

; Never decrease RoMK timer 
; DEC $73A0 -> NOP
ORG !_F+$00C227
    NOP #3

; Always spawn Chests and Copy Essences
; all BEQ -> BRA 
ORG !_F+$1EBF92
    db $80
ORG !_F+$1EBFB5
    db $80
ORG !_F+$1EF1EF
    db $80
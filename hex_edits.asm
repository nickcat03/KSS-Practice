; Make file deletion instant
; LDA #$00B4 -> LDA #$0000
ORG !_F+$078736
    dw $0000

; Spring Breeze bosses always have New File health
; BNE $XX -> NOP NOP 
ORG !_F+$00ED96
    NOP #2

; GCO bosses respawn 
; BEQ -> BRA for all 
; Fatty Whale
ORG !_F+$2AA800
    db $80
; Battle Windows 
ORG !_F+$2ADDE4 
    db $80
; Ghameleo Arm  
ORG !_F+$2AC303
    db $80
; Wham Bam
ORG !_F+$2AD1E5
    db $80

; No game over in Arena
; CMP #$0006 -> CMP #$00FF
ORG !_F+$0387F4
    db $FF

; Checkpoints in all rooms
; At a later point, this should have the option of being disabled by holding a button upon dying
; (For the time being, I commented it out as the new room reload routine is better for this purpose)
; BEQ -> BRA
;ORG !_F+$01813D
;    db $80

; Always have MWW cursor highlight "Continue"
; BEQ -> BRA
ORG !_F+$07DA3E
    db $80

; Never display subgame cutscene after inactivity
; This makes RNG manip impossible so maybe remove this
; BNE -> BRA
;ORG !_F+$07DD67
;    db $80

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

; Avoid losing abilities when dying:
; Never lose ability
; LDA #$0000 -> BRA 1F, NOP
ORG !_F+$03A1FE
    db $80, $1F, $EA
; Keep Helper
; LDA #$FFFF -> RTL 
ORG !_F+$038727
    RTL
; Keep Wheelie Rider state
; STZ $7569 -> NOP x3
ORG !_F+$03A081
    NOP #3
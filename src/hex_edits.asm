; Code for getting Mute button graphics
ORG $15BCC2
    JML set_button_gfx
    NOP #2

; All sub-games selectable
; allow for selection
; LDA $7A83 -> LDA #$0005
ORG $15B644
    LDA #$0005
; visibly show games unlocked
; BEQ $XX -> NOP
ORG $15B831
    LDA #$007F

; Make file deletion instant
; LDA #$00B4 -> LDA #$0000
ORG $078736
    dw $0000

; Make death animation instant
; $B4 -> $01
ORG $088D9D
    db $01

; Set lives to 99 (purely cosmetic)
; LDA #$0003 -> LDA #$0063
ORG $00D873
    LDA #$0063

; Don't decrease lives counter
; DEC $737A -> NOP
ORG $0387E1
    NOP #3

;Set BRK vector to game reset subroutine. This makes it so the game is reset on a crash rather than... crashing.
;$BCE7 is where the reset subroutine is located.
ORG $00FFE6
    dw $E7BC

; Do not clear the entirety of SRAM 
; LDA #$1EFE -> LDA #$1B6E
ORG $008C04
    LDA #$1B6E

; Leave every Dyna Blade stage
; always show leave menu
; BEQ $0C -> BRA $04
ORG $1F9F10
    db $80, $04
; actual logic to accept leave stage input
; BEQ $D7 -> BRA $04
ORG $1F9E5D
    db $80, $04

; Leave every MWW stage
; BNE $XX -> NOP
ORG $1FA611
    NOP #2

; Spring Breeze bosses always have New File health
; BNE $XX -> NOP 
ORG $00ED96
    NOP #2

; GCO bosses respawn 
; BEQ -> BRA for all 
; Fatty Whale
ORG $2AA800
    db $80
; Battle Windows 
ORG $2ADDE4 
    db $80
; Ghameleo Arm  
ORG $2AC303
    db $80
; Wham Bam
ORG $2AD1E5
    db $80

; No game over in Arena
; CMP #$0006 -> CMP #$00FF
ORG $0387F4
    db $FF

; Checkpoints in all rooms
; At a later point, this should have the option of being disabled by holding a button upon dying
; (For the time being, I commented it out as the new room reload routine is better for this purpose)
; BEQ -> BRA
;ORG $01813D
;    db $80

; Always have MWW cursor highlight "Continue"
; BEQ -> BRA
ORG $07DA3E
    db $80

; Disable GCO treasure menu (temporary, as it overrides X button combos)
; LDA #$1040 -> LDA #$1000
ORG $00CB6C
    db $00

; Never display subgame cutscene after inactivity
; This makes RNG manip impossible so maybe remove this
; BNE -> BRA
;ORG $07DD67
;    db $80

; Never decrease RoMK timer 
; DEC $73A0 -> NOP
ORG $00C227
    NOP #3

; Always spawn Chests and Copy Essences
; all BEQ -> BRA 
ORG $1EBF92
    db $80
ORG $1EBFB5
    db $80
ORG $1EF1EF
    db $80

; Avoid losing abilities when dying:
; Never lose ability
; LDA #$0000 -> BRA 1F, NOP
ORG $03A1FE
    db $80, $1F, $EA
; Keep Helper
; LDA #$FFFF -> RTL 
ORG $038727
    RTL
; Keep Wheelie Rider state
; STZ $7569 -> NOP x3
ORG $03A081
    NOP #3

; Stop Red Screen Flashing
ORG $27E529
    RTS
ORG $27E547
    RTS
ORG $27E565
    RTS

; For some reason this code causes RoMK cutscenes to replay for some reason...
; Could be due to the cutscene acting as a "consumable" 
; Consumables (tomato, candy, etc.) always respawn
; STA $28 -> STZ $28
;ORG $00E9DF
;    STZ $28

; Change Arena timer color
;ORG $598680
;    db $1F

; Always on quick pause 
;ORG $1F991F
;    db $80

; Stupid hack for QSQL (swap the order of two subroutines so it is easier to call one of them and then return while still using the built in routine)
ORG $018071
    JSR $8698
    JSR $8678   ; we only need to really use this one so it will be placed on the bottom 
    ; RTL (this returns back to the QSQL code, commented out because this exists in the regular game code already)
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

; Don't decrease lives counter
; DEC $737A -> NOP
; Instead replace with resetting free move toggle
ORG $0387E1
    STZ !toggle_free_move

;Set BRK vector to game reset subroutine. This makes it so the game is reset on a crash rather than... crashing.
;$BCE7 is where the reset subroutine is located.
ORG $00FFE6
    dw $E7BC

; Do not clear the entirety of SRAM 
; LDA #$1EFE -> LDA #$1B6F
ORG $008C04
    LDA #$1B6F

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

; Always have MWW cursor highlight "Continue"
; BEQ -> BRA
ORG $07DA3E
    db $80

; Disable GCO treasure menu (so it doesn't override X button combos)
; LDA #$1040 -> LDA #$1000
ORG $00CB6C
    db $00

; Never decrease RoMK timer 
; DEC $73A0 -> NOP
ORG $00C227
    NOP #3
; Make RoMK timer reaching zero not kill you (usually for warping into RoMK room from other subgame)
; BEQ -> BRA
ORG $029078
    db $80

; Always spawn Chests and Copy Essences
; all BEQ -> BRA 
ORG $1EBF92
    db $80
ORG $1EBFB5
    db $80
ORG $1EF1EF
    db $80

; Stop Red Screen Flashing
ORG $27E529
    RTS
ORG $27E547
    RTS
ORG $27E565
    RTS

; Change Arena timer color
;ORG $598680
;    db $1F

; Always on quick pause 
;ORG $1F991F
;    db $80
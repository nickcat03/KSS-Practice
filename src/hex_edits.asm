; The following locations are writes to the volume address
; The writes are replaced with checks to see if mute is toggled
ORG $00CDFE
    JSR check_if_muted

ORG $00CEE7
    JSR check_if_muted

; volume fade-in and out
ORG $00CE26
    JSR check_if_muted

ORG $00D019
    JSR check_if_muted

; Start code for audio mute toggle
ORG $00CDDC
    JSR mute_toggle


; Code for getting Mute button graphics
ORG $15BCC2
    JML set_button_gfx
    NOP #2


; Make file deletion instant
; LDA #$00B4 -> LDA #$0000
ORG $078736
    dw $0000

;Set BRK vector to game reset subroutine. This makes it so the game is reset on a crash rather than... crashing.
;$BCE7 is where the reset subroutine is located.
ORG $00FFE6
    dw $E7BC

; Do not clear the entirety of SRAM 
; LDA #$1EFE -> LDA #$1B6E
ORG $008C04
    LDA #$1B6E

; Stop automatically setting Mono audio when game starts
; STA $33CC -> NOP #2
;ORG $00D538
;    NOP #2

; For testing room reloads. Do not include in release
;ORG $008A01
;    NOP #2

; Spring Breeze bosses always have New File health
; BNE $XX -> NOP NOP 
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

; Consumables (tomato, candy, etc.) always respawn
; STA $28 -> STZ $28
ORG $00E9DF
    STZ $28

; Change Arena timer color
;ORG $598680
;    db $1F

; Always on quick pause 
;ORG $1F991F
;    db $80
; Custom HUD code

; Stuff for HUD in RAM:
; $7E0500 colors for all the background elements if you wanted to green screen or something
; $7E1520 HUD color palettes
; $7E1617 HUD tile art
; $7E16F7 HUD tile rotation

; Jump to code for replacing Lives count in the HUD with RNG number
ORG $01F8A8
    ; Check if RNG changed this frame, and if so run the HUD code
    LDA $3743
    CMP $00B7
    BEQ +
    STA $00B7

    ; Set tile in between both numbers as blank 
    LDA #$FFFF
    STA $7E0000,X

    ; Adjust X so the correct HUD tiles are set
    TXA 
    SEC
    SBC #$0003
    TAX

    LDA $3743   ;RNG 1
    AND #$00FF      ; only consider the first two bits
    JSL display_triple_digit_integer

    ; Adjust X so the correct HUD tiles are set
    TXA 
    CLC
    ADC #$0004
    TAX

    LDA $3744   ;RNG 2
    AND #$00FF      ; only consider the first two bits
    JSL display_triple_digit_integer
    + RTS
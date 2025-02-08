; Custom HUD code

; Stuff for HUD in RAM:
; $7E0500 colors for all the background elements if you wanted to green screen or something
; $7E1520 HUD color palettes
; $7E1617 HUD tile art
; $7E16F7 HUD tile rotation

; -- Display RNG
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

; -- Display Timer
; Built in routine for displaying a double digit number for Gourmet Race timer
!display_number = $EF71

; Replace Score display routine with the following code
ORG $01F938
    TXA     ; Code before jumping to this routine will store the Score tile coordinate in X
    STA $34 ; Transfer it to this temp variable as that's what the Gourmet Race routine update_tileset_kirby_pos
    STZ $36
    JSR $EE52 ; Built in subroutine to calculate timer incrementation

    ; Display numbers in HUD
    SEP #$30
    LDA !timer_minutes
    LDY #$00
    JSR !display_number
    LDA !timer_seconds
    LDY #$03
    JSR !display_number
    LDA !timer_milliseconds
    LDY #$06
    JSR !display_number
    REP #$30
    INC !write_to_HUD
    RTS

; Stop game from clearing the timer
ORG $01F252
    NOP
    NOP
    NOP
; Code hijacks. These are simply hex writes that jump to custom code from the main routine.
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A0D
    JSR sa1_code

; Jump to NMI custom code from main CPU routine
ORG $0081B7
    JSR nmi_code

; Jump to custom room reload code from room reload routine
ORG $01A743
    NOP
    NOP
    JSL room_reload_code

; Jump to code that checks for custom Kirby kirby colors 
ORG $03D8C0
    JSL kirby_colors

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
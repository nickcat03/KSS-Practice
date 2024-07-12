kirby_colors:

    ; Skip everything if Helper palette is being selected 
    LDY $06
    CPY #$0002
    BNE .IsZero
    
    .select_kirby_colors:
        LDA !p1controller_hold
        AND #$2040
        CMP #$2040
        BNE .merge
        LDA !p1controller_frame
        AND #$0020  ; Pressing right
        BNE +
        LDA !toggle_custom_colors
        INC A 
        STA !toggle_custom_colors
        + LDA !p1controller_frame 
        AND #$0010
        BNE + 
        LDA !toggle_custom_colors
        DEC A 
        STA !toggle_custom_colors

        +
        .merge:
        LDA !toggle_custom_colors 
        CMP #$000A
        BCC +
        LDA #$0000
        STA !toggle_custom_colors

    ; See if a color is selected. If it is 0, that means we use default colors.
    + LDA !toggle_custom_colors
    BEQ .IsZero
    JSR apply_colors

    .finalize:

        ; Adjust stack pointer to jump to the previous routine
        TSC 
        CLC
        ADC #$0003
        TCS

        RTL

    ; Run code as normal if default colors are selected
    .IsZero:
        LDX $04
        LDY $06
        RTL


apply_colors:
    .kirby_palette_offset:
        ; Kirby palette offset 
        ; If Kirby is "flashing", use the flashing palette (e.g shielding, jet charge, etc.)
        ; Else, use custom palette
        LDA $75C1
        BNE .set_flash
        LDA $75B5 
        BNE .set_flash
        LDA $75A9
        BNE .set_flash
        LDA $759D
        BNE .set_flash
        LDA !toggle_custom_colors       ;\ Multiply pointer by 2 then assign it to X
        ASL A                           ;|
        TAX                             ;/
        BRA .set_color

    .set_flash:
        ; Set pointer to 0 since that is where flashing colors are
        LDX #$0000
    .set_color:
        LDA palette_table,X
        TAX
        LDY #$0600
        LDA #$0013
        PHB
        MVN $00,$00

    .set_hat_palette:
        ; If hat palette isn't normally overwritten, don't overwrite it
        LDA $00
        CMP #$0016
        BCC +

        LDA $04
        CLC
        ADC #$0014
        LDY #$0614
        TAX
        LDA #$000B
        MVN $00,$C4

        + PLB
        RTS
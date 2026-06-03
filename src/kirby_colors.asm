pushpc
; Jump to code that checks for custom Kirby kirby colors 
ORG $03D8C0
    JSL kirby_colors
pullpc

kirby_colors:

    ; Skip everything if Helper palette is being selected 
    LDY $06
    CPY #$0002
    BNE .IsZero
    
    ; See if a color is selected. If it is 0, that means we use default colors.
    LDA !toggle_custom_colors
    BEQ .IsZero
    JSR apply_colors

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


; Custom Colors
palette_table: dw palette_flash, palette_pink, palette_red, palette_yellow, palette_light_blue, palette_blue, palette_sapphire, palette_purple, palette_brown, palette_chalk

palette_flash: db $00, $00, $FF, $7F, $BF, $77, $9F, $76, $1E, $72, $9D, $6D, $1B, $65, $DF, $49, $5F, $4A, $8C, $31, $08, $21
palette_pink: db $00, $00, $FF, $7F, $9F, $76, $DE, $71, $1C, $69, $58, $58, $0E, $2C, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_red: db $00, $00, $FF, $7F, $9F, $45, $3D, $39, $DA, $2C, $78, $24, $15, $18, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_yellow: db $00, $00, $FF, $7F, $9F, $4B, $DF, $32, $FE, $1D, $3C, $09, $B2, $08, $18, $00, $5F, $10, $C6, $18, $00, $00
palette_light_blue: db $00, $00, $FF, $7F, $D2, $7F, $49, $7F, $80, $7E, $CB, $7C, $0A, $18, $0D, $2C, $0F, $44, $C6, $18, $00, $00
palette_blue: db $00, $00, $F4, $7F, $71, $7F, $ED, $7E, $6A, $7E, $E5, $7D, $82, $61, $C5, $3C, $6C, $7D, $09, $6D, $66, $58
palette_sapphire: db $00, $00, $36, $7F, $6F, $76, $0C, $6E, $CA, $65, $40, $59, $E0, $4C, $80, $3C, $0A, $5C, $08, $48, $07, $34
palette_purple: db $00, $00, $FF, $7F, $1C, $76, $9B, $71, $F9, $68, $56, $5C, $0F, $3C, $16, $18, $5C, $24, $C6, $18, $00, $00
palette_brown: db $00, $00, $FF, $7F, $5B, $42, $FA, $3D, $99, $39, $37, $31, $13, $1D, $98, $04, $BE, $10, $C6, $18, $00, $00
palette_chalk: db $00, $00, $FF, $7F, $7B, $6F, $F7, $5E, $73, $4E, $CE, $39, $4A, $29, $C6, $18, $EF, $3D, $6B, $2D, $08, $21
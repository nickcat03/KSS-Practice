; Code responsible for displaying triple digit numbers in the HUD
display_triple_digit_integer:
    CMP #$03E8  ; check if the number is greater than or equal to 1000, and if it is, set it to 999
    BCC +
    LDA #$03E7
    + LDY #$FFFF
    SEC

    ; hundreds digit
    - INY
    SBC #$0064
    BCS -
    ADC #$0064
    PHA         ; temporarily store calculated number in stack for calculating the rest
    TYA 
    SEP #$20
    ADC #$B5    
    STA $7E0000,X
    REP #$20
    PLA         ; pull the number back to calculate tens and ones digit
    CLC 
    LDY #$FFFF 
    SEC 

    ; tens digit and ones digit
    - INY 
    SBC #$000A 
    BCS -
    ADC #$00C0 
    SEP #$20
    STA $7E0002,X 
    TYA
    CLC 
    ADC #$B6 
    STA $7E0001,X
    REP #$20
    INC $00AF

    .break:
        RTL
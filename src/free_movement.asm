free_movement:
    REP #$30
    STZ !kirby_invincible   ; Make Kirby invincible

    LDA !p1controller_hold
    AND #$0200  ; Left
    CMP #$0200
    BNE +
    LDA !kirby_x_pos
    CLC
    SBC #$0005
    STA !kirby_x_pos

    + LDA !p1controller_hold
    AND #$0100  ; Right
    CMP #$0100
    BNE + 
    LDA !kirby_x_pos
    CLC
    ADC #$0005
    STA !kirby_x_pos

    + LDA !p1controller_hold
    AND #$0400  ; Down
    CMP #$0400
    BNE + 
    LDA !kirby_y_pos 
    CLC
    ADC #$0005
    STA !kirby_y_pos

    + LDA !p1controller_hold
    AND #$0800  ; Up
    CMP #$0800
    BNE +
    LDA !kirby_y_pos 
    CLC
    SBC #$0005
    STA !kirby_y_pos
    
    + RTS

prepare_intangibility:
    REP #$30
    LDX #$0046
    LDY #$0002
    JSL $038D9A
    LDA #$0E6B
    LDX #$00C4
    JSL $00931D
    RTS

    ;$280FF start of collision routine
    ; $28B69 is start of initializing MWW power up select
    ;63B8
    ;63CE
    ;63D0
    ;63D2

    ;63B8
    ;63F6

    ;$721C
    ;$6726
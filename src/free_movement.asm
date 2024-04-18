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
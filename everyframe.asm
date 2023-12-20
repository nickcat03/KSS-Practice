;Jump to blank ROM space from main routine
ORG !_F+$008A0D
    JSR $F11A

;Start code block here:
ORG !_F+$00F11A
instant_death:
    LDA !p1controller_hold
    AND #$4010      ;R+Y held
    ORA !p1controller_frame
    CMP #$4030      ;L pressed
    BNE return_to_main_routine
    LDA #$0000
    STA !kirby_hp   ;set health to 0
    LDA #$0063
    STA !lives      ;set lives to 99

return_to_main_routine:
    LDA $7E95
    STZ $1D
    STZ $19
    RTS
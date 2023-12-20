;Jump to blank ROM space from main routine
ORG !_F+$008A0D
    JSR $F11A

ORG !_F+$00F11A     ; Custom code start

;Button combo for room reset
LDA !p1controller_hold
AND #$4010      ;R+Y held
ORA !p1controller_frame
CMP #$4030      ;L pressed
BNE +
STZ !kirby_hp   ;set health to 0
INC !lives      ;increase life count so it never goes to 0
LDA #$0003
STA !death_animation_timer      ;set timer to 1 so fadeout is instant

return_to_main_routine:
    LDA #$3000  ; run code that was replaced
    RTS
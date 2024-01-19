; Jump to blank ROM space from main routine
ORG $01E922
    JSL $00!hblank_start
    NOP #3

ORG $00!hblank_start      ; Custom code start



hblank_return_to_main_routine:
    LDA $32EA
    ASL
    ADC $32EA          ; run code that was replaced by JSR instruction
                       ; When adding in the custom HUD, edit this code so that $32EA is instead always #$0000 for spring breeze HUD
    TAX          
    RTL
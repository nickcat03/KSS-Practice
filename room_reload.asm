; Jump to blank ROM space from main routine
ORG !_F+$01A74C
    NOP
    NOP
    JSL $00FD00

ORG !_F+$00FD00         ;custom code start    


hblank_return_to_main_routine:
    LDX #$0160          ; run code that was replaced by JSR instruction
    LDA #$0200          
    RTL
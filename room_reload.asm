; Jump to blank ROM space from main routine
;ORG !_F+$01A74C
;ORG !_F+$0089EB
    NOP
    NOP
    JSL $00FA00
;    JSR $FA00
    NOP

ORG !_F+$00FA00         ;custom code start    
    ;JSR auto_save_on_room_load

room_reload_return_to_main_routine:
    REP #$30
    LDX #$0160          ; run code that was replaced by JSR instruction
    LDA #$0200          
    RTL
; Jump to blank ROM space from main routine
ORG $01A743
    NOP
    NOP
    JSL $00!room_reload_start

ORG $00!room_reload_start        ;custom code start    
    ;JSR auto_save_on_room_load

room_reload_return_to_main_routine:
    REP #$30
    LDX #$0008          ; run code that was replaced by JSR instruction
    LDA #$0100          
    RTL
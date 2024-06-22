
room_reload_code:        ;custom code start  
    SEP #$20
    LDA !is_reloading_room
    CMP #$00
    BNE +
    JSR auto_save_on_room_load
    +

room_reload_return_to_main_routine:
    STZ !is_reloading_room
    REP #$30
    LDX #$0008          ; run code that was replaced by JSR instruction
    LDA #$0100          
    RTL
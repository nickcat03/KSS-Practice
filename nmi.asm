; Jump to blank ROM space from main routine
ORG !_F+$0081B7
    JSR $FD00


ORG !_F+$00FD00        ; Custom code start

REP #$30
LDA !QSQL_timer             ; make sure that a save or load hasn't occured in the last 30 frames
CMP #$0000
BNE countdown_QSQL_timer
check_save_input:
    LDA !p1controller_hold
    CMP #$2010
    BNE check_load_input
    LDA !p1controller_frame
    CMP #$2000              ; R + Select = save state
    BNE check_load_input
    JSR save_state 

check_load_input:
    LDA !p1controller_hold
    CMP #$2020
    BNE check_roomload_input
    LDA !p1controller_frame
    CMP #$2000              ; L + Select = load state
    BNE check_roomload_input
    JSR restore_state

check_roomload_input:
    LDA !p1controller_hold
    CMP #$0030
    BNE vblank_return_to_main_routine
    ;JSR restore_current_room
    BRA vblank_return_to_main_routine

countdown_QSQL_timer:
    DEC !QSQL_timer

vblank_return_to_main_routine:
    REP #$30
    LDA #$3000
    RTS

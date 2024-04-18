; Jump to blank ROM space from main routine
ORG $0081B7
    JSR $!nmi_start


ORG $00!nmi_start        ; Custom code start

REP #$30
LDA !current_nmi_load       ; If the game is currently on a lag frame, skip qsql code
CMP !max_nmi_load
BCS vblank_return_to_main_routine

LDA !QSQL_timer             ; make sure that a save or load hasn't occured in the last however many frames
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
    AND #$0010
    ORA !p1controller_frame
    CMP #$0050
    BNE vblank_return_to_main_routine
    JSR restore_current_room
    BRA vblank_return_to_main_routine

countdown_QSQL_timer:
    DEC !QSQL_timer

vblank_return_to_main_routine:
    REP #$30
    LDA #$3000
    RTS

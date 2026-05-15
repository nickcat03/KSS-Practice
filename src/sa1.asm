pushpc
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A0D
    JSR sa1_code
pullpc

sa1_code:

; Ability / Free Movement Input Handling
; A + L/R      = Common abilities
; A + L + R    = Cycle abilities
; Y + L + R    = Toggle free movement

LDA !p1controller_hold

BIT #$0080                      ; A held
BEQ .free_move_toggle_check

AND #$0030                      ; L or R held
BEQ .free_move_toggle_check

CMP #$0030                      ; Both L + R
BEQ .cycle_abilities

JSR common_abilities
BRA .free_move_toggle_check

.cycle_abilities:
    JSR cycle_abilities

.free_move_toggle_check:
    LDA !p1controller_hold
    AND #$0030                  ; L + R held?
    CMP #$0030
    BNE .free_move_check

    LDA !p1controller_frame
    BIT #$4000                  ; Y pressed this frame?
    BEQ .free_move_check

.toggle_free_move:
    SEP #$20

    LDA !toggle_free_move
    BEQ .enable_free_move

; Disable free move
.disable_free_move:
    STZ !toggle_free_move

    LDA #$02
    STA !kirby_invincible

    STZ !intangible_to_items

    REP #$30

    LDA #$80FF                  ; Restore collision routine
    STA !global_jump_pointer

    BRA .free_move_check

; Enable free move
.enable_free_move:
    INC !toggle_free_move
    INC !intangible_to_items

    REP #$30

    LDA #$8BC9                  ; Intangible movement routine
    STA !global_jump_pointer

.free_move_check:
    SEP #$20

    LDA !toggle_free_move
    BEQ .done

    JSR free_movement

.done:
    REP #$30

; RoMK cutscene skip
LDA !p1controller_frame
AND #$1000
ORA !cutscene_loaded    ;(should be #$0000)
ORA !subgame            ;(should be #$0004)
CMP #$1004
BNE +
SEP #$20
LDA !romk_chapter           ;\ Allows for level 2 RoMK music to play if cutscene is skipped      
CMP #$01                    ;| No need to execute this for anything else, so it only runs for Chapter 2
BNE ++                      ;|                             
LDA #$03                    ;|
INC $33C6                   ;|
JSL !finalize_cutscene      ;/
BRA +++
++ INC $33C6
+++
+ REP #$20

        
REP #$30

; Commenting AFK code for the sake of optimization

; Code for dimming screen when player is AFK
;!afk_time_limit = #$1C20

;afk_timer: 
;    LDA !p1controller_hold
;    BNE +   ; Controller isn't being pressed
;
;    ; If the timer isn't greater than the limit, increase it.
;    LDA !afk_timer 
;    CMP !afk_time_limit
;    BCS ++
;    INC !afk_timer  ; increase afk timer each frame 
;    ++ BRA .check_timer

;    ; Code ran for if an input is pressed on this frame
;    + STZ !afk_timer
;    SEP #$30
;    LDA !afk_toggle     ; check if the AFK toggle is already on, if it is, reset screen brightness.
;    CMP #$01
;    BNE .end
;    STZ !afk_toggle 
;    LDA #$0F 
;    STA !screen_brightness
;    BRA .end

;    .check_timer:   ; Code ran for if no inputs are pressed
;        LDA !afk_timer
;        CMP !afk_time_limit   ; Check if the AFK timer is greater than the time set
;        BCC +
;        SEP #$30
;        LDA #$01
;        STA !afk_toggle
;        LDA #$05        ; Lower screen brightness
;        STA !screen_brightness

;    .end:
;        + REP #$30
        

; Do not write any additional code past this ending routine (it won't be ran)

return_to_main_routine:
    REP #$30
    LDA #$3000          ; run code that was replaced by JSR instruction
    RTS



;6B0E
;0E87
;0E9D

;744B - set to 1 so you cant go in cannons

; Runs on every frame where the player has control over Kirby

pushpc

ORG $00C1BC
    JSR every_gameplay_frame

pullpc

every_gameplay_frame:

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
    LDA !wheelie_rider_state    ; don't activate while riding on wheelie or game will crash
    BNE .free_move_check_done

    LDA !is_shooting            ; don't activate while in shmup mode
    BNE .free_move_check_done 

    LDA !p1controller_hold
    AND #$0030                  ; L + R held?
    CMP #$0030
    BNE .free_move_check_done

    LDA !p1controller_frame
    BIT #$4000                  ; Y pressed this frame?
    BEQ .free_move_check_done

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

    BRA .free_move_check_done

; Enable free move
.enable_free_move:
    INC !toggle_free_move
    INC !intangible_to_items

    REP #$30

    LDA #$8BC9                  ; Intangible movement routine
    STA !global_jump_pointer

.free_move_check_done:
    SEP #$20

    LDA !toggle_free_move
    BEQ .done

    JSR free_movement

.done:
    REP #$30
    LDA $30A1
    RTS
        
; Do not write any additional code past this ending routine (it won't be ran)

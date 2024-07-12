; Whenever possible, it is preferred to run code through SA-1 since it is faster than CPU

sa1_code:

; Lives always set to 99
LDA #$0064
STA !lives

; Make file deletion a single menu
LDA !file_delete_menu
CMP #$80F6
BNE +
LDA !game_mode 
CMP #$0000
BNE ++
LDA #$811A
STA !file_delete_menu 
++
+

;Ability code
; If holding L + R, cycle through all abilities
; If not holding, select a commonly used ability
LDA !p1controller_hold
AND #$00B0
CMP #$00B0
BEQ +
JSR common_abilities
BRA ++
+ JSR cycle_abilities
++

; Button combo for quick death
;LDA !p1controller_hold
;AND #$0020
;ORA !p1controller_frame
;CMP #$0060
;BNE +
;STZ !kirby_hp           ; set health to 0
;+

; Run this code if health = 0
LDA !kirby_hp
CMP #$0000              ; check if health is 0
BNE +
LDA #$0001
STA !animation_timer
+

; Instant Helper removal
LDA !p1controller_hold
AND #$00A0      ;L+A held
ORA !wheelie_rider_state
ORA !p1controller_frame
CMP #$20A0      ;Check if Select is pressed and that Kirby is not riding Wheelie 
BNE +
LDA #$8C74      ;\ Assign RAM values for when Helper gets removed by Suppin Beam.
STA $6340       ;| I have no idea how this works, but I'm glad it does :)
LDA #$16AA      ;|
STA $67A2       ;|
LDA #$86C4      ;|
STA $681C       ;/
+

; RoMK chapter select
LDA !subgame
CMP #$0004                  ; if not RoMK, do not run
BNE +
LDA !game_mode
CMP #$0005                  ; only run in subgame menu
BNE ++
LDA !p1controller_repeat
CMP #$0100                  ; if pressing right, increase chapter
BNE +++                     ; if not, check for left press
INC !romk_chapter
BRA ++++
+++ CMP #$0200              ; if pressing left, decrease chapter
BNE +++                     ; if not, leave routine
DEC !romk_chapter
++++ LDA !romk_chapter
STA !romk_chapter_to_be_loaded 
JSL !update_romk_vram       ; jump to game code for updating vram based on chapter value
+++
++
+

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

; MWW World Map code
mww_map:
    SEP #$30
    LDA !subgame
    CMP #$05                            ; check if in MWW
    BNE .merge
    LDA !game_mode
    CMP #$06                            ; check if on world map screen
    BNE .merge
    JSR mww_cycle_planets
    JSR mww_assign_starting_abilities
    JSR mww_toggle_ability_route
    JSR mww_multiply_map_movement_speed
    .merge:
        REP #$30

; Free movement toggle
free_movement_toggle:
    LDA !p1controller_hold
    AND #$0030  ; L + R
    ORA !p1controller_frame
    CMP #$4030  ; Press Y
    BNE .merge

    SEP #$20
    LDA !toggle_free_move
    CMP #$00
    BNE +
    INC !toggle_free_move   ; Toggle off free move 
    LDA #$02
    STA !kirby_invincible   ; Make Kirby no longer invincible
    STZ !intangible_to_items
    REP #$30
    LDA #$80FF      ; Set pointer that runs code which checks for Kirby's collision
    STA !global_jump_pointer
    BRA .merge
    + STZ !toggle_free_move ; Toggle on free move
    INC !intangible_to_items
    REP #$30
    LDA #$8BC9      ; Set pointer that runs code which makes Kirby intangible
    STA !global_jump_pointer

    .merge:
        ; Free move if toggle is set to 1
        SEP #$20
        LDA !toggle_free_move
        CMP #$00
        BNE +
        JSR free_movement
        +
        
REP #$30

; Instant 100% file
LDA !p1controller_hold
AND #$0840              ; holding Up+X
ORA !game_mode          ; check if game is on file select screen
CMP #$0840
BNE +
;LDA !selected_file
;JSL !erase_file    ; erase previous data to ensure checksum is correct
SEP #$30
LDX #$00                ; set default offset
LDA !selected_file
CMP #$00                ; check if first file is selected
BEQ ++
CMP #$01                ; check if second file is selected
BNE +++
LDX #$4F                ; set file 2 offset if selected
BRA ++++
+++ LDX #$9E            ; set file 3 offset if selected
++ 
++++ JSR make_100_file       ; set 100% file data
+ REP #$30

; Code for dimming screen when player is AFK
!afk_time_limit = #$1C20

afk_timer: 
    LDA !p1controller_hold
    BEQ +   ; Controller isn't being pressed

    ; If the timer isn't greater than the limit, increase it.
    LDA !afk_timer 
    CMP !afk_time_limit
    BCS ++
    INC !afk_timer  ; increase afk timer each frame 
    ++ BRA .check_timer

    ; Code ran for if an input is pressed on this frame
    + STZ !afk_timer
    SEP #$30
    LDA !afk_toggle     ; check if the AFK toggle is already on, if it is, reset screen brightness.
    CMP #$01
    BNE .end
    STZ !afk_toggle 
    LDA #$0F 
    STA !screen_brightness
    BRA .end

    .check_timer:   ; Code ran for if no inputs are pressed
        LDA !afk_timer
        CMP !afk_time_limit   ; Check if the AFK timer is greater than the time set
        BCC +
        SEP #$30
        LDA #$01
        STA !afk_toggle
        LDA #$05        ; Lower screen brightness
        STA !screen_brightness

    .end:
        + REP #$30
        

; Do not write any additional code past this ending routine (it won't be ran)

return_to_main_routine:
    LDA #$3000          ; run code that was replaced by JSR instruction
    RTS



;6B0E
;0E87
;0E9D

;744B - set to 1 so you cant go in cannons

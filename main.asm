; Jump to blank ROM space from main routine
ORG !_F+$008A0D
    JSR $F11A

ORG !_F+$00F11A         ; Custom code start

; GCO bosses always defeated 
SEP #$20
LDA !sb_gco_boss_status
AND #%00001111          ;Ensure that GCO bosses always remain active (the half with all 1's) while SB bosses are not affected
STA !sb_gco_boss_status
REP #$20

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

; Run this code if health = 0
LDA !kirby_hp
CMP #$0000              ; check if health is 0
BNE +
LDA !respawn_timer      ; check if Kirby is in the middle of respawning
CMP #$0000
BNE ++
LDA #$0001
STA !animation_timer    ; set animation timer to 1 so fadeout is instant
LDA !ability                    ;\ store Kirby's ability information to other RAM addresses so they can be reloaded
STA !store_ability              ;|
LDA !ability_info1              ;|
STA !store_ability_info1        ;|
LDA !ability_info2              ;|
STA !store_ability_info2        ;|
LDA !ability_info3              ;|
STA !store_ability_info3        ;|
LDA !wheelie_rider_state        ;|
STA !store_wheelie_rider_state  ;/
LDA #$0013 
STA !respawn_timer
INC !kirby_hp             ; increase health so this routine runs a single time only (this approach is not good and needs to be changed ASAP)
INC !lives                ; increase life count so it never goes to 0
++
+

; Button combo for room reset
LDA !p1controller_hold
AND #$4010              ; R+Y held
ORA !p1controller_frame
CMP #$4030              ; L pressed
BNE +
STZ !kirby_hp           ; set health to 0
+

; Restore abilities after death
LDA !respawn_timer
CMP #$0000              ; if timer is 0, do not decrease it
BEQ +
DEC !respawn_timer
+ CMP #$0001            ; if timer is 1, execute the code 
BNE +
LDA !store_ability              ;\ set Kirby's ability back
STA !ability                    ;|
LDA !store_ability_info1        ;|
STA !ability_info1              ;|
LDA !store_ability_info2        ;|
STA !ability_info2              ;|
LDA !store_ability_info3        ;|
STA !ability_info3              ;|
LDA !store_wheelie_rider_state  ;|
STA !wheelie_rider_state        ;/
+

; If timer somehow goes over 13, reset it back to 0. If it goes off randomly during gameplay, the game could potentially crash.
LDA !respawn_timer
CMP #$0013
BCC +
STZ !respawn_timer
+

; Instant Helper removal
LDA !p1controller_hold
AND #$4010      ;R+Y held
ORA !wheelie_rider_state
ORA !p1controller_frame
CMP #$6010      ;Check if Select is pressed and that Kirby is not riding Wheelie 
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
LDA !p1controller_repeat
CMP #$0100                  ; if pressing right, increase chapter
BNE ++                      ; if not, check for left press
INC !romk_chapter
BRA +++
++ CMP #$0200               ; if pressing left, decrease chapter
BNE ++                      ; if not, leave routine
DEC !romk_chapter
+++ LDA !romk_chapter
STA !romk_chapter_to_be_loaded 
JSL !update_romk_vram       ; jump to game code for updating vram based on chapter value
++
+

; Instant 100% file
LDA !p1controller_hold
AND #$0840              ; holding Up+X
ORA !game_mode          ; check if game is on file select screen
CMP #$0840
BNE +
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
++++ JSR make_100_file ; set file data
+ REP #$30




return_to_main_routine:
    LDA #$3000          ; run code that was replaced
    RTS
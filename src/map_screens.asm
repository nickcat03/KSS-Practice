pushpc

; --- DYNA BLADE ---

; No Iron Maam
; BNE -> BRA 
ORG $158139
    db $80

; Move anywhere on Dyna Blade map
; BNE -> BRA (stage 2)
; BMI $XX -> NOP (rest)
;stage1->2
ORG $14FF1B
    db $80
;stage2->3
ORG $14FF78
    NOP #2
;stage3->4
ORG $14FFF4
    NOP #2
;4->dynablade
ORG $158046
    NOP #2
;switch1
ORG $14FF99
    JMP $7FA4
;switch2
ORG $158067
    JMP $8072


; Dyna Blade Movement speed
; All map movement is hardcoded into the ROM, so it needs to be adjusted manually.

; Each pivot point has a hard-coded value, how fast you move and how many frames you move.

!multiplier = 04

; 373D address to read from for dyna blade data
; Read break on addr $0A7D63 SA-1
; 67B6
; 6830

; CA7F49 code for setting addresses for one of several directions you can take
; Instead of writing the specific address, make a pointer table and then jump to another subroutine before the main one and then write the address to A and X?

; Have timer and speed adjust dynamically when holding R:
; (Note, find a place to hijack into that runs once every frame)

; Speed: 6B86
; Timer: 673C

!move_speed_x = $6B87
!move_speed_y = $6C01
!move_duration = $673C

ORG $158111
    JSL adjust_dyna_move_speed
    NOP

pullpc

adjust_dyna_move_speed:
    ; if R held
    LDA !p1controller_hold
    AND #$0010
    CMP #$0010
    BNE .normal_speed

    ; check if Kirby should be moving
    SEP #$30
    LDA !move_duration
    BEQ .merge

    ; Set which byte to write to for the movement speed increase
    LDX #$00
    LDA !move_speed_x
    BNE .apply_movement     ; if move_speed is zero, it will probably be the y speed that needs to be adjusted
    LDX #$7A    ;offset for movement_speed_y

    .apply_movement
        LDA !move_speed_x,X
        BMI +
        LDA #$04
        STA !move_speed_x,X
        BRA .adjust_timer

        + LDA #$FC
        STA !move_speed_x,X
        +

    .adjust_timer
        DEC !move_duration
        DEC !move_duration
        DEC !move_duration

        LDA !move_duration
        BPL .merge      ; make sure move_direction doesn't go below 00
        STZ !move_duration
        BRA .merge
    
    .normal_speed
        SEP #$30
        .adjust_x
            LDA !move_speed_x
            BEQ .adjust_y
            BMI +
            LDA #$01
            STA !move_speed_x
            BRA .adjust_y
            + LDA #$FF
            STA !move_speed_x

        .adjust_y
            LDA !move_speed_y
            BEQ .merge
            BMI +
            LDA #$01
            STA !move_speed_y
            BRA .merge
            + LDA #$FF
            STA !move_speed_y

    .merge
        REP #$30
        LDY $39
        LDA $6F3E,Y
        RTL

; if R held:
; If Speed = 0: .merge
; If Speed = 1: speed = 4
; Elif Speed = FF: speed = FC
; Timer Dec by 3
; .merge


; --- MILKY WAY WISHES ---

pushpc

; Nova always accessible
; Read controller input for Nova enter
ORG $15A672
    NOP #2
; Show Nova visual on map
ORG $159E2E
    NOP #2

; Hijack into a routine that runs once per frame on the MWW map screen
ORG $15A313
    JSL mww_map
    NOP
pullpc

; MWW World Map code
mww_map: 
    PHX

    SEP #$30
    LDA !subgame
    CMP #$05                            ; check if in MWW
    BNE .merge
    LDA !game_mode
    CMP #$06                            ; check if on world map screen
    BNE .merge
    JSR mww_assign_starting_abilities
    JSR mww_multiply_map_movement_speed
    .merge:
        REP #$30
        ; Replace the code that was used for the hijack
        PLX
        LDX $39
        LDA $6EC4,X
        RTL

mww_assign_starting_abilities:

    ; For mww_ability_route:
    ; 00 = Off, 01 = Any%, 02 = Any% Plasma, 03 = 100%

    SEP #$20
    LDA !mww_ability_route
    ; set to zero if it is out of range
    CMP #$04
    BCC +
    STZ !mww_ability_route
    +
    CMP #$00                ; if auto ability select is set to off, don't run
    BEQ .merge
    LDA !mww_current_planet
    CMP #$02                ; Check if planet is Skyhigh, as it is the only planet with no abilities regardless of route taken
    BEQ .skyhigh
    LDA !mww_ability_route
    CMP #$03                ; if set to any%, jump to any% routine. If set to 100%, continue on.
    BNE .find_any_abilities
    
    .find_100_abilities:
        LDX !mww_current_planet ;\
        LDA ability_table_1,X   ;|  apply new abilities for 100%
        STA !abilities_saved_1  ;|
        LDA ability_table_2,X   ;|
        STA !abilities_saved_2  ;|
        LDA ability_table_3,X   ;|
        STA !abilities_saved_3  ;/
        LDA #$02
        STA !number_of_abilities    ; set number of abilities to anything greater than 1 so they can be cycled through menu
        BRA .merge
        
    .find_any_abilities: 
        LDA #%00001000
        STA !abilities_saved_2      ; make it so only Jet is collected in this address
        LDX !mww_current_planet
        LDA ability_table_any,X 
        STA !abilities_saved_1
        LDA ability_amount_any,X 
        STA !number_of_abilities
        LDA !mww_ability_route
        CMP #$02
        BEQ .finalize_any           ; Check if Plasma setting is on. If it is off, remove Plasma if it is toggled.
        LDA !abilities_saved_1
        AND #%01000000              ; Only allow Hammer to be collected
        STA !abilities_saved_1 
        BRA .finalize_any

    .skyhigh: 
        STZ !abilities_saved_1
        STZ !abilities_saved_2
        STZ !number_of_abilities    ; needs to be cleared or else pressing X will softlock

    .finalize_any: 
        STZ !abilities_saved_3      ; no powers in this address should be collected in any%

    .merge:
        RTS

mww_multiply_map_movement_speed:

    REP #$30
    LDA !p1controller_hold
    AND #$0010
    CMP #$0010
    BNE .no_changes

    LDA !p1controller_hold
    AND #$0200  ; Left
    CMP #$0200
    BNE +
    LDA !kirby_x_pos
    CLC
    SBC #$0005
    STA !kirby_x_pos

    + LDA !p1controller_hold
    AND #$0100  ; Right
    CMP #$0100
    BNE + 
    LDA !kirby_x_pos
    CLC
    ADC #$0005
    STA !kirby_x_pos

    + LDA !p1controller_hold
    AND #$0400  ; Down
    CMP #$0400
    BNE + 
    LDA !kirby_y_pos 
    CLC
    ADC #$0005
    STA !kirby_y_pos

    + LDA !p1controller_hold
    AND #$0800  ; Up
    CMP #$0800
    BNE +
    LDA !kirby_y_pos 
    CLC
    SBC #$0005
    STA !kirby_y_pos
    
    .no_changes:
        + RTS


; MWW ability autoselect tables
; Each bit in the following RAM values are responsible for each ability:
;$7B1B:                 $7B1C:                  $7B1D: 
;7 - none?              7 - Wheel               7 - none?
;6 - Hammer             6 - Ninja               6 - none?
;5 - Plasma             5 - Mirror              5 - none?
;4 - Sword              4 - Parasol             4 - Suplex
;3 - Bomb               3 - Jet                 3 - Copy
;2 - Fighter            2 - Ice                 2 - Stone
;1 - Beam               1 - Fire                1 - Wing
;0 - none?              0 - Cutter              0 - Yo-yo 

; Values for each planet: 
; 00 - Floria           05 - Mecheye
; 01 - Hotbeat          06 - Halfmoon 
; 02 - Skyhigh          07 - ???
; 03 - Cavios           08 - Nova
; 04 - Aqualis          09 - Popstar 

; Tables for converting planet number to proper any% order

;mww_planets_rta_order: db $05, $01, $00, $03, $04, $02, $06, $08, $07
;mww_planets_orig_order: db $00, $01, $02, $03, $04, $05, $06, $07, $08

; These tables are explicitly for 100% route.
;                   Floria     Hotbeat    Skyhigh    Cavios     Aqualis    Mecheye    Halfmoon   ???        Nova
ability_table_1: db %01101000, %00000000, %00000000, %00000000, %01101100, %00000000, %01111110, %01101000, %11111111
ability_table_2: db %10001010, %10001000, %00000000, %10001010, %10001111, %10001010, %10011111, %10001010, %11111111
ability_table_3: db %00011111, %00000010, %00000000, %00010010, %00011111, %00010010, %11111111, %00010111, %11111111

; For any%, the only RAM value that needs to be changed is the one with Hammer and Plasma ($7B1B)
;                     Floria     Hotbeat    Skyhigh    Cavios     Aqualis    Mecheye    Halfmoon   ???        Nova
ability_table_any: db %01100000, %00000000, %00000000, %00000000, %01100000, %00000000, %01100000, %01100000, %01100000
ability_amount_any: db $02, $01, $00, $01, $02, $01, $02, $02, $02








; A9D0 object routine
; 8E41 - routine that initializes object data into SRAM

; 623C - does a sprite exist?
; 6436 - sprite frame graphic to use
; 64B6 - order priority (kirby, sun, moon, non-animated planets, animated planets)
; 6536 - sprite frame graphic offset thing 
; 65B0

; CDE590 pointer table of all sprites being used in mww map
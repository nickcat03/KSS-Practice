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

; CA7F49 code for setting addresses for one of several directions you can take

; Have timer and speed adjust dynamically when holding R:
; (Note, find a place to hijack into that runs once every frame)

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
    LDA !screen_brightness              ; to prevent this from running on every single frame
    CMP #$0F
    BEQ .skip_abilities 

    LDX !mww_current_planet
    JSL convert_planet_id
    JSL mww_assign_starting_abilities
    BRA .merge                          ; prevent movement while loading into level

    .skip_abilities
        JSR mww_multiply_map_movement_speed

    .merge:
        REP #$30
        ; Replace the code that was used for the hijack
        PLX
        LDX $39
        LDA $6EC4,X
        RTL

convert_planet_id:
    ; start off with planet ID in X
    SEP #$30

    LDA !mww_ability_route
    CMP #$03
    BNE .anypercent

    .100percent
        LDA mww_planets_100_order,X
        BRA .end

    .anypercent
        LDA mww_planets_any_order,X

    .end
        TAX
        RTL

mww_assign_starting_abilities:

    ; For mww_ability_route:
    ; 00 = Off, 01 = Any%, 02 = Any% Plasma, 03 = 100%

    ; start off with planet number in RTA order in X

    SEP #$30
    LDA !mww_ability_route
    BEQ .merge      ; don't run if 0 - that means it isn't enabled
    
    ; cap planet count at 8
    CPX #$08
    BCC +
    LDX #$08
    +

    CPX #$00        ; erase all abilities if at Skyhigh
    BEQ .skyhigh

    DEX     ; We don't need to save Skyhigh data because it is all blanked out anyway so just start from Hotbeat

    CMP #$03                ; if set to any%, jump to any% routine. If set to 100%, continue on.
    BNE .find_any_abilities
    
    .find_100_abilities:
        LDA ability_table_1,X   ;\  apply new abilities for 100%
        STA !abilities_saved_1  ;|
        LDA ability_table_2,X   ;|
        STA !abilities_saved_2  ;|
        LDA ability_table_3,X   ;|
        STA !abilities_saved_3  ;/
        LDA #$02
        STA !number_of_abilities    ; set number of abilities to anything greater than 1 so they can be cycled through menu
        BRA .merge
        
    .find_any_abilities: 
        ; apply Hammer / Plasma
        LDA ability_table_any,X
        STA !abilities_saved_1

        ; apply Jet
        LDA #%00001000
        STA !abilities_saved_2

        STZ !abilities_saved_3      ; no powers in this address should be collected in any%

        ; apply ability quantity
        LDA ability_amount_any,X
        STA !number_of_abilities

        ; remove Plasma if not taking Plasma route
        LDA !mww_ability_route
        CMP #$02
        BEQ .merge
        
        ..remove_plasma
            ; see if Plasma exists
            LDA !abilities_saved_1
            BIT #%00100000
            BEQ ..done

            ; Apply changes to the ability values
            AND #%11011111
            STA !abilities_saved_1
            DEC !number_of_abilities

        ..done
            BRA .merge

    .skyhigh: 
        STZ !abilities_saved_1
        STZ !abilities_saved_2
        STZ !abilities_saved_3
        STZ !number_of_abilities    ; needs to be cleared or else pressing X will softlock

    .merge:
        RTL

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

mww_planets_any_order: db $05, $01, $00, $03, $04, $02, $06, $08, $07
mww_planets_100_order: db $05, $01, $00, $03, $06, $02, $07, $04, $08
;original order      : db $00, $01, $02, $03, $04, $05, $06, $07, $08
;                         Flor Hot  Sky  Cavi Aqua Mech Half ???  Nova

; These tables are explicitly for 100% route.
;                   Hotbeat    Mecheye    Cavios     ???        Floria     Aqualis    Halfmoon   Nova       
ability_table_1: db %00000000, %00000000, %00100000, %01101000, %01101000, %01101100, %01111110, %11111111
ability_table_2: db %10001000, %10001010, %10001010, %10001010, %10001010, %10001111, %10011111, %11111111
ability_table_3: db %00000010, %00010010, %00010011, %00010111, %00011111, %00011111, %11111111, %11111111

; For any%, the only RAM value that needs to be changed is the one with Hammer and Plasma ($7B1B)
;                     Hotbeat    Mecheye    Cavios     Aqualis    Floria     Halfmoon   Nova       ???
ability_table_any: db %00000000, %00000000, %00100000, %01100000, %01100000, %01100000, %01100000, %01100000
ability_amount_any: db $01, $01, $02, $03, $03, $03, $03, $03








; A9D0 object routine
; 8E41 - routine that initializes object data into SRAM

; 623C - does a sprite exist?
; 6436 - sprite frame graphic to use
; 64B6 - order priority (kirby, sun, moon, non-animated planets, animated planets)
; 6536 - sprite frame graphic offset thing 
; 65B0

; CDE590 pointer table of all sprites being used in mww map
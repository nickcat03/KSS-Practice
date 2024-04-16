mww_cycle_planets: 

    REP #$20
    LDA !p1controller_repeat
    CMP #$0010                  ; if pressing R
    BNE +
    INC !mww_current_planet
    BRA .apply_map_coordinates
    + CMP #$0020                ; if pressing L
    BNE .merge
    DEC !mww_current_planet 

    .apply_map_coordinates:
        LDA !mww_current_planet
        ASL A                       ; Multiply planet number by 2 to find the spot in 16-bit coordinates table.
        TAX                         
        LDA !mww_planet_x_pos,X     ;\ 
        STA !kirby_x_pos            ;| Then assign the coordinates to Kirby.
        LDA !mww_planet_y_pos,X     ;| Using the same coordinates table that the game uses when loading from a continued file.
        STA !kirby_y_pos            ;/

    .merge: 
        RTS


mww_assign_starting_abilities:

    ; For mww_ability_route:
    ; 00 = Off, 01 = Any%, 02 = Any% Plasma, 03 = 100%

    SEP #$20
    LDA !mww_ability_route
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

mww_toggle_ability_route:

    REP #$20
    LDA !p1controller_frame
    CMP #$2000                      ; pressing select
    BNE .merge
    SEP #$20
    LDA !mww_ability_route 
    CMP #$03                        ; if it is set at 100%, set it to Off
    BNE +
    STZ !mww_ability_route 
    BRA .merge
    + INC !mww_ability_route        ; in any other scenario, increase the value

    .merge:
        RTS

mww_multiply_map_movement_speed:

    LDY $39
    LDA $6C62,Y
    ASL
    CLC
    ADC $6B6E,Y 
    STA $6B6E,Y 
    LDA $6CDC,Y 
    ASL
    CLC
    ADC $6BE8,Y 
    STA $6BE8,Y
    RTS 

;#$4000
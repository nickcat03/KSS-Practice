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

; if R held:
; If Speed = 0: .merge
; If Speed = 1: speed = 4
; Elif Speed = FF: speed = FC
; Timer Dec by 3
; .merge


; --- MILKY WAY WISHES ---

; Nova always accessible
; Read controller input for Nova enter
ORG $15A672
    NOP #2
; Show Nova visual on map
ORG $159E2E
    NOP #2

; Hijack into a routine that runs once per frame on the MWW map screen
ORG $159E8C
    JSL mww_map
pullpc

; MWW World Map code
mww_map:
    ;JSL object_shit
    SEP #$30
    LDA !subgame
    CMP #$05                            ; check if in MWW
    BNE .merge
    LDA !game_mode
    CMP #$06                            ; check if on world map screen
    BNE .merge
    JSR mww_assign_starting_abilities
    JSR mww_toggle_ability_route
    JSR mww_multiply_map_movement_speed
    .merge:
        REP #$30
        ; Replace the code that was used for the hijack
        LDA $32C4
        XBA
        RTL

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

object_shit:
    LDX #$0030
    LDA #$0030
    STA $6010
    LDA #$007C
    STA $6018
    JSL $008E41
    LDA #$007C
    STA $606C
    RTL




; A9D0 object routine
; 8E41 - routine that initializes object data into SRAM

; 623C - does a sprite exist?
; 6436 - sprite frame graphic to use
; 64B6 - order priority (kirby, sun, moon, non-animated planets, animated planets)
; 6536 - sprite frame graphic offset thing 
; 65B0




; CDE590 pointer table of all sprites being used in mww map
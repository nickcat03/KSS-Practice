; Save and Restore code
; DMA to VRAM could possibly be replaced with routine at $0087CB which loads tiles from WRAM (at least for autosaving)

!sfx_save_state = #$0C
!sfx_load_state = #$10
!sfx_room_reset = #$28
!sfx_warp_elsewhere = #$48

!temp_stack_pointer_location = $40FFE0
!music_from_savestate = $408FCA     ; current music RAM ($33CA) from the savestate data
!helper_ability_from_savestate = $40D8A1    ; current helper ability RAM ($74A1) from the savestate data
!screen_fade_from_savestate = $40FFFF  ; for saving brightness value upon loading a state

save_state:

    SEP #$30
    LDA !sfx_save_state          ;Sound effect played
    STA !current_sfx
    JSL !play_sfx

    JSR enable_vblank

    REP #$20
    TSC                     ; Transfer stack pointer
    STA !temp_stack_pointer_location

    .mvn_instructions:
        REP #$20

        ; Copy savestate data to expanded SaveRAM

        ; WRAM
        LDX #$0000          ; Copy first portion of WRAM $7E0000-$7E1FFF to $402000-$403FFF
        LDY #$2000
        LDA #$1FFF
        MVN $40,$7E

        ; WRAM 
        LDX #$B400          ; Copy level data(?) in WRAM $7EB400-$7EFFFF to $404000-$408BFF
        LDY #$4000
        LDA #$4BFF
        MVN $40,$7E

        ; Room Reload Data  ; Copy custom room reload data to another block directly next to it
        LDX.w #!room_reload_storage
        LDY.w #!room_reload_storage_state
        LDA #!reload_storage_size
        MVN $40,$40

        ; SA1
        LDX #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $408C00-$4093FF
        LDY #$8C00
        LDA #$07FF
        MVN $40,$00

        ; WRAM
        LDX #$0000          ; Copy current level layout in WRAM $7F0000-$7F1FFF to $409400-$40B3FF
        LDY #$9400
        LDA #$2FFF
        MVN $40,$7F

        ; SAVERAM
        LDX #$0000          ; Copy SaveRAM $400000-$401FFF to $40C400-$40E3FF
        LDY #$C400
        LDA #$1FFF
        MVN $40,$40 

        LDA #$0000          ; Reset
        MVN $00,$00

        .dma_instructions:
        SEP #$20
        LDX #$0000      ; add comments here later as per the restore code
        STX $2116
        LDX #$0000      
        STX $4302       
        LDA #$41        
        STA $4304       
        LDX #$FFFF
        STX $4305       
        LDA #$39        
        STA $4301       
        LDA #$81        
        STA $4300       
        LDA #$01        
        STA $420B
 
    JSR disable_vblank

    LDA #$01
    STA !QSQL_transfer_mode             ; Tell SA-1 to save stack pointer
    LDA #$02
    STA !QSQL_offset

    REP #$30

    STZ !temp_pointer   ; clear address for loading SA-1 stack pointer

    RTS

restore_state: 

    SEP #$30
    LDA !sfx_load_state          ;Sound effect played
    STA !current_sfx
    JSL !play_sfx

    JSR enable_vblank

    REP #$20
    LDA !temp_stack_pointer_location                 ; Restore stack pointer
    TCS

    .restore_music
        SEP #$20
        LDA !music_from_savestate            
        CMP !current_music
        BEQ +
        STA !current_music
        JSL !load_music
        +

    LDA !sound_buffer           ; sometimes sounds do not play if this is not saved
    STA !save_sound_buffer
    LDA !sound_bank_1
    STA !save_sound_bank_1
    REP #$20
    LDA !sound_bank_2     ; make sure sound banks are reloaded if they are different
    STA !save_sound_bank_2

    .restore_helper_graphics
        ; Restore helper graphics from the previous savestate
        SEP #$30
        LDA !is_shooting    ; if in nova shmup, ignore this completely
        BNE .merge

        LDA !helper_ability_from_savestate
        CMP #$FF    ; if there wasn't a helper in the last state don't do anything
        BEQ .merge

        CMP !helper_ability
        BEQ .merge

        REP #$30
        LDX #$0004
        LDY #$0004
        JSL !assign_helper_data

        .merge
            REP #$30

    .restore_ram
        ; Restore savestate from SRAM

        JSR compare_level_data
        
        ; SA1
        LDX #$8C00          ; Copy SA-1 IRAM $003000-$0037FF to $408C00-$4093FF
        LDY #$3000
        LDA #$07FF
        MVN $00,$40

        LDA !screen_fade
        STA !screen_fade_from_savestate

        JSR restore_level_data

        LDA !screen_fade_from_savestate
        STA !screen_fade

        ; WRAM
        LDX #$2000          ; Copy first portion of WRAM $7E0000-$7E1FFF to $402000-$403FFF
        LDY #$0000
        LDA #$1FFF
        MVN $7E,$40

        ; WRAM 
        LDX #$4000          ; Copy level data(?) in WRAM $7EB400-$7EFFFF to $404000-$408BFF
        LDY #$B400
        LDA #$4BFF
        MVN $7E,$40

        ; Room Reload Data  ; Copy custom room reload data to another block directly next to it
        LDX.w #!room_reload_storage_state
        LDY.w #!room_reload_storage
        LDA #!reload_storage_size
        MVN $40,$40

        ; SAVERAM
        LDX #$C400          ; Copy SaveRAM $400000-$401FFF to $40C400-$40E3FF
        LDY #$0000
        LDA #$1FFF
        MVN $40,$40 

        ; WRAM
        LDX #$9400          ; Copy current level layout in WRAM $7F0000-$7F1FFF to $409400-$B3FF
        LDY #$0000
        LDA #$2FFF
        MVN $7F,$40

        LDA #$0000          ; Reset
        MVN $00,$00

        LDA #$FFFF
        STA $3000           ; Set first two bytes in SA-1 to $FFFF so pause menu doesn't glitch out (don't ask why)

        LDA #$0001
        STA $7E04B1         ; Temporary value for DMA writes to the tileset. Clearing so this doesn't make glitchy graphics on load.

        .restore_vram:
        SEP #$20
        LDX #$0000
        STX $2116
        LDX #$0002      ;Source Offset into source bank
        STX $4302       ;Set Source address lower 16-bits
        LDA #$41        ;Source bank
        STA $4304       ;Set Source address upper 8-bits
        LDX #$FFFF      ;# of bytes to copy 
        STX $4305       ;Set DMA transfer size
        LDA #$18        ;$2118 is the destination, so
        STA $4301       ;  set lower 8-bits of destination to $18
        LDA #$01        ;Set DMA transfer mode: auto address increment
        STA $4300       ;  using write mode 1 (meaning write a word to $2118/$2119)
        LDA #$01        ;The registers we've been setting are for channel 0
        STA $420B       ;  so Start DMA transfer on channel 0 (LSB of $420B)

    JSR disable_vblank

    LDA #$02
    STA !QSQL_transfer_mode         ; Tell SA-1 to restore stack pointer
    LDA #$02
    STA !QSQL_offset

    LDA !save_sound_buffer          ; apply previous sound buffer so consecutive sound plays
    STA !sound_buffer
    LDA !save_sound_bank_1
    STA !sound_bank_1
    REP #$30
    LDA !save_sound_bank_2
    STA !sound_bank_2

    STZ !temp_pointer   ; clear address for loading SA-1 stack pointer

    RTS


; Load all of the level data from the previous state
; Routines for loading in level tileset/background/etc:
; $0183CA - background graphics
; $0184DE - consumables (food)
; $018698 - tile data
; $018678 - level tileset

!room_graphics = $0032F6
!room_graphics_state = $408EF6

; using random spots in WRAM for these because they're temporary and we're loading the state anyway
!current_background = $000300
!state_background = $000302
!current_tileset = $000304
!state_tileset = $000306

compare_level_data:
    ; this routine is purely meant for saving values so that later we could see if we actually need to load them in
    ; having these values load in on every state load is redundant and makes loads extremely slow
    ; this verifies that we only load the level graphics if we actually need them

    ; store current room graphics
    SEP #$20
    LDA.w !room_graphics+2
    PHA
    PLB
    REP #$20

    LDA !room_graphics
    TAX

    LDA $001D,X
    STA !current_background

    LDA $001B,X
    STA !current_tileset

    ; store state room graphics
    SEP #$20
    LDA !room_graphics_state+2
    PHA
    PLB
    REP #$20

    LDA !room_graphics_state
    TAX

    LDA $001D,X
    STA !state_background

    LDA $001B,X
    STA !state_tileset

    SEP #$20
    LDA #$00
    PHA
    PLB   ; Set data bank back to zero (this is what the original routine uses)
    REP #$20

    RTS

restore_level_data:
    .prepare_level_restore

        LDA #$8000      ; Prevents an infinite loop when loading background data
        STA !screen_fade

    .reload_consumables
        ; always run, it doesn't waste many cycles and there are some edge cases that are impractical to check for
        ; ironically enough it's probably a good thing this runs because then the state would load too quickly
        JSL load_consumables

    .reload_background
        LDA.w !state_background
        CMP.w !current_background
        BEQ .reload_tileset
        JSL load_background

    .reload_tileset
        LDA.w !state_tileset
        CMP.w !current_tileset
        BEQ .end_level_restore
        JSL load_tileset

    .end_level_restore
        RTS

    pushpc
    ; writing code in bank 01 so that short jumps can be performed in the same bank as the built-in routines
    ORG $01FFE0
        load_consumables:
            JSR $84DE
            RTL
        load_background:
            JSR $83CA
            RTL
        load_tileset:
            JSR $8678
            RTL
    pullpc



; Save stuff such as HP, ability, invincibility timer, RNG, etc.
auto_save_on_room_load:
    SEP #$10
    REP #$20

    ; ability info
    LDA !ability
    STA !store_ability
    LDA !helper_ability
    STA !store_helper_ability
    LDA !wheelie_rider_state
    STA !store_wheelie_rider_state

    ; health
    LDA !kirby_hp 
    STA !store_kirby_hp 
    LDA !helper_hp 
    STA !store_helper_hp 

    ; items
    LDA !lives_collected
    STA !store_lives_collected
    LDA !tomatoes_collected
    STA !store_tomatoes_collected
    LDA !romk_cutscenes_done
    STA !store_romk_cutscenes
    LDA !romk_cutscenes_done+2
    STA !store_romk_cutscenes+2

    ; mww abilities
    LDA !mww_ability_data_1
    STA !store_abilities_1
    LDA !mww_ability_data_2
    STA !store_abilities_2
    LDA !mww_last_ability_selected
    STA !store_last_ability_selected

    ; invincibility status 
    LDA !kirby_invincible
    STA !store_kirby_invincibility_state
    LDA !kirby_invincible_time
    STA !store_kirby_invincibility_timer
    LDA !kirby_speed
    STA !store_kirby_speed
    LDA !kirby_inv_flash
    STA !store_kirby_flashing

    LDA !helper_invincible
    STA !store_helper_invincibility_state
    LDA !helper_invincible_time
    STA !store_helper_invincibility_timer
    LDA !helper_speed
    STA !store_helper_speed
    LDA !helper_inv_flash
    STA !store_helper_flashing
    
    ; audio
    LDA !current_ability_sfx
    STA !store_ability_sfx

    LDA !current_music
    STA !store_music

    LDA !RNG
    STA !store_RNG

    STZ !is_reloading_room
    RTS

; Reload saved values when room is reloaded
restore_on_room_restart:
    SEP #$30

    STZ !toggle_free_move

    .check_wheelie_rider
        LDA !store_wheelie_rider_state
        STA !wheelie_rider_state 
        BEQ .restore_kirby_ability    ; if it equals #$0000 then we don't need to do anything special

        LDA !store_ability
        STA !ability
        STZ $36C8       ; address used for tracking if swimming. needs to be cleared or game will crash
        STZ !helper_ability+1   ; clear this byte so that it isn't #$FF if it is
        LDA #$0D      ; Wheel ability (for Wheelie). Forcing this here because you'd only be riding on Wheelie.
        BRA .reload_helper

    .restore_kirby_ability
        REP #$30
        LDA !store_ability
        CMP !ability
        BEQ +
        JSR quick_select_ability
        + 

    .restore_helper_ability
        LDA !store_helper_ability
        CMP !helper_ability
        BEQ .no_change
        CMP #$FFFF
        BEQ .unload_helper

    .reload_helper
        STZ $7496       ; address used to store helper state, but if it's #$FFFF then the helper ability will reset
        STA !helper_ability
        BRA .skip
    
    .unload_helper
        LDA #$FFFF
        STA !helper_ability
        STA $62C0
        BRA .skip
    
    .no_change
        STZ $7496       ; Reset this to eliminate edge cases where it could be FFFF so that helper respawns

    .skip

    REP #$30

    ; health
    LDA !store_kirby_hp
    STA !kirby_hp
    LDA !store_helper_hp 
    STA !helper_hp

    ; items
    LDA !store_lives_collected
    STA !lives_collected
    LDA !store_tomatoes_collected
    STA !tomatoes_collected
    LDA !store_romk_cutscenes
    STA !romk_cutscenes_done
    LDA !store_romk_cutscenes+2
    STA !romk_cutscenes_done+2

    ; mww abilities
    LDA !store_abilities_1
    STA !mww_ability_data_1
    LDA !store_abilities_2
    STA !mww_ability_data_2
    LDA !store_last_ability_selected
    STA !mww_last_ability_selected

    ; invincibility status 
    LDA !store_kirby_invincibility_state
    STA !kirby_invincible
    LDA !store_kirby_invincibility_timer
    BEQ +
    ; room reload subtracts $5A from this value, so we re-add it here.
    ; if timer value is $00 then don't add anything
    CLC
    ADC #$005A
    + STA !kirby_invincible_time
    LDA !store_kirby_speed
    STA !kirby_speed
    LDA !store_kirby_flashing
    STA !kirby_inv_flash

    LDA !store_helper_invincibility_state
    STA !helper_invincible
    LDA !store_helper_invincibility_timer
    BEQ +
    CLC
    ADC #$005A
    + STA !helper_invincible_time
    LDA !store_helper_speed
    STA !helper_speed
    LDA !store_helper_flashing
    STA !helper_inv_flash
    
    ; audio
    LDA !store_ability_sfx
    STA !current_ability_sfx

    SEP #$20
    REP #$10
    ; don't load new music if it is boss music (the music gets reloaded anyway)
    ; this is only really intended for invincibility candy
    LDA !current_music
    CMP #$05
    BEQ .skip_music_load
    CMP #$06
    BEQ .skip_music_load
    LDA !store_music
    CMP !current_music
    BEQ .skip_music_load
    STA !current_music
    JSL !load_music

    .skip_music_load
    REP #$30

    LDA !store_RNG
    STA !RNG

    ; STZ !is_reloading_room
    RTS

restore_current_room:   

    SEP #$20

    INC !is_reloading_room
    
    LDA !reload_room
    CMP #$00
    BNE .break              ; if already reloading, don't do it again
    LDA !game_mode          ; checking multiple game modes to make sure we are in an actual level
    CMP #$03                ; check if in a normal level
    BEQ .load_room
    CMP #$09                ; check if in Goal Game
    BEQ .load_room
    CMP #$0C                ; check if in The Arena
    BEQ .load_room
    CMP #$0D                ; check if in Dyna Blade Trial Room
    BEQ .load_room
    CMP #$0E                ; check if fighting Iron Ma'am 
    BEQ .load_room
    BRA .break

    .load_room:

        JSR enable_vblank

        SEP #$30
        LDA !subgame
        CMP #$03
        BNE +
        JSR .warp_somewhere_else
        BRA ++
        + 
        LDA !sfx_room_reset
        STA !current_sfx
        JSR .reload_saved_values
        ++

        JSL !play_sfx
        SEP #$20
        INC !reload_room        ; tell game to reload the room
        STZ !screen_fade        ; reset screen fade so it fades back in after respawn
        STZ !screen_brightness  ; turn screen dark

        LDA !replay_cutscene
        CMP #$01                ; check if in first room in level
        BNE .break
        STZ !replay_cutscene    ; replay beginning room cutscene if it exists

        LDA #$20
        STA !QSQL_timer     ; Set amount of frames until next QSQL is allowed

    .break:
        REP #$30
        RTS

    .reload_saved_values:
        ; If holding L, do not reload stored values and instead store new ones
        REP #$30
        LDA !p1controller_hold
        AND #$0020
        CMP #$0020
        BEQ +
        JSR restore_on_room_restart
        BRA ++
        + JSR auto_save_on_room_load
        ++ SEP #$30
        RTS

    .warp_somewhere_else:
        REP #$20
        LDA !p1controller_hold
        AND #$0820
        CMP #$0820
        BNE +
        LDX #$37            ; Fatty Whale
        STX !room_to_respawn_into
        LDA #$003C
        STA !kirby_x_respawn
        LDA #$009C
        STA !kirby_y_respawn
        BRA .finalize_warp
        + LDA !p1controller_hold 
        AND #$0120
        CMP #$0120
        BNE +
        LDX #$36            ; Battle Windows
        STX !room_to_respawn_into
        LDA #$003C
        STA !kirby_x_respawn
        LDA #$009C
        STA !kirby_y_respawn
        BRA .finalize_warp
        + LDA !p1controller_hold 
        AND #$0420
        CMP #$0420
        BNE +
        LDX #$13            ; Old Tower
        STX !room_to_respawn_into
        LDA #$012C
        STA !kirby_x_respawn
        LDA #$0054
        STA !kirby_y_respawn
        BRA .finalize_warp
        + LDA !p1controller_hold 
        AND #$0220
        CMP #$0220
        BNE +
        LDX #$4C            ; Garden
        STX !room_to_respawn_into
        LDA #$00B4
        STA !kirby_x_respawn
        LDA #$0054
        STA !kirby_y_respawn
        BRA .finalize_warp
        + JSR .reload_saved_values
        LDA !sfx_room_reset
        STA !current_sfx
        RTS

    .finalize_warp:
        SEP #$30
        LDA #$02
        STA !replay_cutscene            ; use the "second" respawn coordinates
        STZ !is_reloading_room
        LDA !sfx_warp_elsewhere
        STA !current_sfx
        RTS

enable_vblank:

    SEP #$20

    STZ $4200           ; Disable NMI
    STZ $420C           ; Disable HDMA

    - LDA $4212
    BPL -

    LDA #$80
    STA $2100           ; Force blank
    RTS

disable_vblank:

    SEP #$20

    - LDA $4212
    BPL -

    LDA $4210           ; Clear NMI flag

    LDA #$81
    STA $4200           ; NMI enable
    LDA #$A8 
    STA $4209           ; Set IRQ hblank period so HUD displays correctly
    LDA #$0F 
    STA $2100           ; Exit force blank
    LDA #$0A
    STA !QSQL_timer     ; Set amount of frames until next QSQL is allowed
    RTS

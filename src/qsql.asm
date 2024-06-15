; Save and Restore code
; DMA to VRAM could possibly be replaced with routine at $0087CB which loads tiles from WRAM (at least for autosaving)

!sfx_save_state = #$0C
!sfx_load_state = #$10
!sfx_room_reset = #$28
!sfx_warp_elsewhere = #$48

save_state:

    SEP #$30
    LDA !sfx_save_state          ;Sound effect played
    STA !current_sfx
    JSL !play_sfx

    JSR enable_vblank

    REP #$20
    TSC                     ; Transfer stack pointer
    STA $404800

    .mvn_instructions:
        REP #$20

        LDX #$0000          ; Data copy starts
        LDY #$2000          ; Copy SaveRAM $400000-$401FFF to $402000-$403FFF
        LDA #$1FFF
        MVN $40,$40 

        LDX #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $404000-$4047FF
        LDY #$4000
        LDA #$07FF
        MVN $40,$00
                           
        LDX #$0000          ; This game sucks
        LDY #$0000          ; Copy all of WRAM cuz yolo
        LDA #$FFFF
        MVN $41,$7E

        LDX #$0000
        LDY #$0000
        LDA #$FFFF
        MVN $42,$7F

        LDA #$0000          ; Reset
        MVN $00,$00


    .dma_instructions:
        SEP #$20
        LDX #$0000      ; add comments here later as per the restore code
        STX $2116
        LDX #$0000      
        STX $4302       
        LDA #$43        
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

    RTS

restore_state: 

    SEP #$30
    LDA !sfx_load_state          ;Sound effect played
    STA !current_sfx
    JSL !play_sfx

    JSR enable_vblank

    REP #$20
    LDA $404800                 ; Restore stack pointer
    TCS

    .restore_music
        SEP #$20
        LDA $4043CA             ; music from the savestate
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

    .restore_sram_sa1

        LDX #$2000          ; Data copy starts
        LDY #$0000          ; Copy SaveRAM $400000-$401FFF to $402000-$403FFF
        LDA #$1FFF 
        MVN $40,$40

        LDX #$4000
        LDY #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $404000-$4047FF
        LDA #$07FF
        MVN $00,$40
                            
        LDX #$0000          ; Restore all WRAM
        LDY #$0000         
        LDA #$FFFF
        MVN $7E,$41

        LDX #$0000
        LDY #$0000
        LDA #$FFFF
        MVN $7F,$42

        LDA #$0000          ; Reset
        MVN $00,$00

    .restore_vram:
        SEP #$20
        LDX #$0000
        STX $2116
        LDX #$0002      ;Source Offset into source bank
        STX $4302       ;Set Source address lower 16-bits
        LDA #$43        ;Source bank
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

    RTS

; Save stuff such as HP, ability, invincibility timer, RNG, etc.
auto_save_on_room_load:
    SEP #$10
    REP #$20

    ; ability info
    ;LDX !ability
    ;STX !store_ability
    ;LDA !helper_info1 
    ;STA !store_helper_info1 
    ;LDA !helper_info2
    ;STA !store_helper_info2 
    ;LDA !helper_info3 
    ;STA !store_helper_info3
    ;LDX !wheelie_rider_state
    ;STX !store_wheelie_rider_state

    ; health
    ;LDX !kirby_hp 
    ;STX !store_kirby_hp 
    ;LDX !helper_hp 
    ;STX !store_helper_hp 

    ; mww abilities

    ; invincibility status 
    
    ; miscellaneous
    ;LDA !current_music
    ;STA !store_music
    LDA !RNG
    STA !store_RNG

    STZ !is_reloading_room
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
        JSR .reload_saved_values
        ++

        LDA !sfx_warp_elsewhere          ;Sound effect played
        STA !current_sfx
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
        SEP #$10
        REP #$20
        LDA !store_RNG
        STA !RNG
        SEP #$30
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
        RTS

    .finalize_warp:
        SEP #$30
        LDA #$02
        STA !replay_cutscene            ; use the "second" respawn coordinates
        STZ !is_reloading_room
        LDA !sfx_warp_elsewhere
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

; Code responsible for saving and loading the SA-1 stack pointer

ORG $008C9D             ; After waiting for CPU to finish
    JMP standard      ; Use jump rather than JSR as this will not mess with the stack

;ORG $008A03             ; After waiting for lag frame
;    JMP lag_frame

ORG $00FF00

    lag_frame:
        LDA #$01
        STA !temp_pointer
        BRA +

    standard:
        STZ !temp_pointer 

        + SEP #$20
        LDA !QSQL_transfer_mode     ; mode 01 is save, mode 02 is load
        CMP #$01
        BNE +

        REP #$20
        LDX !QSQL_offset
        TSC                     ; Transfer stack pointer to A
        STA $404800,X           ; Backup stack pointer
        BRA .end
        + CMP #$02

        BNE .end
        LDX !QSQL_offset
        REP #$20
        LDA $404800,X           ; Load stack pointer address into A
        TCS                     ; Restore stack pointer

    .end:
        SEP #$20
        LDA !temp_pointer
        CMP #$01
        BEQ +
        STZ !QSQL_transfer_mode
        REP #$20
        STZ $2209
        JMP $8CA0           ; Jump back to main routine
        + PLA
        PLP 
        JMP $8CCE

; workram $14D0 items collected
; workram $1200 elevators
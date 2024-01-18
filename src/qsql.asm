; Save and Restore code
; DMA to VRAM could possibly be replaced with routine at $0087CB which loads tiles from WRAM (at least for autosaving)

!sfx_save_state = #$0C
!sfx_load_state = #$10
!sfx_room_reset = #$28

save_state:

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
                           
        LDX #$0000          ; Palette data, what enemies spawn, basically the first part of workram (except for the first 100 bytes)
        LDY #$5000          ; Copy WRAM $7F0000-$7F6FFF to $408000-$40EFFF
        LDA #$2FFF
        MVN $40,$7E

        LDX #$B000
        LDY #$0000
        LDA #$4FFF
        MVN $42,$7E

        LDX #$0000          ; Level data. This includes the room layout, tileset, tile graphics, etc.
        LDY #$8000          ; Copy WRAM $7F0000-$7F6FFF to $408000-$40EFFF
        LDA #$6FFF
        MVN $40,$7F

        ;LDX #$0900          ; test copy 
        ;LDY #$8600
        ;LDA #$0FFF
        ;MVN $40,$7E

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

    LDA !sfx_save_state          ;Sound effect played
    JSR play_sound

    REP #$30

    RTS

restore_state: 

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

    ;JSL $00D29E    ; subroutine for loading in SFX?

    .restore_sram_sa1
        REP #$20

        LDX #$2000          ; Data copy starts
        LDY #$0000          ; Copy SaveRAM $400000-$401FFF to $402000-$403FFF
        LDA #$1FFF 
        MVN $40,$40

        LDX #$4000
        LDY #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $404000-$4047FF
        LDA #$07FF
        MVN $00,$40
                            
        LDX #$5000          ; Palette data, what enemies spawn, basically the first part of workram (except for the first 100 bytes)
        LDY #$0000          ; Copy WRAM $7E0100-$7E2FFF to $405000-$407FFF
        LDA #$2FFF
        MVN $7E,$40

        LDX #$0000
        LDY #$B000
        LDA #$4FFF
        MVN $7E,$42

        LDX #$8000          ; Level data. This includes the room layout, tileset, tile graphics, etc.
        LDY #$0000          ; Copy WRAM $7F0000-$7F6FFF to $408000-$40EFFF
        LDA #$6FFF
        MVN $7F,$40

        ;LDX #$8600          ; test copy 
        ;LDY #$0900
        ;LDA #$0FFF
        ;MVN $7E,$40

        LDA #$0000          ; Reset
        MVN $00,$00

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

    LDA !sfx_load_state
    JSR play_sound

    REP #$30

    RTS

; Save stuff such as items collected, Kirby HP, ability, invincibility timer, etc.
auto_save_on_room_load:


restore_current_room:   

    JSR enable_vblank

    SEP #$20
    
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
        LDA !sfx_room_reset
        JSR play_sound
        SEP #$20
        INC !reload_room        ; tell game to reload the room
        STZ !screen_fade        ; reset screen fade so it fades back in after respawn

        LDA !replay_cutscene
        CMP #$01                ; check if in first room in level
        BNE .break
        STZ !replay_cutscene    ; replay beginning room cutscene if it exists

    .break:
        REP #$20
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
    LDA #$0F 
    STA $2100           ; Exit force blank
    LDA #$0A
    STA !QSQL_timer     ; Set amount of frames until next QSQL is allowed
    RTS


;$7E7200-$7E7600 responsible for corkboard graphics overlap (not very important to fix)

; Code responsible for saving and loading the SA-1 stack pointer

ORG !_F+$008C9D
    JMP $FF00               ; Use jump rather than JSR as this will not mess with the stack

ORG !_F+$00FF00
    SEP #$20
    LDA !QSQL_transfer_mode
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
        STZ !QSQL_transfer_mode
        REP #$20
        STZ $2209
        JMP $8CA0           ; Jump back to main routine



; workram $14D0 items collected
; workram $1200 elevators
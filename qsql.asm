; Save and Restore code
save_state:
    JSR enable_vblank

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
                           
        LDX #$0100          ; Palette data, what enemies spawn, basically the first part of workram (except for the first 100 bytes)
        LDY #$5000          ; Copy WRAM $7F0000-$7F6FFF to $408000-$40EFFF
        LDA #$2EFF
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

    RTS

restore_state: 
    JSR enable_vblank

    .restore_music
        SEP #$20
        LDA $4043CA             ; music from the savestate
        CMP !current_music
        BEQ +
        STA !current_music
        JSL !load_music
        +

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
        LDY #$0100          ; Copy WRAM $7E0100-$7E2FFF to $405000-$407FFF
        LDA #$2EFF
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

    RTS

auto_save_on_room_load:
    REP #$20            ; Since we are loading in the new room, only copy Save and SA-1 RAM

    LDX #$0000          ; Data copy starts
    LDY #$2000          ; Copy SaveRAM $400000-$401FFF to $402000-$403FFF
    LDA #$1FFF
    MVN $43,$40 

    LDX #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $404000-$4047FF
    LDY #$4000
    LDA #$07FF
    MVN $43,$00

    LDA #$0000          ; Reset
    MVN $00,$00

    RTS

restore_current_room:

    JSR enable_vblank
    REP #$30

    ;JSL $03A1BE              ; kills helper?? but not really?
    ;JSL $03A071             ; responsible for clearing abilities on death
    ;JSL $009A8E
    ;JSL $009232
    ;JSR $90E9
    ;JSL $009A78
    ;JSL $018698
    ;JSL $018000
    ;JSL $01806E
    ;JSL $01FBCB
    ;JSL $01F6F7    ; RTS at the end 
    ;JSL $01A288
    SEP #$20
    JSR disable_vblank
    RTS

restore_current_room_2:   

    JSR enable_vblank

    REP #$20            ; Restore automatic copy of current room data

    LDX #$2000          ; Data copy starts
    LDY #$0000          ; Copy SaveRAM $400000-$401FFF to $402000-$403FFF
    LDA #$1FFF
    MVN $40,$43 

    LDX #$4000          ; Copy SA-1 IRAM $003000-$0037FF to $404000-$4047FF
    LDY #$3000
    LDA #$07FF
    MVN $00,$43

    LDA #$0000          ; Reset
    MVN $00,$00

    JSR disable_vblank

    RTS

enable_vblank:

    SEP #$20

    LDA #$01

    STZ $4200           ; Disable NMI
    STZ $420C           ; Disable HDMA

    LDA #$00
    TSB $0D9F

    - LDA $4212
    BPL -

    LDA #$80
    STA $2100           ; Force blank
    RTS

disable_vblank:
    - LDA $4212
    BPL -

    LDA $4210           ; Clear NMI flag

    LDA #$81
    STA $4200           ; NMI enable
    LDA #$0F 
    STA $2100           ; Exit force blank
    LDA #$0A
    STA !QSQL_timer     ; Set amount of frames until next QSQL is allowed
    REP #$30
    RTS

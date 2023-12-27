; Jump to blank ROM space from main routine
ORG !_F+$0081B7
    JSR $FE00


ORG !_F+$00FE00        ; Custom code start

REP #$30
check_save_input:
    LDA !p1controller_hold
    CMP #$2010
    BNE check_load_input
    LDA !p1controller_frame
    CMP #$2000              ; R + Select = save state
    BNE check_load_input
    JSR save_state 

check_load_input:
    LDA !p1controller_hold
    CMP #$2020
    BNE vblank_return_to_main_routine
    LDA !p1controller_frame
    CMP #$2000              ; L + Select = load state
    BNE vblank_return_to_main_routine
    JSR restore_state

vblank_return_to_main_routine:
    REP #$30
    LDA #$3000
    RTS


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
                           
        LDX #$0500          ; Copy CGRAM $000500-$0006F0 to $408000-$4081F0
        LDY #$8000          ; CGRAM is mirrored to workram $000500-$0006F0
        LDA #$01F0
        MVN $40,$00

        LDX #$0000          ; Copy level data
        LDY #$8200
        LDA #$1FFF
        MVN $40,$7F

        ;LDX #$0000          ; test copy =
        ;LDY #$8400
        ;LDA #$5FFF
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
                            ; cgram is mirrored to workram $000500-$0006F0
        LDX #$8000          ; Copy CGRAM $000500-$0006F0 to $408000-$4081F0
        LDY #$0500
        LDA #$01F0
        MVN $00,$40

        LDX #$8200          ; Copy level data
        LDY #$0000
        LDA #$1FFF
        MVN $7F,$40

        ;LDX #$8400          ; test copy
        ;LDY #$0000
        ;LDA #$5FFF
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
        LDX #$FFFF      ;# of bytes to copy (16k)
        STX $4305       ;Set DMA transfer size
        LDA #$18        ;$2118 is the destination, so
        STA $4301       ;  set lower 8-bits of destination to $18
        LDA #$01        ;Set DMA transfer mode: auto address increment
        STA $4300       ;  using write mode 1 (meaning write a word to $2118/$2119)
        LDA #$01        ;The registers we've been setting are for channel 0
        STA $420B       ;  so Start DMA transfer on channel 0 (LSB of $420B)

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
    REP #$30
    RTS

; Possible sprite tables (all workram addresses)

; $007A0 - 007FF
; $03600 - something
; $08000 - something
; $17912 - $1836D
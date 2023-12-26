; Jump to blank ROM space from main routine
;ORG !_F+$008430
ORG !_F+$0081B7
;ORG !_F+$008A63
;ORG !_F+$0083BF
;ORG !_F+$0083DD
;ORG !_F+$008307
;ORG !_F+$01EA10
;ORG !_F+$01EA14
;ORG !_F+$008269
    JSR $FE00
;    NOP #2

ORG !_F+$00FE00        ; Custom code start

REP #$30
LDA !p1controller_hold
AND #$2000
ORA !p1controller_frame
CMP #$2020              ; L + Select = save state
BNE +
JSR save_state 
+ LDA !p1controller_hold
AND #$2000
ORA !p1controller_frame
CMP #$2010              ; R + Select = load state
BNE +
JSR restore_state
+ 

vblank_return_to_main_routine:
    REP #$30
    LDA #$3000
    RTS


; Save and Restore code
save_state:
    .enable_vblank: 
        SEP #$20

        STZ $4200           ; NMI disable

        - LDA $4212
        BPL -

        LDA #$80
        STA $2100           ; Force blank

    .save_sram_sa1:
        REP #$20

        LDX #$0000          ; Data copy starts
        LDY #$5000          ; Copy SaveRAM $400000-$401FFF to $405000-$406FFF
        LDA #$1FFF
        MVN $40,$40 
        LDX #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $407000-$4077FF
        LDY #$7000
        LDA #$07FF
        MVN $40,$00

        LDA #$0000          ; Reset
        MVN $00,$00

    .save_vram:
        SEP #$20
        LDX #$0000      ;add comments here later as per the restore code
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

    .disable_vblank:
        - LDA $4212         ; Wait until vblank
        BPL -

        LDA $4210           ; Clear NMI flag

        LDA #$81
        STA $4200           ; NMI enable
        LDA #$0F 
        STA $2100           ; Exit force blank

    REP #$30
    RTS

restore_state: 


    .enable_vblank:
    SEP #$20

    STZ $4200           ; NMI disable

    - LDA $4212         ; Wait until vblank
    BPL -

    LDA #$80
    STA $2100           ; Force blank

    .restore_sram_sa1
        REP #$20

        LDX #$5000          ; Data copy starts
        LDY #$0000          ; Copy SaveRAM $400000-$401FFF to $405000-$406FFF
        LDA #$1FFF 
        MVN $40,$40
        LDX #$7000
        LDY #$3000          ; Copy SA-1 IRAM $003000-$0037FF to $407000-$4077FF
        LDA #$07FF
        MVN $00,$40

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

    .disable_vblank:
        - LDA $4212
        BPL -

        LDA $4210           ; Clear NMI flag

        LDA #$81
        STA $4200           ; NMI enable
        LDA #$0F 
        STA $2100           ; Exit force blank

    REP #$30
    RTS
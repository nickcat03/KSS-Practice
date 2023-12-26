; Jump to blank ROM space from main routine
;ORG !_F+$008430
ORG !_F+$0081B7
    JSR $FE00
;    NOP

ORG !_F+$00FE00        ; Custom code start

REP #$30

; Save State 
LDA !p1controller_hold
AND #$2000
ORA !p1controller_frame
CMP #$2020
BNE +

SEP #$20

STZ $4200           ; NMI disable

- LDA $4212
BPL -

LDA #$80
STA $2100           ; Force blank

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

SEP #$20
LDX #$0000                       ;Get lower 16-bits of source ptr
STX $4302                        ;Set source offset
LDA #$00                         ;Get upper 8-bits of source ptr
STA $4304                        ;Set source bank
LDX #$FFFF                       ;
STX $4305                        ;Set transfer size in bytes
LDX #$0000                       ;Get lower 16-bits of destination ptr
STX $2181                        ;Set WRAM offset
LDA #$41                         ;Get upper 8-bits of dest ptr 
STA $2183                        ;Set WRAM bank (only LSB is significant)
LDA #$80
STA $4301                        ;DMA destination is $2180
STZ $4300                        ;Write mode=0, 1 byte to $2180
LDA #$01                         ;DMA transfer mode=auto increment
STA $420B                        ;Initiate transfer using channel 0


- LDA $4212         ; Wait until vblank
BPL -

LDA $4210           ; Clear NMI flag

LDA #$81
STA $4200           ; NMI enable
LDA #$0F 
STA $2100           ; Exit force blank

REP #$20

+

; Restore State
LDA !p1controller_hold
AND #$2000
ORA !p1controller_frame
CMP #$2010
BNE +

SEP #$20

STZ $4200           ; NMI disable

- LDA $4212        ; Wait until vblank
BPL -

LDA #$80
STA $2100           ; Force blank

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

SEP #$20
STZ $2115
STZ $2116
LDX #$0000      ;Source Offset into source bank
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

- LDA $4212
BPL -

LDA $4210           ; Clear NMI flag

LDA #$81
STA $4200           ; NMI enable
LDA #$0F 
STA $2100           ; Exit force blank

+

; VRAM tileset on screen is from 9000 - 9FFF

vblank_return_to_main_routine:
    REP #$30
    LDA #$3000
    RTS
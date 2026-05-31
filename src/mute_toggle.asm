; Stereo Mono graphic code starts at $CABCAB
; Audio toggle code starts at $00CDD8
; Edit $00D017 so that audio doesn't play when muted

pushpc

; The following locations are writes to the volume address
; The writes are replaced with checks to see if mute is toggled
ORG $00CDFE
    JSR check_if_muted

ORG $00CEE7
    JSR check_if_muted

; volume fade-in and out
ORG $00CE26
    JSR check_if_muted

ORG $00D019
    JSR check_if_muted

; Start code for audio mute toggle
ORG $00CDDC
    JSR mute_toggle

; Code for getting Mute button graphics
ORG $15BCC2
    JML set_button_gfx
    NOP #2

pullpc

mute_toggle:

TAX             ; store accumulator so it can be used again when leaving routine
LDA !corkboard_cursor
CMP #$0A        ; if not highlighting Stereo Mono button, do not run this
BEQ +
TXA
STA !stereo_mono
RTS
+
change_audio_output:                
    LDA !mute_toggle
    CMP #$01                ; if muted
    BEQ .turn_off_mute
    LDA !stereo_mono
    CMP #$01                ; if on mono
    BEQ .turn_on_mute
    INC !stereo_mono        ; if on stereo, change it to mono
    TXA
    RTS
    
    .turn_on_mute
        LDA #$01
        STA !mute_toggle
        STZ !volume
        BRA .finalize_apuio

    .turn_off_mute
        STZ !mute_toggle
        LDA #$FF 
        STA !volume 
        STZ !stereo_mono    ; switch to stereo

    .finalize_apuio
        LDA #$16
        JSL !load_music
        TXA
        RTS

; Run for every time volume is adjusted
check_if_muted:
    STA !temp_pointer
    LDA !mute_toggle
    CMP #$01            ; if muted 
    BEQ +
    LDA !temp_pointer
    STA !volume        ; write value to volume
    BRA .end
    + STZ !volume       ; if game is muted, clear volume

    .end:
        RTS

set_button_gfx:
    SEP #$20
    LDA !mute_toggle
    CMP #$01            ; is set to mute
    BNE .break
    REP #$20
    LDA #off_button_graphics 
    STA $3714           ; set where the gfx table address is 
    STZ $3716           ; bank $00
    JML $CABCE0         ; jump to code which applies the graphics

    .break
        REP #$20        ; Run code that was replaced as the game is not muted
        LDA $33CD 
        AND #$00FF
        JML $CABCC8     ; jump to code which checks for if Stereo or Mono


; Table for "Off" audio button graphics
off_button_graphics: db $B4, $06, $B5, $06, $B6, $06, $B7, $06, $B8, $06, $B9, $06, $BA, $06, $BB, $06, $BC, $06
; Stereo Mono graphic code starts at $CABCAB
; Audio toggle code starts at $00CDD8
; Edit $00D017 so that audio doesn't play when muted

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
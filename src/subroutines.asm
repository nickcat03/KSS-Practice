; Subroutine to make a 100% file. All it does is overwrite the file with data that a 100% file would have. This will also pass checksum.
; Preferably in the future, all of these RAM addresses should be labeled.
make_100_file:
    REP #$20
    LDA #$1557
    STA $7F04,X
    LDA #$0F05
    STA $7F06,X
    LDA #$0005
    STA $7F08,X
    LDA #$007F
    STA $7F0A,X
    LDA #$03FF
    STA $7F0C,X
    LDA #$7FFE
    STA $7F0E,X
    LDA #$1000
    STA $7F10,X
    LDA #$0027
    STA $7F12,X
    LDA #$0001
    STA $7F26,X
    LDA #$FF00
    STA $7F2A,X
    STA $7F4E,X
    LDA #$FFFF 
    STA $7F2C,X
    STA $7F2E,X
    STA $7F30,X
    STA $7F42,X
    LDA #$FF0F
    STA $7F32,X
    LDA #$9676
    STA $7F34,X
    LDA #$0098
    STA $7F36,X
    LDA #$013C
    STA $7F38,X
    LDA #$131F
    STA $7F44,X
    LDA #$0401
    STA $7F46,X
    LDA #$0503
    STA $7F48,X
    LDA #$0102
    STA $7F4A,X
    LDA #$0605
    STA $7F4C,X
    RTS

; Copy of routine at $00D255, except with instructions for editing the stack removed
play_sound:
    CLC
    ADC #$1E            ; this is added due to it being offset for some reason
    STA !current_sfx    ; store sound in queue

    SEP #$30
    CMP #$72
    BCS +
    TAX
    LDA $3096
    LDY $3094
    CPY $00A7
    BEQ ++
    STY $00A7
    EOR #$80
    ++ AND #$80
    STA $3096
    TXA 
    ORA $3096
    STA $2141
    + LDA !volume
    STA $2142
    LDA !stereo_mono
    STA $2143
    REP #$30
    RTS
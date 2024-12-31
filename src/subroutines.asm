; Subroutine to make a 100% file. All it does is overwrite the file with data that a 100% file would have. This will also pass checksum.
; Preferably in the future, all of these RAM addresses should be labeled.

; to do:
; change graphic to show a 100% file
; delete file first, then make it 100% because not doing this will cause file to not pass checksum and will be deleted on reload.
make_100_file:

    ; sfx for making 100 file, this needs to be ran on cpu or else game will freeze
    ;SEP #$30
    ;3E
    ;LDA #$2C
    ;STA !current_sfx
    ;JSL !play_sfx

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

; Code responsible for displaying triple digit numbers in the HUD
display_triple_digit_integer:
    CMP #$03E8  ; check if the number is greater than or equal to 1000, and if it is, set it to 999
    BCC +
    LDA #$03E7
    + LDY #$FFFF
    SEC

    ; hundreds digit
    - INY
    SBC #$0064
    BCS -
    ADC #$0064
    PHA         ; temporarily store calculated number in stack for calculating the rest
    TYA 
    SEP #$20
    ADC #$B5    
    STA $7E0000,X
    REP #$20
    PLA         ; pull the number back to calculate tens and ones digit
    CLC 
    LDY #$FFFF 
    SEC 

    ; tens digit and ones digit
    - INY 
    SBC #$000A 
    BCS -
    ADC #$00C0 
    SEP #$20
    STA $7E0002,X 
    TYA
    CLC 
    ADC #$B6 
    STA $7E0001,X
    REP #$20
    INC $00AF

    .break:
        RTL
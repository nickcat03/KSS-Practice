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
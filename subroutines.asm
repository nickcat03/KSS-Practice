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
    LDA #$0102
    STA $7F4A,X
    LDA #$0605
    STA $7F4C,X
    RTS


quick_select_ability:
    LDY #$0002
    JSL !assign_ability_data
    RTS

    ; old code that was used before using game function:

    ;STZ !temp_pointer           ; use temporary counter to keep track of loop
    ;ASL A               
    ;TAX
    ;LDA ability_pointers,X      ; get start of table for given ability
    ;TAY
    ;LDX #$0000
    ;- LDA write_ability_to,X    ; get address to be written to
    ;TAX                         
    ;LDA $0000,Y                 ; store ability data
    ;STA $0000,X                 ; write to address that ability data correlates to
    ;INY                         ; increase Y to continue through the table of addresses to write
    ;INY
    ;INC !temp_pointer           ; increase counter
    ;INC !temp_pointer
    ;LDA !temp_pointer           
    ;TAX                         ; assign counter to X so it could be used to find the next address to write to
    ;CMP #$0013
    ;BCC -
    ;RTS

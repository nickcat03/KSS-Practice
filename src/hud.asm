; Custom HUD code

; Replace Lives count with RNG 
Display_RNG:
    ORG $01F8A8
        LDA $3743
        AND #$00FF      ; only consider the first two bits
        CMP $00B7
        BEQ .break
        STA $00B7
        LDY #$FFFF
        SEC

        ; hundreds digit
        - INY
        SBC #$0064
        BCS -
        ADC #$0064
        PHA         ; temporarily store calculated number in stack for calculating the rest
        TYA 
        SEP #$20
        ADC #$B5    ; find graphic to use
        STA $7DFFFF,X
        REP #$20
        PLA
        CLC 
        LDY #$FFFF 
        SEC 

        ; tens digit
        - INY 
        SBC #$000A 
        BCS -
        ADC #$00C0 
        SEP #$20
        STA $7E0001,X 
        TYA
        CLC 
        ADC #$B6 
        STA $7E0000,X
        REP #$20
        INC $00AF

        .break:
            RTS
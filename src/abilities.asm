; Ability Quick Select
common_abilities:
    ; Holding R
    ; normal
    LDA !p1controller_hold
    AND #$0090
    ORA !p1controller_frame
    CMP #$2090
    BNE +
    LDA #$00!normal
    JSR quick_select_ability
    +
    ; jet
    LDA !p1controller_hold
    AND #$0090
    ORA !p1controller_frame
    CMP #$0890
    BNE +
    LDA #$00!jet
    JSR quick_select_ability
    +
    ; wheel
    LDA !p1controller_hold
    AND #$0090
    ORA !p1controller_frame
    CMP #$0190
    BNE +
    LDA #$00!wheel
    JSR quick_select_ability
    +
    ; hammer
    LDA !p1controller_hold
    AND #$0090
    ORA !p1controller_frame
    CMP #$0490
    BNE +
    LDA #$00!hammer
    JSR quick_select_ability
    +
    ; plasma
    LDA !p1controller_hold
    AND #$0090
    ORA !p1controller_frame
    CMP #$0290
    BNE +
    LDA #$00!plasma
    JSR quick_select_ability
    +
    ; Holding L
    ; wing
    LDA !p1controller_hold
    AND #$00A0
    ORA !p1controller_frame
    CMP #$08A0
    BNE +
    LDA #$00!wing
    JSR quick_select_ability
    +
    ; stone
    LDA !p1controller_hold
    AND #$00A0
    ORA !p1controller_frame
    CMP #$01A0
    BNE +
    LDA #$00!stone
    JSR quick_select_ability
    +
    ; suplex
    LDA !p1controller_hold
    AND #$00A0
    ORA !p1controller_frame
    CMP #$04A0
    BNE +
    LDA #$00!suplex
    JSR quick_select_ability
    +
    ; cutter
    LDA !p1controller_hold
    AND #$00A0
    ORA !p1controller_frame
    CMP #$02A0
    BNE +
    LDA #$00!cutter
    JSR quick_select_ability
    + RTS

cycle_abilities:
    ; if holding L + R, cycle through all abilities
    LDA !p1controller_hold
    AND #$00B0
    ORA !p1controller_repeat
    CMP #$01B0          ; check if right is pressed
    BNE +
    LDA !ability
    CMP #$00!crash          ; check if ability is at max number
    BNE ++
    STZ !ability        ; set ability to normal to loop back around
    BRA .assign_ability
    ++ CMP #$00!mike
    BNE ++
    LDA #$00!paint          ; check if Sleep is next in the list to skip it
    STA !ability
    BRA .assign_ability
    ++ INC !ability     ; increase ability number 
    BRA .assign_ability
    + CMP #$02B0        ; check if left is pressed
    BNE +
    LDA !ability
    CMP #$00!normal          ; check if ability is at min number (prevent crash)
    BNE ++
    LDA #$00!crash           ; set ability to Crash to loop back around
    STA !ability
    BRA .assign_ability
    ++ CMP #$00!paint        ; check if Sleep is next in the list to skip it
    BNE ++
    LDA #$00!mike
    STA !ability
    BRA .assign_ability
    ++ DEC !ability

    .assign_ability:
        LDA !ability
        JSR quick_select_ability
    + RTS

quick_select_ability:
    LDY #$0002
    JSL !assign_ability_data
    RTS
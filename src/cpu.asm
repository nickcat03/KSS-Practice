pushpc

ORG $01E0A3
    JSL check_cutscene_skip
    NOP
    NOP

pullpc

; RoMK Cutscene Skip
check_cutscene_skip:

    ; check start button
    LDA !p1controller_frame
    AND #$1000
    BEQ .return

    LDA !cutscene_loaded
    BNE .return

    LDA !subgame
    CMP #$0004
    BNE .return

    SEP #$20

    ; skip cutscene
    INC $33C6

    ; check chapter 2 because its music is loaded in differently for some reason
    LDA !romk_chapter
    CMP #$01
    BNE .return

    LDA #$03
    JSL !finalize_cutscene

    .return
        REP #$30
        LDA $30A3
        AND #$0004
        RTL
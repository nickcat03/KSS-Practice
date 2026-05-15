pushpc

; Hijack routine that runs on subgame menus once per frame
ORG $07DCE1
    JSL subgame_menu
    NOP #2

pullpc

subgame_menu:
    ; RoMK chapter select

    LDA !subgame
    CMP #$0004                      ; Only run for RoMK
    BNE .return

    LDA !game_mode
    CMP #$0005                      ; Only run in subgame menu
    BNE .return

    LDA !p1controller_repeat

    CMP #$0100                      ; Right pressed
    BEQ .next_chapter

    CMP #$0200                      ; Left pressed
    BEQ .prev_chapter

    BRA .update

    .next_chapter:
        INC !romk_chapter
        BRA .update

    .prev_chapter:
        DEC !romk_chapter

    .update:
        LDA !romk_chapter
        STA !romk_chapter_to_be_loaded

        ; Update menu VRAM for selected chapter
        JSL !update_romk_vram

    .return:
        LDA $739A
        AND #$00FF
        RTL
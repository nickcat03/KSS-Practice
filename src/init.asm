; called when the SA-1 starts

pushpc

org $00BBCC
  JSL init

pullpc

init:
  LDA #$0000
  STA !custom_menu_enabled
  STA !is_warping

  ; set custom colors to zero if they are in an invalid range
  LDA !toggle_custom_colors
  CMP #$000A
  BCC +
  LDA #$0000
  STA !toggle_custom_colors
  +

  ; decide whether to boot into original title screen or corkboard
  LDA !autoboot_corkboard
  ; check if it is above 2 (most likely on first boot)
  SEP #$20
  CMP #$02
  BCC +
  LDA #$00
  STA !autoboot_corkboard
  +
  STA !game_mode
  REP #$20

  ; code which was replaced
  JSL $0084BE

  ; return
  RTL

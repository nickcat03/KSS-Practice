; called when the SA-1 starts

pushpc

org $00BBCC
  JSL init

pullpc

; game reset long jump in bank $00
check_reset:
  JSR !check_game_reset
  RTL

init:
  LDA #$0000
  STA !custom_menu_enabled

  ; set custom colors to zero if they are in an invalid range
  LDA !toggle_custom_colors
  CMP #$000A
  BCC +
  LDA #$0000
  STA !toggle_custom_colors
  +


  ; code which was replaced
  JSL $0084BE

  ; return
  RTL

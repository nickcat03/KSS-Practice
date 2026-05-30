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

  ; code which was replaced
  JSL $0084BE

  ; return
  RTL

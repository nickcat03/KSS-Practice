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

  ; decide whether to boot into original title screen or corkboard
  LDA !autoboot_corkboard
  ; check if it is above 2 (most likely on first boot)
  CMP #$0002
  BCC +
  LDA #$0000
  STA !autoboot_corkboard
  +
  STA !game_mode

  ; code which was replaced
  JSL $0084BE

  ; return
  RTL

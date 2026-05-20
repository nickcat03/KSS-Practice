; called when the SA-1 starts

pushpc

org $00BBCC
  JSL init
  continue_from_init:

pullpc

init:
  LDA #$0000
  STA !custom_menu_enabled

  ; code which was replaced
  JSL $0084BE
  JML continue_from_init

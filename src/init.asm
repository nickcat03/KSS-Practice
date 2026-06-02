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

  ; set mww ability route to zero if it is in an invalid range
  SEP #$20
  LDA !mww_ability_route
  CMP #$04
  BCC +
  STZ !mww_ability_route
  + 
  REP #$20

  ; set sa-1 adjustment to zero if it is in an invalid range
  LDA !sa1_adjustment
  CMP #$000B
  BCC +
  LDA #$0000
  STA !sa1_adjustment
  +

  ; decide whether to boot into original title screen or corkboard
  LDA !autoboot_corkboard
  ; check if it is above 2 (most likely on first boot)
  SEP #$30
  CMP #$02
  BCC +
  LDA #$00
  STA !autoboot_corkboard
  +
  STA !game_mode

  ; load in file 1 save data if we're autobooting to corkboard
  BEQ .skip_save_load
  LDX #$00
  LDY #$00
  JSL $00EBE8

  ; load corkboard cursor
  LDA $7F06
  AND #$00FF
  CMP #$00FF
  BNE +
  LDA #$0000
  + STA $7A8F

  JSL $CAB827

  .skip_save_load:
  
  REP #$30

  ; code which was replaced
  JSL $0084BE

  ; return
  RTL

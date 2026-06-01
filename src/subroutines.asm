; Code responsible for displaying triple digit numbers in the HUD
display_triple_digit_integer:
    CMP #$03E8  ; check if the number is greater than or equal to 1000, and if it is, set it to 999
    BCC +
    LDA #$03E7
    + LDY #$FFFF
    SEC

    ; hundreds digit
    - INY
    SBC #$0064
    BCS -
    ADC #$0064
    PHA         ; temporarily store calculated number in stack for calculating the rest
    TYA 
    SEP #$20
    ADC #$B5    
    STA $7E0000,X
    REP #$20
    PLA         ; pull the number back to calculate tens and ones digit
    CLC 
    LDY #$FFFF 
    SEC 

    ; tens digit and ones digit
    - INY 
    SBC #$000A 
    BCS -
    ADC #$00C0 
    SEP #$20
    STA $7E0002,X 
    TYA
    CLC 
    ADC #$B6 
    STA $7E0001,X
    REP #$20
    INC $00AF

    .break:
        RTL


; game reset long jump in bank $00
check_reset:
  JSR !check_game_reset
  RTL

check_gamemode_on_change:
  TAX
  LDA !is_warping
  BEQ +

  LDX #$0003

  + STX !game_mode
  RTS

check_gamemode_on_coordinates_load:
  LDA !is_warping
  BNE +

  STZ $332A
  RTS

  + LDA #$0000
  STA !is_warping
  RTS

; screen flashing code
pushpc

ORG $27E42E
  JSR check_white_flash
ORG $27E435
  JSR check_red_flash

ORG $27FF10
  check_white_flash:
    LDA !toggle_screen_flash
    BEQ +
      JMP $E565 ; dim screen
    + JMP $E529 ; flash white

  check_red_flash:
    LDA !toggle_screen_flash
    BEQ +
      JMP $E565 ; dim screen
    + JMP $E547 ; flash red

pullpc
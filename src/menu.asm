; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430
 
struct MenuOffsets $000000
  .Title: skip 2
  .ChoiceCount: skip 2
  .UpMenu: skip 2
  .TextBank: skip 1
endstruct

struct Choices extends MenuOffsets
  .Text: skip 2
  .Code: skip 2
endstruct

!menu_vram = $0040
!menu_row_size = $0020

!menu_mirror = $7FF000

!cursor_sprite = $00E8

!dp_menu = $41
!dp_scratch = $45

!sfx_open = $41
!sfx_select = $32
!sfx_back = $28
!sfx_warp_elsewhere = $48
!sfx_ability = $44

!palette_fg = $0000
!palette_bg = $1576

open_custom_menu:
  LDA #$0001
  STA !custom_menu_enabled

  ; ensure current language <= 1
  LDA !custom_menu_language
  AND #$0001
  STA !custom_menu_language

  ; load fonts
  LDA.w #font_dma_table
  LDX.W #bank(font_dma_table)
  JSL !load_dma_table

  JSR save_registers

  LDA #$0000
  STA $003061 ; set BG mode 0
  STA $003063 ; set BG1 tilemap VRAM address and size

  LDA #$0001 ; disable OAM and all other layers but 1
  STA $003072

  ; set BG tilemap offsets to $3000.w ($6000)
  ; we only use layer 1 but clobbering them all is easier
  LDA #$3333
  STA $003067

  ; disable hdma for fatty whale fight etc
  LDA #$0000
  STA $003092
  STA $00309C
  LDA #$84BB
  STA $00309B

  ; clear layer 1 scroll pos
  LDA #$0000
  STA $003037
  STA $003039
  STA $00303B
  STA $00303D

  ; max brightness
  LDA #$000F
  STA $00305F

  LDA.w #.set_palette
  LDX.w #bank(.set_palette)
  JSL !sa1_executesnes 
  BRA +
  
  .set_palette
    ; palette
    LDA #!palette_bg
    STA $7E0502
    LDA #!palette_fg
    STA $7E0504
    RTL
  +

  ; open main menu
  LDA #menu_main
  STA !custom_menu_pointer
  LDA #$0000
  STA !custom_menu_cursor

  ; play sfx
  SEP #$20
  LDA #!sfx_open
  STA !current_sfx_long
  REP #$20
  JSR play_sound_on_snes

; main loop
custom_menu:
  ; allow for resetting the game while also in this menu
  ; jumps to custom routine in init.asm that lets us jump to the reset game routine from bank $00
  JSL check_reset

  ; setup dp_menu
  LDA !custom_menu_pointer
  STA !dp_menu
  SEP #$20
  LDA.b #bank(menu_main)
  STA !dp_menu+2
  REP #$20

  JSL !update_layers_input

  ; exit on R+Start
  LDA !p1controller_hold
  AND #!btn_r
  BEQ +
    LDA !p1controller_frame
    CMP #!btn_start
    BNE ++
      JMP exit_menu
    ++
  +

  ; cursor movement
  JSR update_cursor

  ; go up a menu
  LDA !p1controller_frame
  CMP #!btn_b
  BNE +
    ; play sfx
    SEP #$20
    LDA #!sfx_back
    STA !current_sfx_long
    REP #$20
    JSR play_sound_on_snes

    ; get next menu pointer
    LDY.w #MenuOffsets.UpMenu
    LDA [!dp_menu], Y

    ; if it's 0000, exit the menu
    BNE ++
      JMP exit_menu
    ++

    ; set menu
    STA !custom_menu_pointer
    LDA #$0000
    STA !custom_menu_cursor
    JMP custom_menu
  +

  ; do the thing
  LDA !p1controller_frame
  AND #!btn_a|!btn_y
  BEQ +
    ; prep sound effect
    SEP #$20
    LDA #!sfx_select
    STA !current_sfx_long
    REP #$20
    ; load the first menu function pointer
    LDA !custom_menu_cursor
    TAX
    LDA.w #MenuOffsets.Choices[0].Code
    CLC
    ADC !custom_menu_pointer
    ; add the offset to get to the right index
    CPX #$0000
    BEQ .done_adding
    .add_loop:
      CLC
      ADC.w #sizeof(MenuOffsets.Choices)
      DEX
      BNE .add_loop
    .done_adding:
    TAX
    JSR ($0000, X)
    JSR play_sound_on_snes
    ; exit if menu is now $0000
    LDA !custom_menu_pointer
    BNE ++
      JMP exit_menu
    ++
    ; restart loop in case menu changed
    JMP custom_menu
  +

  ; switch language on select
  ;LDA !p1controller_frame
  ;CMP #!btn_select
  ;BNE +
  ;  LDA !custom_menu_language
  ;  EOR #$0001
  ;  STA !custom_menu_language
  ;+

  ; build menu on snes cpu
  LDA.w #draw_screen
  LDX.w #bank(draw_screen)
  JSL !sa1_executesnes 

  ; write menu mirror to PPU
  JSR write_mirror

  ; loop
  JMP custom_menu
update_cursor:
  LDA !p1controller_frame
  CMP #!btn_up
  BNE +
    LDA !custom_menu_cursor
    DEC
    CMP #$FFFF
    BNE ++
      ; wrap to end
      LDY.w #MenuOffsets.ChoiceCount
      LDA [!dp_menu], Y
      DEC
    ++
    STA !custom_menu_cursor
  +
  LDA !p1controller_frame
  CMP #!btn_down
  BNE +
  LDA !custom_menu_cursor
  INC
  LDY.w #MenuOffsets.ChoiceCount
  CMP [!dp_menu], Y
  BNE ++
    ; wrap to begin
    LDA #$0000
  ++
  STA !custom_menu_cursor
  +
  RTS

exit_menu:
  LDA #$0000
  STA !custom_menu_enabled
  ; clear controller inputs
  LDA #$0000
  STA !p1controller_frame
  JSL !update_layers_input

  ; restore clobbered VRAM
  LDA.w #restore_dma_table
  LDX.w #bank(restore_dma_table)
  JSL !load_dma_table

  JSR restore_registers
  RTL

draw_screen:
  JSR clear_screen

  ; write header
  LDA #menu_header
  STA !dp_scratch
  SEP #$20
  LDA #bank(menu_header)
  STA !dp_scratch+2
  REP #$20
  LDX #$0001
  LDY #$0001
  JSR draw_string

  ; draw menu title
  LDY.w #MenuOffsets.Title
  LDA [!dp_menu], Y
  STA !dp_scratch
  SEP #$20
  LDY.w #MenuOffsets.TextBank
  LDA [!dp_menu], Y
  STA !dp_scratch+2
  REP #$20
  LDX #$0001
  LDY #$0003
  JSR draw_string

  ; draw menu options
  ; X = iterator, Y = current text index
  LDX #$0000
  LDY.w #MenuOffsets.Choices[0].Text
  PHY
  .choice_print_loop
    PLY

    ; load text of current choice
    LDA [!dp_menu], Y
    PHX
    PHY
    PHA

    ; calculate display Y
    TXA
    ASL A
    ADC #$0005
    TAY

    ; display X is always 3
    LDX #$0003

    PLA
    STA !dp_scratch
    SEP #$20
    PHY
    LDY.w #MenuOffsets.TextBank
    LDA [!dp_menu], Y
    PLY
    STA !dp_scratch+2
    REP #$20
    JSR draw_string
    PLY
    PLX

    ; move Y to next offset
    TYA
    CLC
    ADC.w #sizeof(MenuOffsets.Choices)
    TAY

    ; increase loop counter
    INX

    PHY
    ; check for loop
    TXA
    LDY.w #MenuOffsets.ChoiceCount
    CMP [!dp_menu], Y
  BNE .choice_print_loop
  PLY

  ; draw cursor
  LDA !custom_menu_cursor

  ; starts 2 down
  CLC
  ADC #$0002

  ; y * 128 (moves two lines at a time)
  ASL A
  INC ; on an odd line... just trust ok
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A

  ; second column
  CLC
  ADC #$0002

  ADC #!menu_mirror
  STA !dp_scratch
  ; set bank
  SEP #$20
  LDA.b #bank(!menu_mirror)
  STA !dp_scratch+2
  REP #$20

  LDA #!cursor_sprite
  STA [!dp_scratch]

  RTL


save_registers:
  LDA !dp_scratch
  STA $40F6C2
  LDA !dp_scratch+2
  STA $40F6C4
  LDA !dp_scratch+4
  STA $40F6C6

  LDA !dp_menu
  STA $40F6C8
  LDA !dp_menu+2
  STA $40F6CA

  LDA $003061 ; BG mode
  STA $40F6E0
  LDA $003063 ; BG1 tilemap VRAM address and size
  STA $40F6E2

  ; set BG tilemap offsets
  LDA $003067
  STA $40F6E4

  ; layer 1 scroll pos
  LDA $003037
  STA $40F6E6
  LDA $003039
  STA $40F6E8
  LDA $00303B
  STA $40F6EA
  LDA $00303D
  STA $40F6EC

  ; layer select
  LDA $003072
  STA $40F6EE

  ; brightness and oam flags
  LDA $00305F
  STA $40F6F0

  ; HDMA toggle
  LDA $003092
  STA $40F6F2
  ; order matters here
  LDA $00309C
  STA $40F6F4
  LDA $00309B
  STA $40F6F6

  LDA.w #.backup_palette
  LDX.w #bank(.backup_palette)
  JSL !sa1_executesnes 
  BRA +
  
  .backup_palette
    LDA $7E0502
    STA $40F6F8
    LDA $7E0504
    STA $40F6FA
    RTL
  +
  RTS

play_sound_on_snes:
  LDA.w #.onSNES
  LDX.w #bank(.onSNES)
  JSL !sa1_executesnes 
  BRA +
  .onSNES
    JSL !play_sfx_long
    RTL
  +
  RTS

restore_registers:
  LDA $40F6C2
  STA !dp_scratch
  LDA $40F6C4
  STA !dp_scratch+2
  LDA $40F6C6
  STA !dp_scratch+4

  LDA $40F6C8
  STA !dp_menu
  LDA $40F6CA
  STA !dp_menu+2

  LDA $40F6E0
  STA $003061 ; BG mode
  LDA $40F6E2
  STA $003063 ; BG1 tilemap VRAM address and size

  ; set BG tilemap offsets
  LDA $40F6E4
  STA $003067

  ; layer 1 scroll pos
  LDA $40F6E6
  STA $003037
  LDA $40F6E8
  STA $003050
  LDA $40F6EA
  STA $00303B
  LDA $40F6EC
  STA $00303D

  ; layer select
  LDA $40F6EE
  STA $003072

  ; brightness and oam flags
  LDA $40F6F0
  STA $00305F

  ; HDMA toggle
  LDA $40F6F2
  STA $003092
  ; order matters here
  LDA $40F6F4
  STA $00309C
  LDA $40F6F6
  STA $00309B

  LDA.w #.restore_palette
  LDX.w #bank(.restore_palette)
  JSL !sa1_executesnes 
  BRA +
  
  .restore_palette
    LDA $40F6F8
    STA $7E0502
    LDA $40F6FA
    STA $7E0504
    RTL
  +

  RTS

; string addr (24-bit) in dp_scratch, x in X, y in Y
draw_string:
  CLC

  ; set banks
  PHY
  SEP #$20
  LDA.b #bank(!menu_mirror)
  STA !dp_scratch+5
  REP #$20
  PLY

  ; move up one tile if it's jp because tails are above
  LDA !custom_menu_language
  STA !dp_scratch+3
  ; calculate destination start addr
  INY
  TYA
  SBC !dp_scratch+3
  
  ; y * 64
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  ; add X*2
  STX !dp_scratch+3
  ASL !dp_scratch+3
  ADC !dp_scratch+3
  ADC #!menu_mirror
  STA !dp_scratch+3

  ; load pointer to language string
  LDA !custom_menu_language
  ASL A
  TAY
  LDA [!dp_scratch], Y
  STA !dp_scratch

  LDX #$0001
  SEP #$20
  .loop:
  LDA #$00
  LDA [!dp_scratch]
  ; if the character is 00, skip writing
  CMP #$00
  BEQ .increment
  ; if the character is FF, stop
  CMP #$FF
  BEQ .done
  ; if the character is FE, move down a line and restore X pos
  CMP #$FE
  BNE +
    REP #$20
    LDA #$0040 ; line height
    ADC !dp_scratch+3
    STX !dp_scratch+3
    ASL !dp_scratch+3
    SBC !dp_scratch+3
    STA !dp_scratch+3
    SEP #$20
    BRA .increment
  +
  ; if the character is FD, move up a line
  ; (for drawing eng text in JP mode)
  CMP #$FD
  BNE +
    REP #$20
    LDA !dp_scratch+3
    SBC #$0040 ; line height
    STA !dp_scratch+3
    SEP #$20
    ; counteract below increments
    DEX
    DEC !dp_scratch+3
    DEC !dp_scratch+3
    BRA .increment
  +
  ; clear upper bytes
  REP #$20
  AND #$00FF
  ; write tile
  STA [!dp_scratch+3]
  SEP #$20
  .increment:
  REP #$20
  INC !dp_scratch
  INC !dp_scratch+3
  INC !dp_scratch+3
  INX
  SEP #$20
  BRA .loop

  .done:
  REP #$20
  RTS
  


clear_screen:
  LDA #$0000
  LDX #$800
  -
  STA !menu_mirror, X
  DEX
  DEX
  BNE -
  STA !menu_mirror, X
  
  RTS

write_mirror:
  ; set transfer mode 03
  LDA #$0003
  STA !dma_type

  ; set source and size
  LDA #!menu_mirror
  STA !dma_src
  LDA #$007F
  STA !dma_src_bank
  LDA #$0740
  STA !dma_size

  ; set dest
  LDA #$0000
  STA !dma_dest

  JSL !write_to_dma_buffer
  RTS


; Code for handling room warps

!subgame_long = $0032EA
!room_number_long = $0032F2
!level_long = $0032EE
!cutscene_long = $00332A
!kirby_x_long = $00330C 
!kirby_y_long = $003310

pushpc
ORG $01DF960
  warp_to_level:
    STA !custom_menu_level_table

    SEP #$30

    LDA #$1D
    PHA
    PLB
    
    LDY #$00

    ; current_sfx will be played when this returns
    LDA #!sfx_warp_elsewhere
    STA !current_sfx_long

    ; Start writing level data
    LDA !custom_menu_subgame_warp
    STA !subgame_long

    LDA (!custom_menu_level_table)
    STA !room_number_long

    INY

    LDA (!custom_menu_level_table),Y
    STA !level_long

    REP #$20

    INY

    LDA (!custom_menu_level_table),Y
    STA !cutscene_long

    INY
    INY

    LDA (!custom_menu_level_table),Y
    STA !kirby_x_long

    INY
    INY

    LDA (!custom_menu_level_table),Y
    STA !kirby_y_long

    LDA #$0001
    STA !reload_room_long

    ;LDA #$03
    ;CMP !game_mode 
    ;BEQ +
    ;LDA #$03
    ;STA !game_mode
    ;REP #$20
    ;JSL $00C177
    ;SEP #$20
    ;+

    ; set current menu to $0000 to exit cleanly

    SEP #$30
    
    LDA #$00
    PHA
    PLB

    REP #$30
    LDA #$0000
    STA !custom_menu_pointer
    STA !screen_brightness_long
    STA !screen_fade_long
    RTL

    ; Tables for level warp data
    ; values in parenthesis are 8-bit, rest are 16-bit
    ; (level number, room), cutscene, kirby x, kirby y
    ; ($32EE, $32F2), $332A, $330C, $3310

    ; Dyna Blade
    dyna_boss:            dw $0402, $0001, $0000, $0000

    ; Great Cave Offensive
    gco_fatty_whale:      dw $0037, $0002, $003C, $009C
    gco_windows:          dw $0036, $0002, $003C, $009C
    gco_tower_entrance:   dw $0013, $0002, $012C, $0054
    gco_garden_entrance:  dw $004C, $0002, $00B4, $0054

    ; Revenge of Meta Knight
    romk_combo_cannon:    dw $0305, $0002, $0024, $0084
    romk_reactor:         dw $0505, $0002, $0024, $0084
    romk_metaknight_boss: dw $0602, $0002, $003C, $0084

    ; Milky Way Wishes
    mww_heart_of_nova:    dw $0801, $0001, $0000, $0000
    mww_marx:             dw $0802, $0001, $0000, $0000

pullpc
  

clear_tile:
dw $2000

; DMA tables
; If byte 0 is negative, data is decompressed
; For mode explanations see https://github.com/Ankouno/KSS-disassembly/blob/9863c88e7f987e71bca858cd6a466ea04b5b8339/Bank00.asm#L869
;[mode] [datasize] [addr rev][pg] [addr dest]
font_dma_table:
; Entry 0: Back up existing data in destination to SRAM in free space at E400
; HACK: the first value is duplicated, so we read two extra bytes
db $15, $C2, $12, $00, $E4, $40, $00, $30
; Entry 1: Decompress JP font to VRAM 3000.w ($6000) (same as vanilla)
db $83, $30, $0B, $EE, $50, $E5, $00, $30
; Entry 2: Decompress EN font to VRAM 3600.w
db $83, $C0, $06, $70, $F2, $02, $80, $34
; Entry 3: Back up the area we will use for tilemap data
db $15, $00, $08, $00, $F7, $40, $00, $00
; End of table
db $FF

restore_dma_table:
; Entry 0: Restore data in destination to SRAM in free space at E400
; HACK: the first value from the read previously was duplicated, so we start two bytes late
db $03, $C0, $12, $02, $E4, $40, $00, $30
; Entry 1: Restore beginning of VRAM
; HACK: the first value from the read previously was duplicated, so we start two bytes late
db $03, $FE, $07, $02, $F7, $40, $00, $00
; End of table
db $FF

menu_header:
%text("KSS Practice Hack * 05/29/2026","スパデラ　ハック * ２９/５/２０２６")

option_noop:
  RTS

set_menu_and_cursor:
  STA !custom_menu_pointer
  LDA #$0000
  STA !custom_menu_cursor
  RTS

back_to_main:
  LDA #menu_main
  JSR set_menu_and_cursor
  RTS

back_one:
  ; get next menu pointer
  LDY.w #MenuOffsets.UpMenu
  LDA [!dp_menu], Y
  JSR set_menu_and_cursor
  RTS


menu_main:
  dw .title, $0004, $0000
  db bank(.title)
  dw .opt1, .opt1_code
  dw .opt2, .opt2_code
  dw .opt3, .opt3_code
  dw .opt4, .opt4_code
  .title: %text("Main Menu", "マイン　メンユー")
  .opt1:  %text("Warp Menu", "ワープ　メニュー")
  .opt2:  %text("MWW Abilities", "MWW Abilities")
  .opt3:  %text("Kirby Color", "カービィ の いろ")
  .opt4:  %lang_swap_text("にほんご　メニュー", "English menu")
  .opt1_code:
    LDA #menu_warp
    JSR set_menu_and_cursor
    RTS
  .opt2_code:
    LDA #menu_mww_abilities
    JSR set_menu_and_cursor
    RTS
  .opt3_code:
    LDA #menu_colors
    JSR set_menu_and_cursor
    RTS
  .opt4_code:
    LDA !custom_menu_language
    EOR #$0001
    STA !custom_menu_language
    RTS

menu_warp:
  dw text_warp_title, $0007, menu_main
  db bank(text)
  dw text_spring, .opt1_code
  dw text_dyna, .opt2_code
  dw text_gourmet, .opt3_code
  dw text_gco, .opt4_code
  dw text_romk, .opt5_code
  dw text_mww, .opt6_code
  dw text_back, back_one
  .opt1_code:
    LDA #$0000
    STA !custom_menu_subgame_warp
    LDA #menu_warp_spring
    JSR set_menu_and_cursor
    RTS
  .opt2_code:
    LDA #$0001
    STA !custom_menu_subgame_warp
    LDA #menu_warp_dyna
    JSR set_menu_and_cursor
    RTS
  .opt3_code:
    LDA #$0002
    STA !custom_menu_subgame_warp
    LDA #menu_warp_gourmet
    JSR set_menu_and_cursor
    RTS
  .opt4_code:
    LDA #$0003
    STA !custom_menu_subgame_warp
    LDA #menu_warp_gco
    JSR set_menu_and_cursor
    RTS
  .opt5_code:
    LDA #$0004
    STA !custom_menu_subgame_warp
    LDA #menu_warp_romk
    JSR set_menu_and_cursor
    RTS
  .opt6_code:
    LDA #$0005
    STA !custom_menu_subgame_warp
    LDA #menu_warp_mww
    JSR set_menu_and_cursor
    RTS

menu_warp_spring:
  dw text_spring, $0001, menu_warp
  db bank(text)
  dw text_back, back_one

menu_warp_dyna:
  dw text_dyna, $0002, menu_warp
  db bank(text)
  dw text_warp_dynafight, .opt1_code
  dw text_back, back_one
  .opt1_code:
    LDA.w #dyna_boss
    JSL warp_to_level
    RTS

menu_warp_gourmet:
  dw text_gourmet, $0001, menu_warp
  db bank(text)
  dw text_back, back_one

menu_warp_gco:
  dw text_gco, $0005, menu_warp
  db bank(text)
  dw text_whale, .opt1_code
  dw text_windows, .opt2_code
  dw text_tower, .opt3_code
  dw text_garden, .opt4_code
  dw text_back, back_one
  .opt1_code:
    LDA.w #gco_fatty_whale
    JSL warp_to_level
    RTS
  .opt2_code:
    LDA.w #gco_windows
    JSL warp_to_level
    RTS
  .opt3_code:
    LDA.w #gco_tower_entrance
    JSL warp_to_level
    RTS
  .opt4_code:
    LDA.w #gco_garden_entrance
    JSL warp_to_level
    RTS

menu_warp_romk:
  dw text_romk, $0004, menu_warp
  db bank(text)
  dw text_combo, .opt1_code
  dw text_reactor, .opt2_code
  dw text_meta, .opt3_code
  dw text_back, back_one
  .opt1_code:
    LDA.w #romk_combo_cannon
    JSL warp_to_level
    RTS
  .opt2_code:
    LDA.w #romk_reactor
    JSL warp_to_level
    RTS
  .opt3_code:
    LDA.w #romk_metaknight_boss
    JSL warp_to_level
    RTS

menu_warp_mww:
  dw text_mww, $0003, menu_warp
  db bank(text)
  dw text_nova, .opt1_code
  dw text_marx, .opt2_code
  dw text_back, back_one
  .opt1_code:
    LDA.w #mww_heart_of_nova
    JSL warp_to_level
    RTS
  .opt2_code:
    LDA.w #mww_marx
    JSL warp_to_level
    RTS

menu_mww_abilities:
  dw text_mww_abilities, $0004, menu_main
  db bank(text)
  dw text_mww_abilities_opt1, .setmwwability_code
  dw text_mww_abilities_opt2, .setmwwability_code
  dw text_mww_abilities_opt3, .setmwwability_code
  dw text_mww_abilities_opt4, .setmwwability_code
  .setmwwability_code
    LDA !custom_menu_cursor
    STA !mww_ability_route

    SEP #$30
    LDA #!sfx_ability
    STA !current_sfx_long
    REP #$30

    LDA #menu_main
    JSR set_menu_and_cursor
    RTS

menu_colors:
  dw text_colors_title, $000B, menu_main
  db bank(text)
  dw text_colors_opt1, .setcolor_code
  dw text_colors_opt2, .setcolor_code
  dw text_colors_opt3, .setcolor_code
  dw text_colors_opt4, .setcolor_code
  dw text_colors_opt5, .setcolor_code
  dw text_colors_opt6, .setcolor_code
  dw text_colors_opt7, .setcolor_code
  dw text_colors_opt8, .setcolor_code
  dw text_colors_opt9, .setcolor_code
  dw text_colors_opta, .setcolor_code
  dw text_back, back_to_main
  .setcolor_code:
    LDA !custom_menu_cursor
    STA !toggle_custom_colors

    SEP #$30
    LDA #!sfx_ability
    STA !current_sfx_long
    REP #$30

    LDA #menu_main
    JSR set_menu_and_cursor
    RTS


pushpc
org $29F780

text:
  .back: %text("Back", "もどる")

  .spring:  %text("Spring Breeze", "はるかぜとともに")
  .dyna:    %text("Dyna Blade", "ダィナブレィド")
  .gourmet: %text("Gourmet Race", "グルメレース")
  .gco:     %text("Great Cave Offensive", "どうくつだいさくせん")
  .romk:    %text("Revenge of Meta Knight", "メタナイトのぎゃくしゅう")
  .mww:     %text("Milky Way Wishes", "ぎんがにねがいを")

  .nova:    %text("Nova","ノヴァ")
  .marx:    %text("Marx","マルク")
  .whale:   %text("Fatty Whale","ファッティホエール")
  .windows: %text("Battle Windows","バトルウィンドウズ")
  .tower:   %text("Old Tower","こだい　の　とう")
  .garden:  %text("Garden","しんぴ　の　らくえん")

  .combo:   %text("Combo Cannon","にれんしゅほう")
  .reactor: %text("Reactor","リアクター")
  .meta:    %text("Meta Knight","メタナイト")

  .warp
    ..title: %text("Warp Menu", "ワープ　メンユー")
    ..dynafight:  %text("Dyna Boss","ダィナブレィド　と　たたかう")

  .mww_abilities
    ..title: %text("MWW Abilities", "MWW Abilities")
    ..opt1: %text("Off", "Off")
    ..opt2: %text("Any", "Any")
    ..opt3: %text("Any (Plasma)", "Any (Plasma)")
    ..opt4: %text("100", "100")

  .colors
    ..title: %text("Kirby Color", "カービィ　の　いろ")
    ..opt1:  %text("Default", "おまかせ　（スタンダード）")
    ..opt2:  %text("Pink (Always)", "ピンク　（いつも）")
    ..opt3:  %text("Red", "レッド")
    ..opt4:  %text("Yellow", "イエロー")
    ..opt5:  %text("Light blue", "ソーダ")
    ..opt6:  %text("Blue", "ブルー")
    ..opt7:  %text("Sapphire", "サファイア")
    ..opt8:  %text("Purple", "ラベンダー")
    ..opt9:  %text("Brown", "チョコレート")
    ..opta:  %text("Chalk", "モノトーン")

assert pc() <= $29FFFF
pullpc

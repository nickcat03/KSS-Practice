; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430
 
struct MenuOffsets $000000
  .Title: skip 2
  .ChoiceCount: skip 2
  .UpMenu: skip 2
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
  CMP #!btn_a
  BNE +
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
    ; restart loop in case menu changed
    JMP custom_menu
  +

  ; switch language on select
  LDA !p1controller_frame
  CMP #!btn_select
  BNE +
    LDA !custom_menu_language
    EOR #$0001
    STA !custom_menu_language
  +

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
  LDX #$0001
  LDY #$0001
  JSR draw_string

  ; write footer
  LDA #menu_footer
  LDX #$0001
  LDY #$001A
  JSR draw_string

  ; draw menu title
  LDY.w #MenuOffsets.Title
  LDA [!dp_menu], Y
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

; string addr in A, x in X, y in Y
draw_string:
  CLC
  STA !dp_scratch

  ; set banks
  SEP #$20
  LDA.b #bank(menu_header)
  STA !dp_scratch+2
  LDA.b #bank(!menu_mirror)
  STA !dp_scratch+5
  REP #$20

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
%text("KSS Practice Hack * 05/27/2026","スパデラ　ハック * 05/27/2026")
menu_footer:
%lang_swap_text("SEL おせば　にほんご","Press SELECT for English")

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
  dw .title, $0003, $0000
  dw .opt1, .opt1_code
  dw .opt2, option_noop
  dw .opt3, .opt3_code
  dw .opt3, option_noop
  .title: %text("* Main menu *", "マイン　メンユー")
  .opt1:  %text("Warp", "ボースへいこう")
  .opt2:  %text("Set RNG", "らんそうせってい")
  .opt3:  %text("Kirby Color", "カービィのいろ")
  .opt1_code:
    LDA #menu_warp
    JSR set_menu_and_cursor
    RTS
  .opt3_code:
    LDA #menu_colors
    JSR set_menu_and_cursor
    RTS

menu_warp:
  dw .title, $0007, menu_main
  dw .opt1, .opt1_code
  dw .opt2, .opt2_code
  dw .opt3, .opt3_code
  dw .opt4, .opt4_code
  dw .opt5, .opt5_code
  dw .opt6, .opt6_code
  dw .opt7, back_one
  .title: %text("* Warp Menu *", "PLACEHOLDER")
  .opt1:  %text("Spring Breeze", "PLACEHOLDER")
  .opt2:  %text("Dyna Blade", "PLACEHOLDER")
  .opt3:  %text("Gourmet Race", "PLACEHOLDER")
  .opt4:  %text("GCO", "PLACEHOLDER")
  .opt5:  %text("ROMK", "PLACEHOLDER")
  .opt6:  %text("MWW", "PLACEHOLDER")
  .opt7:  %text("Back", "PLACEHOLDER")
  .opt1_code:
    LDA #menu_warp_spring
    JSR set_menu_and_cursor
    RTS
  .opt2_code:
    LDA #menu_warp_dyna
    JSR set_menu_and_cursor
    RTS
  .opt3_code:
    LDA #menu_warp_gourmet
    JSR set_menu_and_cursor
    RTS
  .opt4_code:
    LDA #menu_warp_gco
    JSR set_menu_and_cursor
    RTS
  .opt5_code:
    LDA #menu_warp_romk
    JSR set_menu_and_cursor
    RTS
  .opt6_code:
    LDA #menu_warp_mww
    JSR set_menu_and_cursor
    RTS

menu_warp_spring:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* Spring Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_warp_dyna:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* Dyna Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_warp_gourmet:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* Gourmet Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_warp_gco:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* GCO Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_warp_romk:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* ROMK Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_warp_mww:
  dw .title, $0001, menu_warp
  dw .opt1, back_one
  .title: %text("* MWW Warps *", "PLACEHOLDER")
  .opt1:  %text("Back", "PLACEHOLDER")

menu_colors:
  dw .title, $000B, menu_main
  dw .opt1, .setcolor_code
  dw .opt2, .setcolor_code
  dw .opt3, .setcolor_code
  dw .opt4, .setcolor_code
  dw .opt5, .setcolor_code
  dw .opt6, .setcolor_code
  dw .opt7, .setcolor_code
  dw .opt8, .setcolor_code
  dw .opt9, .setcolor_code
  dw .opt10, .setcolor_code
  dw .opt11, back_to_main
  .title: %text("* Kirby Color *", "PLACEHOLDER")
  .opt1:  %text("Default", "PLACEHOLDER")
  .opt2:  %text("Pink (Always)", "PLACEHOLDER")
  .opt3:  %text("Red", "PLACEHOLDER")
  .opt4:  %text("Yellow", "PLACEHOLDER")
  .opt5:  %text("Light blue", "PLACEHOLDER")
  .opt6:  %text("Blue", "PLACEHOLDER")
  .opt7:  %text("Sapphire", "PLACEHOLDER")
  .opt8:  %text("Purple", "PLACEHOLDER")
  .opt9:  %text("Brown", "PLACEHOLDER")
  .opt10:  %text("Chalk", "PLACEHOLDER")
  .opt11:  %text("Back", "PLACEHOLDER")
  .setcolor_code:
    LDA !custom_menu_cursor
    STA !toggle_custom_colors
    LDA #menu_main
    JSR set_menu_and_cursor
    RTS



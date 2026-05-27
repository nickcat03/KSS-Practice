; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430

!menu_vram = $0000
!menu_row_size = $0020

!cursor = $1000
!current_menu = $1002
!current_menu_option_count = $1004

open_custom_menu:
  LDA #$0001
  STA !custom_menu_enabled

  ; load fonts
  LDA #font_dma_table
  LDX #bank(font_dma_table)
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

  ; clear layer 1 scroll pos
  LDA #$0000
  STA $003037
  STA $003039
  STA $00303B
  STA $00303D

  ; max brightness
  LDA #$000F
  STA $00305F

  ; draw the main menu
  LDA #main_menu
  LDX #bank(main_menu)
  JSR draw_menu

; main loop
custom_menu:
  JSL !update_layers_input

  ; exit on R+Start
  LDA !p1controller_hold
  AND #!btn_r
  BEQ +
  LDA !p1controller_frame
  CMP #!btn_start
  BEQ exit_menu
  +

  ; loop
  BRA custom_menu

exit_menu:
  LDA #$0000
  STA !custom_menu_enabled
  ; clear controller inputs
  LDA #$0000
  STA !p1controller_frame
  JSL !update_layers_input

  ; restore clobbered VRAM
  LDA #restore_dma_table
  LDX #bank(restore_dma_table)
  JSL !load_dma_table

  JSR restore_registers

  RTL

save_registers:
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

  RTS

restore_registers:
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

  RTS

; draw menu in A
draw_menu:
  PHA
  ; set transfer mode 03
  LDA #$0003
  STA !dma_type

  PLA
  ; set source and size
  STA !dma_src
  TXA
  STA !dma_src_bank
  ; menu size - 70
  LDA #$0380
  STA !dma_size

  ; set dest
  LDA #!menu_vram
  STA !dma_dest

  JSL !write_to_dma_buffer
  RTS

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
db $83, $C0, $06, $70, $F2, $02, $00, $36
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
db $03, $00, $08, $02, $F7, $40, $00, $00
; End of table
db $FF

; Menus!
; Menu format:
; 2 bytes - title L1
; 2 bytes - title L2
; options:
;   2 bytes - text L1 ( break if $0000 )
;   2 bytes - text L2
;   2 bytes - option function pointer

main_menu:
%en("       Main Menu 1      ")
%en("  The quick brown fox   ")
%en("jumped over the lazy dog")
%en("  THE QUICK BROWN FOX   ")
%en("JUMPED OVER THE LAZY DOG")
%en("       Main Menu 6      ")
%en("       Main Menu 7      ")

menu_end: ; asar needs a label after each db to use datasize()


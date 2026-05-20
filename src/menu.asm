; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430

!menu_vram = $2CA4
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

  ; set BG mode 0
  LDA #$0000
  STA $003061

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

  RTL

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

; borked code
;                 ; save current menu
;                 STA !current_menu
; 
;                 ; write menu title lines
;                 LDY #$0000
;                 ; use y to write 0 to option count
;                 STY !current_menu_option_count
;                 JSR write_texts
; 
;                 ; load first option
;                 LDY #$0002
; 
;                 .next_option:
;                 LDA ($00), Y
;                 CMP #$0000
;                 BEQ .done
;                 
;                 INC !current_menu_option_count
;                 PHA
;                 JSR write_texts
;                 PLA
; 
;                 INY
;                 INY
;                 INY
; 
;                 BRA .next_option
; 
;                 .done:
;                 RTS
             
; write text in A, A+2 on lines Y and Y+1
; write_texts:
;                 PHA
;                 PHY
;                 LDX #$0000
;                 JSR write_text
;                 PLY
;                 INY
;                 PLA
;                 INC
;                 INC
;                 JSR write_text
;                 RTS

; write text in A (bank X) on line Y
; write_text:
;                 ; set transfer mode 03
;                 PHA
;                 LDA #$0003
;                 STA !dma_type
; 
;                 ; set source and size
;                 PLA
;                 STA !dma_src
;                 TXA
;                 STA !dma_src_bank
;                 LDA #datasize(menu_line_blank)
;                 STA !dma_size
; 
;                 ; calculate destination from line
;                 LDA #(!menu_vram-!menu_row_size)
;                 -
;                 CLC
;                 ADC #!menu_row_size
;                 DEY
;                 BPL -
;                 STA !dma_dest
; 
;                 JSL !write_to_dma_buffer
;                 RTS

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
; End of table
db $FF

restore_dma_table:
; Entry 0: Restore data in destination to SRAM in free space at E400
; HACK: the first value from the read previously was duplicated, so we start two bytes late
db $03, $C0, $12, $02, $E4, $40, $00, $30
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


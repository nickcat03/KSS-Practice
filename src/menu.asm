; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430

; Use English text for pause menus
pushpc
org $1FB438
    db $70, $F2, $02

; hijack the 'normal mode' pause menu update loop with ours
org $1F9DE1
JSL menu
RTS
pullpc

!menu_vram = $2CA4
!menu_row_size = $20

menu:
; draw pause text
JSL !load_font

; can comment this out to prevent default ability desc from being drawn
; JSL !draw_text 

; draw our own text (thru DMA)
; set transfer mode 03
LDA #$0003
STA !dma_type

; overwrite menu line 1
LDA #menu_line_1
STA !dma_src
LDA #bank(menu_line_1)
STA !dma_src_bank
LDA #datasize(menu_line_1)
STA !dma_size
LDA #!menu_vram
STA !dma_dest
JSL !write_to_dma_buffer

; overwrite menu line 2
LDA #bank(menu_line_2)
STA !dma_src_bank
LDA #menu_line_2
STA !dma_src
LDA #datasize(menu_line_1)
STA !dma_size
LDA #!menu_vram+!menu_row_size
STA !dma_dest
JSL !write_to_dma_buffer
 

; un-dim the screen
LDA #$000f
STA !screen_brightness
JSL !dim_screen

; main loop
-
JSL !pass_frame
LDA !p1controller_frame
CMP #!btn_start
BNE -
RTL

menu_line_1: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00,
                $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00,
                $20, $00, $20, $00, $20, $00, $20, $00, $20

menu_line_2: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $5D, $24, $09,
                $20, $00, $20, $0C, $20, $2C, $20, $31, $20, $1F, $20, $00, $20,
                $13, $20, $1D, $20, $2C, $20, $30, $20, $2F, $20, $00, $20, $00,
                $20, $00, $20, $00, $20, $00, $20, $00, $20

menu_line_blank: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20
menu_end: ; asar needs a label after each db to use datasize()
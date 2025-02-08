; hijack the 'normal mode' pause menu update loop with ours
pushpc
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
                $20, $00, $20, $00, $20, $00, $20, $00, $20, $0F, $20, $0F, $20,
                $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00,
                $20, $00, $20, $00, $20, $00, $20, $00, $20

menu_line_2: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $AC, $24, $AC,
                $24, $00, $20, $53, $20, $50, $20, $7c, $20, $05, $20, $10, $20,
                $01, $20, $0c, $20, $06, $20, $00, $20, $ac, $24, $ac, $24, $00,
                $20, $00, $20, $00, $20, $00, $20, $00, $20

menu_line_blank: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20
menu_end: ; asar needs a label after each db to use datasize()


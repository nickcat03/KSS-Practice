; Character Data (this is compressed data):
; JP ROM: $2550EE
; EN ROM: $285A43
; JP Text Location Pointer: $CFB430

; rom patches
pushpc
; always load the spring breeze pause menu (&border) regardless of current subgame
org $1f98bc
LDA #$0000
org $1f9ca0
LDA #$0000
org $1f98fe
LDA #$0000
org $1f9921
LDA #$0000
org $1f9a8d
LDA #$0000

; hijack the 'normal mode' pause menu update loop with ours
org $1F9DE1
JSL menu
RTS
pullpc

!menu_vram = $2CA4
!menu_row_size = $0020

!cursor = $1000
!current_menu = $1002
!current_menu_option_count = $1004

menu:
; draw pause text
JSL !load_font
; load fonts
LDA #font_dma_table
LDX #bank(font_dma_table)
JSL !load_dma_table

; draw the main menu
LDA main_menu
JSR draw_menu

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

; draw menu in A
draw_menu:
                ; save current menu
                STA !current_menu

                ; write menu title lines
                LDY #$0000
                ; use y to write 0 to option count
                STY !current_menu_option_count
                JSR write_texts

                ; load first option
                LDY #$0002

                .next_option:
                LDA ($00), Y
                CMP #$0000
                BEQ .done
                
                INC !current_menu_option_count
                PHA
                JSR write_texts
                PLA

                INY
                INY
                INY

                BRA .next_option

                .done:
                RTS
             
; write text in A, A+2 on lines Y and Y+1
write_texts:
                PHA
                PHY
                LDX #$0000
                JSR write_text
                PLY
                INY
                PLA
                INC
                INC
                JSR write_text
                RTS

; write text in A (bank X) on line Y
write_text:
                ; set transfer mode 03
                PHA
                LDA #$0003
                STA !dma_type

                ; set source and size
                PLA
                STA !dma_src
                TXA
                STA !dma_src_bank
                LDA #datasize(menu_line_blank)
                STA !dma_size

                ; calculate destination from line
                LDA #(!menu_vram-!menu_row_size)
                -
                CLC
                ADC #!menu_row_size
                DEY
                BPL -
                STA !dma_dest

                JSL !write_to_dma_buffer
                RTS

font_dma_table:
; Entry 1: Decompress JP font to VRAM 3000 (same as vanilla)
db $83, $30, $0B, $EE, $50, $E5, $00, $30
; Entry 2: Decompress EN font to VRAM 3600
db $83, $30, $0B, $70, $F2, $02, $00, $36
; End of table
db $FF

; character mapping
'A' = $20C1
'B' = $20C2
'C' = $20C3
'D' = $20C4
'E' = $20C5
'F' = $20C6
'G' = $20C7
'H' = $20C8
'I' = $20C9
'J' = $20Ca
'K' = $20Cb
'L' = $20Cc
'M' = $20Cd
'N' = $20Ce
'O' = $20Cf
'P' = $20D0
'Q' = $20D1
'R' = $20D2
'S' = $20D3
'T' = $20D4
'U' = $20D5
'V' = $20D6
'W' = $20D7
'X' = $20D8
'Y' = $20D9
'Z' = $20Da
' ' = $2000
'a' = $20Db
'b' = $20Dc
'c' = $20Dd
'd' = $20De
'e' = $20Df
'f' = $20E0
'g' = $20E7
'h' = $20E1
'i' = $20E2
'j' = $20E8
'k' = $20E3
'l' = $20E4
'm' = $20E5
'n' = $20Ee
'o' = $20Ec
'p' = $20Ea
'q' = $20Eb
'r' = $20Ed
's' = $20Ee
't' = $20Ef
'u' = $20F0
'v' = $20F1
'w' = $20F2
'x' = $20F3
'y' = $20F4
'z' = $20F5

; Menus!
; Menu format:
; 2 bytes - title L1
; 2 bytes - title L2
; options:
;   2 bytes - text L1 ( break if $0000 )
;   2 bytes - text L2
;   2 bytes - option function pointer

main_menu: dw .titleL1, .titleL2, .text1L1, .text1L2, .func1, .text2L1, .text2L2, .func2, $0000
.titleL1: dw "      Main Menu       "
.titleL2: dw "                      "
.text1L1: dw " wow this is cool   "
.text1L2: dw "                    "
.text2L1: dw " i am makeing menu  "
.text2L2: dw "                    "

.func1: RTS
.func2: RTS

menu_line_1: dw "       I LOVE AERO      "
menu_line_2: dw "   i love aero a lot    "

menu_line_blank: db $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20,
                    $00, $20, $00, $20, $00, $20, $00, $20, $00, $20, $00, $20
menu_end: ; asar needs a label after each db to use datasize()




; A9D0 object routine
; 8E41 - routine that initializes object data into SRAM

; 623C - does a sprite exist?
; 65B0
; 6436 - sprite frame graphic to use
; 64B6 - order priority (kirby, sun, moon, non-animated planets, animated planets)
; 6536 - sprite frame graphic offset thing 




; CDE590 pointer table of all sprites being used in mww map
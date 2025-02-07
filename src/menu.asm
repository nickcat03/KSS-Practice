; hijack the 'normal mode' pause menu update loop with ours
pushpc
org $1F9DE1
JSL menu
RTS
pullpc

menu:
; un-dim the screen
LDA #$000f
STA !screen_brightness
JSL !dim_screen

; draw pause text
JSL !load_font
JSL !draw_text

-
JSL !pass_frame
LDA !p1controller_frame
CMP #!btn_start
BNE -
RTL

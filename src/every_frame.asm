pushpc
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A51
    JMP sa1_code
pullpc

; This code will run on every single frame on the SA-1

sa1_code:
    ; custom menu code
    ; if the menu is already open, don't check for hotkeys to avoid recursion
    LDA !custom_menu_enabled
    BNE .done

    ; on R+Start, open the custom menu
    LDA !p1controller_hold
    AND #!btn_r
    BEQ +
    LDA !p1controller_frame
    CMP #!btn_start
    BNE +
    JSL open_custom_menu
    +

.done:
    ; run code that was replaced by JMP to here 
    PLY
    PLX
    PLA
    PLP
    RTL

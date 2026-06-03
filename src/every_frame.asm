pushpc
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A51
    JMP sa1_code
pullpc

; This code will run on every single frame on the SA-1

sa1_code:
    ; run artificial cycles
    LDA !sa1_adjustment
    TAX
    LDA sa1_table,X
    INC A
    - DEC A
    BNE -

    ; custom menu code
    ; if the menu is already open, don't check for hotkeys to avoid recursion
    LDA !custom_menu_enabled
    BNE .done

    ; on R+Start, open the custom menu
    LDA !p1controller_hold  ; skip if there is a conflict with reset combo
    AND #$2030              ; checks if L+R+Select are being held
    CMP #$2030
    BEQ +

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

sa1_table:
    dw $0000
    dw $0BC0
    dw $0E10
    dw $1060
    dw $12B0
    dw $1500
    dw $1750
    dw $19A0
    dw $1BF0
    dw $1E40
    dw $2090
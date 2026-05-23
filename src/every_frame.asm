pushpc
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A0D
    JSR sa1_code
pullpc

; This code will run on every single frame on the SA-1

sa1_code:


return_to_main_routine:
    REP #$30
    LDA #$3000          ; run code that was replaced by JSR instruction
    RTS
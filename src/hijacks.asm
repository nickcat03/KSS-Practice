; Code hijacks. These are simply hex writes that jump to custom code from the main routine.
; Jump to SA-1 custom code from main SA-1 routine
ORG $008A0D
    JSR sa1_code

; Jump to NMI custom code from main CPU routine
ORG $0081B7
    JSR nmi_code

; Jump to custom room reload code from room reload routine
ORG $01A743
    NOP
    NOP
    JSL room_reload_code

; Jump to code that checks for custom Kirby kirby colors 
ORG $03D8C0
    JSL kirby_colors
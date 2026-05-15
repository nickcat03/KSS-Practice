pushpc

; --- DYNA BLADE ---

; No Iron Maam
; BNE -> BRA 
ORG $158139
    db $80

; Move anywhere on Dyna Blade map
; BNE -> BRA (stage 2)
; BMI $XX -> NOP (rest)
;stage1->2
ORG $14FF1B
    db $80
;stage2->3
ORG $14FF78
    NOP #2
;stage3->4
ORG $14FFF4
    NOP #2
;4->dynablade
ORG $158046
    NOP #2
;switch1
ORG $14FF99
    JMP $7FA4
;switch2
ORG $158067
    JMP $8072


; Dyna Blade Movement speed
; All map movement is hardcoded into the ROM, so it needs to be adjusted manually.

; Each pivot point has a hard-coded value, how fast you move and how many frames you move.

!multiplier = 04

; Stage 1 -> Stage 2
!addr = $14FD5A
ORG !addr
    db $!multiplier, $02, $2F/!multiplier
ORG !addr+6
    db $00-!multiplier, $02, $1E/!multiplier
ORG !addr+12
    db $!multiplier, $02, $17/!multiplier

;Stage 2 -> Stage 1
!addr = $14FD80
ORG !addr
    db $00-!multiplier, $02, $17/!multiplier+1
ORG !addr+6
    db $!multiplier, $02, $1E/!multiplier+1
ORG !addr+12
    db $00-!multiplier, $02, $24/!multiplier+1


; Stage 2 -> Stage 3
!addr = $14FDA6
ORG !addr
    db $!multiplier, $02, $27/!multiplier+1
ORG !addr+6
    db $!multiplier, $02, $1F/!multiplier

; Stage 3 -> Stage 2
!addr = $14FE12
ORG !addr
    db $00-!multiplier, $02, $1F/!multiplier+1
ORG !addr+6
    db $00-!multiplier, $02, $27/!multiplier


; Stage 3 -> Stage 4
!addr = $14FE32
ORG !addr
    db $!multiplier, $02, $27/!multiplier+1
ORG !addr+6
    db $00-!multiplier, $02, $38/!multiplier
ORG !addr+12
    db $00-!multiplier, $02, $18/!multiplier
ORG !addr+18
    db $00-!multiplier, $02, $15/!multiplier

; Stage 4 -> Stage 3
!addr = $14FE5E
ORG !addr
    db $!multiplier, $02, $15/!multiplier
ORG !addr+6
    db $!multiplier, $02, $18/!multiplier
ORG !addr+12
    db $!multiplier, $02, $38/!multiplier
ORG !addr+18
    db $00-!multiplier, $02, $27/!multiplier


; Stage 4 -> Dyna Blade
!addr = $14FE8A
ORG !addr
    db $!multiplier, $02, $27/!multiplier+1
ORG !addr+6
    db $00-!multiplier, $02, $14/!multiplier

; Dyna Blade -> Stage 4
!addr = $14FEEA
ORG !addr
    db $!multiplier, $02, $14/!multiplier
ORG !addr+6
    db $00-!multiplier, $02, $27/!multiplier


; Stage 2 -> Switch 1
!addr = $14FDC6
ORG !addr
    db $00-!multiplier, $02, $1C/!multiplier
ORG !addr+6
    db $00-!multiplier, $02, $38/!multiplier
ORG !addr+12
    db $00-!multiplier, $02, $12/!multiplier

; Switch 1 -> Stage 2
!addr = $14FDEC
ORG !addr
    db $!multiplier, $02, $12/!multiplier+1
ORG !addr+6
    db $!multiplier, $02, $38/!multiplier
ORG !addr+12
    db $!multiplier, $02, $1C/!multiplier


; Stage 4 -> Switch 2
!addr = $14FEAA
ORG !addr
    db $00-!multiplier, $02, $1C/!multiplier
ORG !addr+6
    db $00-!multiplier, $02, $18/!multiplier

; Switch 2 -> Stage 4
!addr = $14FECA
ORG !addr
    db $!multiplier, $02, $18/!multiplier
ORG !addr+6
    db $!multiplier, $02, $1C/!multiplier

pullpc
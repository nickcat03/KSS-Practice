free_movement:
    REP #$30

    STZ !kirby_invincible   

    LDA !p1controller_hold
    STA $00                  ; temp copy (save cycles)

    LDA $00
    BIT #$0010               ; R held?
    BEQ .speed_ok
    LDA #$0008               ; double movement speed
    BRA .store_speed

.speed_ok:
    LDA #$0005

.store_speed:
    STA $02                  ; movement speed

    LDA $00
    BIT #$0200               ; Left
    BEQ .check_right

    LDA !kirby_x_pos
    SEC
    SBC $02
    STA !kirby_x_pos

.check_right:
    LDA $00
    BIT #$0100               ; Right
    BEQ .check_down

    LDA !kirby_x_pos
    CLC
    ADC $02
    STA !kirby_x_pos

.check_down:
    LDA $00
    BIT #$0400               ; Down
    BEQ .check_up

    LDA !kirby_y_pos
    CLC
    ADC $02
    STA !kirby_y_pos

.check_up:
    LDA $00
    BIT #$0800               ; Up
    BEQ .done

    LDA !kirby_y_pos
    SEC
    SBC $02
    STA !kirby_y_pos

.done:
    RTS
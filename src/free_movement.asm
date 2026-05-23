!move_speed = $02   ; temp address for storing movement speed
!upper_screen_bound = #$FFD0    ; maximum Y height, this goes past #$0000 to account for passing screen boundary

free_movement:
    REP #$30

    STZ !kirby_invincible   

    ; determine movement speed
    LDA !p1controller_hold
    BIT #$0010               ; R held?
    BEQ .speed_ok

    LDA #$0008               ; fast speed
    BRA .store_speed

.speed_ok:
    LDA #$0005               ; normal speed

.store_speed:
    STA !move_speed

    ; Max X for moving right = room_size_x + room_bound_offset_x - $0014
    LDA !room_size_x
    CLC
    ADC !room_bound_offset_x
    SEC
    SBC #$0014
    STA $04

    ; Max Y for moving down = room_size_y + room_bound_offset_y - $0028
    LDA !room_size_y
    CLC
    ADC !room_bound_offset_y
    SEC
    SBC #$0028
    STA $06

.check_left:
    LDA !p1controller_hold
    BIT #$0200
    BEQ .check_right

    LDA !kirby_x_pos
    SEC
    SBC !move_speed

    ; clamp to minimum X
    CMP !room_bound_offset_x
    BCS +

    LDA !room_bound_offset_x
+
    STA !kirby_x_pos

.check_right:
    LDA !p1controller_hold
    BIT #$0100
    BEQ .check_down

    LDA !kirby_x_pos
    CLC
    ADC !move_speed

    CMP $04
    BCC +

    LDA $04
+
    STA !kirby_x_pos

.check_down:
    LDA !p1controller_hold
    BIT #$0400
    BEQ .check_up

    ; check if in screen wrap space from moving up past the screen bounds
    ; this prevents teleporting to the bottom of the screen
    LDA !kirby_y_pos
    CMP !upper_screen_bound
    BCS .wrapped

    LDA !kirby_y_pos
    CLC
    ADC !move_speed

    CMP $06
    BCC +

    LDA $06

+
    STA !kirby_y_pos
    BRA .check_up

.wrapped:
    ; wrapped-space movement
    LDA !kirby_y_pos
    CLC
    ADC !move_speed
    STA !kirby_y_pos

.check_up:
    LDA !p1controller_hold
    BIT #$0800
    BEQ .done

    ; clamp to max height
    LDA !kirby_y_pos
    CMP !upper_screen_bound
    BCS .clamp_up

    ; move up
    SEC
    SBC !move_speed

    ; allow underflowing from #$0000 to #$FFFF
    BCS +

.clamp_up:
    LDA !upper_screen_bound
+
    STA !kirby_y_pos

.done:
    RTS
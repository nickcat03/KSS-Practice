;$7BF0 - $7EEF is free RAM space

; controller registers
!p1controller_hold        = $32C4
!p1controller_frame       = $32D4
!p1controller_repeat      = $32CC

;menus and various selectable items
!selected_file              = $6D56
!game_mode                  = $623E
!subgame                    = $32EA
!romk_chapter               = $7A67
!romk_chapter_to_be_loaded  = $7B25

; status elements (health, lives, etc)
!kirby_hp       = $737C
!helper_hp      = $737E
!lives          = $737A

; various timers
!animation_timer      = $6E4C

; ability information RAM addresses
!ability                = $749E
!ability_info1          = $7496
!ability_info2          = $74A0
!ability_info3          = $74A2
!wheelie_rider_state    = $7568

; blank addresses used for storing ability information
!store_ability              = $7BF0
!store_ability_info1        = $7BF2
!store_ability_info2        = $7BF4
!store_ability_info3        = $7BF6
!store_wheelie_rider_state  = $7BF8
!respawn_timer              = $7BFA
!temp_pointer               = $7BFC

; subroutines
!update_romk_vram           = $07E55D

; useless subroutines that ill keep here anyway cuz theyre nice to have somewhere
!debug_reload_display           = $DBE7


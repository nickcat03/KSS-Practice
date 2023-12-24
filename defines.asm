; $7BF0 - $7EEF is free RAM space
; But for some reason they randomly get FF00 written to them?

; controller registers
!p1controller_hold        = $32C4
!p1controller_frame       = $32D4
!p1controller_repeat      = $32CC

; menus and various selectable items
!selected_file              = $6D56
!timer_for_various_file_select_things   = $6724
!game_mode                  = $7390
!subgame                    = $32EA
!subgame_menu_cursor        = $7B23
!romk_chapter               = $7A67
!romk_chapter_to_be_loaded  = $7B25
!cutscene_loaded            = $33C6
!file_delete_menu           = $679E

;Milky Way Wishes 
!mww_current_planet         = $7A6B
!kirby_x_pos                = $6988
!kirby_y_pos                = $6A02
!abilities_saved_1          = $7B1B
!abilities_saved_2          = $7B1C 
!abilities_saved_3          = $7B1D
!number_of_abilities        = $7B1E

; subgame addresses
!sb_gco_boss_status         = $7AE5

; status elements (health, lives, etc)
!kirby_hp       = $737C
!helper_hp      = $737E
!lives          = $737A
!score          = $7376
!romk_timer     = $73A0

; various timers
!animation_timer      = $6E4C

; abilities
!normal                 = 00
!cutter                 = 01
!beam                   = 02
!yoyo                   = 03
!ninja                  = 04
!wing                   = 05
!fighter                = 06
!jet                    = 07
!sword                  = 08
!fire                   = 09
!stone                  = 0A 
!bomb                   = 0B 
!plasma                 = 0C
!wheel                  = 0D 
!ice                    = 0E 
!mirror                 = 0F
!copy                   = 10
!suplex                 = 11
!hammer                 = 12
!parasol                = 13
!mike                   = 14
!sleep                  = 15
!paint                  = 16
!cook                   = 17
!crash                  = 18

; ability information RAM addresses
!ability                = $749F
!ability_info1          = $7496
!ability_info2          = $74A0
!ability_info3          = $74A2
!wheelie_rider_state    = $7568

; blank addresses used for storing information
!store_ability              = $7B50
!store_ability_info1        = $7B52
!store_ability_info2        = $7B54
!store_ability_info3        = $7B56
!store_wheelie_rider_state  = $7B58
!respawn_timer              = $7B5A
!temp_pointer               = $7B5C
!mww_ability_route          = $7B5E
!mww_planet_rta             = $7B60

; subroutines
!update_romk_vram           = $07E55D
!assign_ability_data        = $029C71
!finalize_cutscene          = $00CF98
!erase_file                 = $00EBD7

;tables 
!mww_planet_x_pos           = $CAA6F5
!mww_planet_y_pos           = $CAA709

; useless subroutines that ill keep here anyway cuz theyre nice to have somewhere
!debug_reload_display           = $DBE7



; Game function stuff (this could probably be called something better)
!max_nmi_load       = $301B
!current_nmi_load   = $301D

; controller registers
!p1controller_hold        = $32C4
!p1controller_frame       = $32D4
!p1controller_repeat      = $32CC
!p1mirror_hold            = $3690
!p1mirror_frame           = $3694
!p1controller_direct      = $4218

; audio
!sound_buffer               = $3096
!sound_bank_1               = $00AA
!sound_bank_2               = $00AB
!current_music              = $33CA
!current_sfx                = $33CB
!volume                     = $33CC
!stereo_mono                = $33CD

; menus and various selectable items
!selected_file              = $6D56
!timer_for_various_file_select_things   = $6724
!game_mode                  = $7390
!subgame                    = $32EA
!corkboard_cursor           = $7A85
!subgame_menu_cursor        = $7B23
!romk_chapter               = $7A67
!romk_chapter_to_be_loaded  = $7B25
!cutscene_loaded            = $33C6
!file_delete_menu           = $679E

;Milky Way Wishes 
!mww_current_planet         = $7A6B
!abilities_saved_1          = $7B1B
!abilities_saved_2          = $7B1C 
!abilities_saved_3          = $7B1D
!number_of_abilities        = $7B1E

; subgame addresses
!sb_gco_boss_status         = $7AE5

; status elements (health, lives, etc)
!kirby_hp           = $737C
!helper_hp          = $737E
!lives              = $737A
!score              = $7376
!romk_timer         = $73A0
!boss_inv_frames    = $78FC
!boss_hp            = $7A19
!boss_max_hp        = $7A1B
!boss_hp_meter      = $7A1D

; coordinates / positions 
!kirby_x_pos                = $6988
!kirby_y_pos                = $6A02
!kirby_x_respawn            = $330C
!kirby_y_respawn            = $3310
!room_to_respawn_into       = $32F2
!camera_lock                = $7368

; various miscellaneous things
!animation_timer        = $6E4C
!reload_room            = $7392
!screen_fade            = $30A1
!screen_brightness      = $305F
!replay_cutscene        = $332A     ; this variable might do more than just handle cutscenes
!move_cam_hud           = $3330    /; these...
!is_paused              = $7368    \; ... two seem to do the same thing?
!RNG                    = $3743
!intangible_to_items    = $744B

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
!helper_info1          = $7496
!helper_info2          = $74A0
!helper_info3          = $74A2
!wheelie_rider_state    = $7568
!kirby_invincible       = $35F1
!kirby_invincible_time  = $35F5
!helper_invincible      = $35F3
!helper_invincible_time = $35F7
!kirby_speed            = $74C8
!helper_speed           = $74CA

; blank addresses used for storing information
!respawn_timer              = $7B5A
!temp_pointer               = $7B5C
!mww_ability_route          = $7B5E
!mww_planet_rta             = $7B60
!QSQL_timer                 = $7B62
!QSQL_transfer_mode         = $7B64
!QSQL_offset                = $7B66
!is_reloading_room          = $7B68
!toggle_free_move           = $7B70
!mute_toggle                = $7B7E
!save_sound_buffer          = $404810
!save_sound_bank_1          = $40481A
!save_sound_bank_2          = $40481B
!afk_timer                  = $7B3E
!afk_toggle                 = $7B3D

; for saving certain values on room reload 
!store_ability                      = $7B40
!store_wheelie_rider_state          = $7B41
!store_kirby_hp                     = $7B42
!store_helper_hp                    = $7B43
!store_helper_info1                 = $7B44
!store_helper_info2                 = $7B46
!store_helper_info3                 = $7B48
!store_abilities1                   = $7B4A
!store_abilities2                   = $7B4B
!store_abilities3                   = $7B4C
!store_number_of_abilities          = $7B4D
!store_kirby_invincibility_timer    = $7B4E
!store_kirby_invincibility_state    = $7B50
!store_helper_invincibility_timer   = $7B51
!store_helper_invincibility_state   = $7B53
!store_music                        = $7B54
!store_kirby_speed                  = $7B55
!store_helper_speed                 = $7B56
!store_RNG                          = $7B58

; subroutines
!reset_game                 = $BCE7
!update_romk_vram           = $07E55D
!assign_ability_data        = $029C71
!finalize_cutscene          = $00CF98
!erase_file                 = $00EBD7
!load_music                 = $00CF98
!update_tileset             = $0087CB
!update_tileset_kirby_pos   = $0085EA
;!update_soundbank           = $00D2F0          ;$00D1D0
!global_jump_pointer        = $633E

;tables 
!mww_planet_x_pos           = $CAA6F5
!mww_planet_y_pos           = $CAA709

; useless subroutines that ill keep here anyway cuz theyre nice to have somewhere
!debug_reload_display       = $DBE7
!play_sfx                   = $D155
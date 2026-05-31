
; Game function stuff (this could probably be called something better)
; These values are used for seeing how many cycles are left to do DMA operations
!max_nmi_load       = $301B
!current_nmi_load   = $3019
!nmi_mirror         = $301D
!active_frames      = $3010 ;(default is 1, if game lags it will be greater)

; controller registers
!p1controller_hold        = $32C4
!p1controller_frame       = $32D4
!p1controller_repeat      = $32CC
!p1mirror_hold            = $3690
!p1mirror_frame           = $3694
!p1controller_direct      = $4218

; audio
!sound_buffer               = $3096
!current_ability_sfx        = $00AA
!sound_bank_1               = $00AA
!sound_bank_2               = $00AB
!current_music              = $33CA
!current_sfx                = $33CB
!current_sfx_long           = $0033CB
!volume                     = $33CC
!stereo_mono                = $33CD

; menus and various selectable items
!selected_file              = $6D56
!timer_for_various_file_select_things   = $6724
!game_mode                  = $7390
!advance_game_mode          = $7392
!subgame                    = $32EA
!room_number                = $32F2
!level_number               = $32EE     ; dyna level, romk chapter, mww planet
!level_number_long          = $0032EE
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
!mww_ability_data_1         = $7B1B
!mww_ability_data_2         = $7B1D
!mww_last_ability_selected  = $36BC

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
!write_to_HUD       = $00AF     ; if set to 1, the HUD will update

; coordinates / positions 
!kirby_x_pos                = $6988
!kirby_y_pos                = $6A02
!kirby_x_respawn            = $330C
!kirby_y_respawn            = $3310
!kirby_x_respawn_long       = $00330C
!kirby_y_respawn_long       = $003310
!room_to_respawn_into       = $32F2
!camera_lock                = $7368
!room_size_x                = $3366
!room_bound_offset_x        = $3364
!room_size_y                = $3362
!room_bound_offset_y        = $3360

; gourmet race timer
!timer_minutes      = $7A2D
!timer_seconds      = $7A2C 
!timer_milliseconds = $7A2B

; various miscellaneous things
!animation_timer        = $6E4C
!reload_room            = $7392
!reload_room_long       = $007392
!screen_fade            = $30A1
!screen_fade_long       = $0030A1
!screen_brightness      = $305F
!screen_brightness_long = $00305F
!replay_cutscene        = $332A     ; this variable might do more than just handle cutscenes
!move_cam_hud           = $3330     ;/ these...
!is_paused              = $7368     ;\ ... two seem to do the same thing?
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
!helper_ability         = $74A1
!helper_info1           = $7496
!helper_info2           = $74A0
!helper_info3           = $74A2
!wheelie_rider_state    = $7569
!kirby_invincible       = $35F1
!kirby_invincible_time  = $35F5
!kirby_inv_flash        = $75B1
!helper_invincible      = $35F3
!helper_invincible_time = $35F7
!helper_inv_flash       = $75B3
!kirby_speed            = $74C8
!helper_speed           = $74CA
!is_shooting            = $7577     ; shmup section, the "shooting" ability

; item tracking
!lives_collected        = $14C7     ; persists between rooms (item does not respawn between rooms)
!tomatoes_collected     = $14CF     ; persists between rooms
!food_collected         = $14D7     ; gets cleared in between rooms (these always respawn)
!romk_cutscenes_done    = $771D     ; persists between rooms, 3 bytes large

; blank addresses used for storing information
!respawn_timer              = $7B5A
!temp_pointer               = $7B5C
!mww_ability_route          = $7B71
!mww_planet_rta             = $7B60
!QSQL_timer                 = $7B62
!QSQL_transfer              = $7B64
!is_reloading_room          = $7B68
!toggle_free_move           = $7B70
!mute_toggle                = $7B7E
!save_sound_buffer          = $40FFF0
!save_sound_bank_1          = $40FFEA
!save_sound_bank_2          = $40FFFB
!toggle_custom_colors       = $40FFFD
!custom_menu_enabled        = $40FFC0
!custom_menu_language       = $40FFC2
!custom_menu_pointer        = $40FFC4
!custom_menu_cursor         = $40FFC6
!custom_menu_action         = $40FFC8
!custom_menu_subgame_warp   = $40FFCA
!is_warping                 = $40FFCC
!autoboot_corkboard         = $40FFCE
!custom_menu_level_table    = $66       ; called as $3766 in menu code

; for saving certain values on room reload 
!room_reload_storage                = $40FF40

!store_ability                      = !room_reload_storage
!store_helper_ability               = !room_reload_storage+$2
!store_wheelie_rider_state          = !room_reload_storage+$4
!store_kirby_hp                     = !room_reload_storage+$6
!store_helper_hp                    = !room_reload_storage+$8
!store_abilities_1                  = !room_reload_storage+$A
!store_abilities_2                  = !room_reload_storage+$C
!store_kirby_invincibility_timer    = !room_reload_storage+$E
!store_kirby_invincibility_state    = !room_reload_storage+$10
!store_helper_invincibility_timer   = !room_reload_storage+$12
!store_helper_invincibility_state   = !room_reload_storage+$14
!store_kirby_speed                  = !room_reload_storage+$16
!store_helper_speed                 = !room_reload_storage+$18
!store_music                        = !room_reload_storage+$1A
!store_RNG                          = !room_reload_storage+$1C
!store_lives_collected              = !room_reload_storage+$1E
!store_tomatoes_collected           = !room_reload_storage+$20
!store_romk_cutscenes               = !room_reload_storage+$22
!store_kirby_flashing               = !room_reload_storage+$26
!store_helper_flashing              = !room_reload_storage+$28
!store_ability_sfx                  = !room_reload_storage+$2A
!store_last_ability_selected        = !room_reload_storage+$2C

!reload_storage_size                = $002C
!room_reload_storage_state          = !room_reload_storage+!reload_storage_size+2

; subroutines
!reset_game                 = $BCE7
!check_game_reset           = $BCDE
!update_romk_vram           = $07E55D
!assign_ability_data        = $029C71
!assign_helper_data         = $029D2F
!finalize_cutscene          = $00CF98
!erase_file                 = $00ECD0
!load_music                 = $00CF98
!update_tileset             = $0087CB
!update_tileset_kirby_pos   = $0085EA
;!update_soundbank           = $00D2F0          ;$00D1D0
!global_jump_pointer        = $633E
!pause_game_loop            = $00A2D4
!resume_game_loop           = $00A2EF
!close_pause_menu           = $CF9AB2
!draw_text                  = $1FB449
!draw_pause_menu            = $CF999B
!dim_screen                 = $C005C7
!update_layers_input        = $008A06
!sa1_executesnes            = $008C6D

; internal dma queue
!write_to_dma_buffer        = $00875a
!load_dma_table             = $0086e5

; arguments for the above
!dma_type                   = $003731 ;8bit
; index into table at $00869D
!dma_size                   = $003732 ;16bit
!dma_src                    = $003734 ;16bit
!dma_src_bank               = $003736 ;8bit
!dma_dest                   = $003737 ;16bit

;tables 
!mww_planet_x_pos           = $CAA6F5
!mww_planet_y_pos           = $CAA709

; useless subroutines that ill keep here anyway cuz theyre nice to have somewhere
!debug_reload_display       = $DBE7
!play_sfx                   = $D155
!play_sfx_long              = $00D155

; controller buttons
!btn_b      = $8000
!btn_y      = $4000
!btn_select = $2000
!btn_start  = $1000
!btn_up     = $0800
!btn_down   = $0400
!btn_left   = $0200
!btn_right  = $0100
!btn_a      = $0080
!btn_x      = $0040
!btn_l      = $0020
!btn_r      = $0010

; ---------------------------------------------------------------------------
; RAM Addresses - Variables (v) and Flags (f)
; ---------------------------------------------------------------------------

; ====================
; Error trap variables
; ====================
v_reg_buffer:		equ $FFFFFC00 ; stores registers d0-a7 during an error event ($40 bytes) - v_objstate uses same space
v_sp_buffer:		equ $FFFFFC40 ; stores most recent sp address (4 bytes) - v_objstate uses same space
v_error_type:		equ $FFFFFC44 ; error type - v_objstate uses same space

; ====================
; Major data blocks
; ====================
v_256x256_tiles:	equ   $FF0000 ; 256x256 tile mappings ($A400 bytes)
v_level_layout:		equ $FFFFA400 ; level and background layouts ($400 bytes)
v_bgscroll_buffer:	equ $FFFFA800 ; background scroll buffer ($200 bytes)
v_nem_gfx_buffer:	equ $FFFFAA00 ; Nemesis graphics decompression buffer ($200 bytes)
v_sprite_queue:		equ $FFFFAC00 ; sprite display queue, in order of priority ($400 bytes)
v_16x16_tiles:		equ $FFFFB000 ; 16x16 tile mappings
v_sonic_gfx_buffer:	equ $FFFFC800 ; buffered Sonic graphics ($17 cells) ($2E0 bytes)
v_sonic_pos_tracker:	equ $FFFFCB00 ; earlier position tracking list for Sonic, used by invinciblity stars ($100 bytes)
v_hscroll_buffer:	equ $FFFFCC00 ; scrolling table data (actually $380 bytes, but $400 is reserved for it)
v_ost_all:		equ $FFFFD000 ; object variable space ($40 bytes per object) ($2000 bytes)
	v_ost_player:		equ v_ost_all ; object variable space for Sonic ($40 bytes)
	; Title screen and intro
	v_ost_titlesonic:	equ v_ost_all+(sizeof_ost*1) ; title screen Sonic
	v_ost_psb:		equ v_ost_all+(sizeof_ost*2) ; title screen "Press Start Button"
	v_ost_tm:		equ v_ost_all+(sizeof_ost*3) ; title screen "TM"
	v_ost_titlemask:	equ v_ost_all+(sizeof_ost*4) ; title screen sprite mask
	; Intro/credits
	v_ost_credits:		equ v_ost_all+(sizeof_ost*2) ; "Sonic Team Presents" and credits text
	; Try again
	v_ost_endeggman:	equ v_ost_all+(sizeof_ost*2) ; ending/"Try Again" Eggman
	v_ost_tryagain:		equ v_ost_all+(sizeof_ost*3) ; "Try Again" text
	v_ost_tryag_emeralds:	equ v_ost_all+(sizeof_ost*$20) ; "Try Again" chaos emeralds
	; Continue
	v_ost_cont_text:	equ v_ost_all+(sizeof_ost*1) ; continue screen text
	v_ost_cont_oval:	equ v_ost_all+(sizeof_ost*2) ; continue screen oval
	v_ost_cont_minisonic:	equ v_ost_all+(sizeof_ost*3) ; continue screen mini Sonics
	; Level - no interaction with Sonic
	v_ost_hud:		equ v_ost_all+(sizeof_ost*1) ; HUD
	v_ost_titlecard1:	equ v_ost_all+(sizeof_ost*2) ; title card - zone name
	v_ost_titlecard2:	equ v_ost_all+(sizeof_ost*3) ; title card - "zone"
	v_ost_titlecard3:	equ v_ost_all+(sizeof_ost*4) ; title card - "act" 1/2/3
	v_ost_titlecard4:	equ v_ost_all+(sizeof_ost*5) ; title card - oval
	v_ost_gameover1:	equ v_ost_all+(sizeof_ost*2) ; game over card - "game"/"time"
	v_ost_gameover2:	equ v_ost_all+(sizeof_ost*3) ; game over card - "over"
	v_ost_shield:		equ v_ost_all+(sizeof_ost*6) ; shield
	v_ost_stars1:		equ v_ost_all+(sizeof_ost*8) ; invincibility stars
	v_ost_stars2:		equ v_ost_all+(sizeof_ost*9) ; invincibility stars
	v_ost_stars3:		equ v_ost_all+(sizeof_ost*$A) ; invincibility stars
	v_ost_stars4:		equ v_ost_all+(sizeof_ost*$B) ; invincibility stars
	v_ost_end_emeralds:	equ v_ost_all+(sizeof_ost*$10) ; ending chaos emeralds
	v_ost_gotthrough1:	equ v_ost_all+(sizeof_ost*$17) ; got through act - "Sonic has"
	v_ost_gotthrough2:	equ v_ost_all+(sizeof_ost*$18) ; got through act - "passed"
	v_ost_gotthrough3:	equ v_ost_all+(sizeof_ost*$19) ; got through act - "act" 1/2/3
	v_ost_gotthrough4:	equ v_ost_all+(sizeof_ost*$1A) ; got through act - score
	v_ost_gotthrough5:	equ v_ost_all+(sizeof_ost*$1B) ; got through act - time bonus
	v_ost_gotthrough6:	equ v_ost_all+(sizeof_ost*$1C) ; got through act - ring bonus
	v_ost_gotthrough7:	equ v_ost_all+(sizeof_ost*$1D) ; got through act - oval
	v_ost_watersurface1:	equ v_ost_all+(sizeof_ost*$1E) ; LZ water surface
	v_ost_watersurface2:	equ v_ost_all+(sizeof_ost*$1F) ; LZ water surface
	; Special stage results
	v_ost_ssresult1:	equ v_ost_all+(sizeof_ost*$17) ; special stage results screen
	v_ost_ssresult2:	equ v_ost_all+(sizeof_ost*$18) ; special stage results screen
	v_ost_ssresult3:	equ v_ost_all+(sizeof_ost*$19) ; special stage results screen
	v_ost_ssresult4:	equ v_ost_all+(sizeof_ost*$1A) ; special stage results screen
	v_ost_ssresult5:	equ v_ost_all+(sizeof_ost*$1B) ; special stage results screen
	v_ost_ssres_emeralds:	equ v_ost_all+(sizeof_ost*$20) ; special stage results screen chaos emeralds
	; Level - can interact with Sonic
	v_ost_level_obj:	equ v_ost_all+(sizeof_ost*$20) ; level object variable space ($1800 bytes)
v_ost_end:		equ $FFFFF000

v_snddriver_ram:	equ $FFFFF000 ; start of RAM for the sound driver data ($5C0 bytes)

; =================================================================================
; From here on, until otherwise stated, all offsets are relative to v_snddriver_ram
; =================================================================================
v_startofvariables:	equ $000
v_sndprio:		equ $000	; sound priority (priority of new music/SFX must be higher or equal to this value or it won't play; bit 7 of priority being set prevents this value from changing)
v_main_tempo_timeout:	equ $001	; Counts down to zero; when zero, resets to next value and delays song by 1 frame
v_main_tempo:		equ $002	; Used for music only
f_pausemusic:		equ $003	; flag set to stop music when paused
v_fadeout_counter:	equ $004

v_fadeout_delay:	equ $006
v_communication_byte:	equ $007	; used in Ristar to sync with a boss' attacks; unused here
f_updating_dac:		equ $008	; $80 if updating DAC, $00 otherwise
v_sound_id:		equ $009	; sound or music copied from below
v_soundqueue0:		equ $00A	; sound or music to play
v_soundqueue1:		equ $00B	; special sound to play
v_soundqueue2:		equ $00C	; unused sound to play

f_voice_selector:	equ $00E	; $00 = use music voice pointer; $40 = use special voice pointer; $80 = use track voice pointer

v_voice_ptr:		equ $018	; voice data pointer (4 bytes)

v_special_voice_ptr:	equ $020	; voice data pointer for special SFX ($D0-$DF) (4 bytes)

f_fadein_flag:		equ $024	; Flag for fade in
v_fadein_delay:		equ $025
v_fadein_counter:	equ $026	; Timer for fade in/out
f_1up_playing:		equ $027	; flag indicating 1-up song is playing
v_tempo_mod:		equ $028	; music - tempo modifier
v_speeduptempo:		equ $029	; music - tempo modifier with speed shoes
f_speedup:		equ $02A	; flag indicating whether speed shoes tempo is on ($80) or off ($00)
v_ring_speaker:		equ $02B	; which speaker the "ring" sound is played in (00 = right; 01 = left)
f_push_playing:		equ $02C	; if set, prevents further push sounds from playing

v_music_track_ram:	equ $040	; Start of music RAM

v_music_fmdac_tracks:	equ v_music_track_ram+TrackSz*0
v_music_dac_track:	equ v_music_fmdac_tracks+TrackSz*0
v_music_fm_tracks:	equ v_music_fmdac_tracks+TrackSz*1
v_music_fm1_track:	equ v_music_fm_tracks+TrackSz*0
v_music_fm2_track:	equ v_music_fm_tracks+TrackSz*1
v_music_fm3_track:	equ v_music_fm_tracks+TrackSz*2
v_music_fm4_track:	equ v_music_fm_tracks+TrackSz*3
v_music_fm5_track:	equ v_music_fm_tracks+TrackSz*4
v_music_fm6_track:	equ v_music_fm_tracks+TrackSz*5
v_music_fm_tracks_end:	equ v_music_fm_tracks+TrackSz*6
v_music_fmdac_tracks_end:	equ v_music_fm_tracks_end
v_music_psg_tracks:	equ v_music_fmdac_tracks_end
v_music_psg1_track:	equ v_music_psg_tracks+TrackSz*0
v_music_psg2_track:	equ v_music_psg_tracks+TrackSz*1
v_music_psg3_track:	equ v_music_psg_tracks+TrackSz*2
v_music_psg_tracks_end:	equ v_music_psg_tracks+TrackSz*3
v_music_track_ram_end:	equ v_music_psg_tracks_end

v_sfx_track_ram:	equ v_music_track_ram_end	; Start of SFX RAM, straight after the end of music RAM

v_sfx_fm_tracks:	equ v_sfx_track_ram+TrackSz*0
v_sfx_fm3_track:	equ v_sfx_fm_tracks+TrackSz*0
v_sfx_fm4_track:	equ v_sfx_fm_tracks+TrackSz*1
v_sfx_fm5_track:	equ v_sfx_fm_tracks+TrackSz*2
v_sfx_fm_tracks_end:	equ v_sfx_fm_tracks+TrackSz*3
v_sfx_psg_tracks:	equ v_sfx_fm_tracks_end
v_sfx_psg1_track:	equ v_sfx_psg_tracks+TrackSz*0
v_sfx_psg2_track:	equ v_sfx_psg_tracks+TrackSz*1
v_sfx_psg3_track:	equ v_sfx_psg_tracks+TrackSz*2
v_sfx_psg_tracks_end:	equ v_sfx_psg_tracks+TrackSz*3
v_sfx_track_ram_end:	equ v_sfx_psg_tracks_end

v_spcsfx_track_ram:	equ v_sfx_track_ram_end	; Start of special SFX RAM, straight after the end of SFX RAM

v_spcsfx_fm4_track:	equ v_spcsfx_track_ram+TrackSz*0
v_spcsfx_psg3_track:	equ v_spcsfx_track_ram+TrackSz*1
v_spcsfx_track_ram_end:	equ v_spcsfx_track_ram+TrackSz*2

v_1up_ram_copy:		equ v_spcsfx_track_ram_end

; =================================================================================
; From here on, no longer relative to sound driver RAM
; =================================================================================

v_gamemode:		equ $FFFFF600 ; game mode (00=Sega; 04=Title; 08=Demo; 0C=Level; 10=SS; 14=Cont; 18=End; 1C=Credit; 8C=PreLevel)
	; $F601 unused
v_joypad_hold:		equ $FFFFF602 ; joypad input - held, can be overridden by demos
v_joypad_press:		equ $FFFFF603 ; joypad input - pressed, can be overridden by demos
v_joypad_hold_actual:	equ $FFFFF604 ; joypad input - held, actual
v_joypad_press_actual:	equ $FFFFF605 ; joypad input - pressed, actual
v_joypad2_hold_actual:	equ $FFFFF606 ; joypad 2 input - held, actual - unused
v_joypad2_press_actual:	equ $FFFFF607 ; joypad 2 input - pressed, actual - unused
	; $F608-$F60B unused
v_vdp_mode_buffer:	equ $FFFFF60C ; VDP register $81 buffer - contains $8134 which is sent to vdp_control_port (2 bytes)
	; $F60E-$F613 unused
v_countdown:		equ $FFFFF614 ; decrements every time VBlank runs, used as a general purpose timer (2 bytes)
v_fg_y_pos_vsram:	equ $FFFFF616 ; foreground y position, sent to VSRAM during VBlank (2 bytes)
v_bg_y_pos_vsram:	equ $FFFFF618 ; background y position, sent to VSRAM during VBlank (2 bytes)
v_fg_x_pos_hscroll:	equ $FFFFF61A ; foreground x position - unused (2 bytes)
v_bg_x_pos_hscroll:	equ $FFFFF61C ; background x position - unused (2 bytes)
v_bg3screenposy_dup_unused:	equ $FFFFF61E ; (2 bytes)
v_bg3screenposx_dup_unused:	equ $FFFFF620 ; (2 bytes)

	; $F622-$F623 unused
v_vdp_hint_counter:	equ $FFFFF624 ; VDP register $8A buffer - horizontal interrupt counter ($8Axx) (2 bytes)
	v_vdp_hint_line:	equ $FFFFF625 ; screen line where water starts and palette is changed by HBlank
v_palfade_start:	equ $FFFFF626 ; palette fading - start position in bytes
v_palfade_size:		equ $FFFFF627 ; palette fading - number of colours
v_vblank_0e_counter:	equ $FFFFF628 ; counter that increments when VBlank routine $E is run - unused
	; $F629 unused
v_vblank_routine:	equ $FFFFF62A ; VBlank routine counter
	; $F62B unused
v_spritecount:		equ $FFFFF62C ; number of sprites on-screen
	; $F62D-$F631 unused
v_palcycle_num:		equ $FFFFF632 ; palette cycling - current index number (2 bytes)
v_palcycle_time:	equ $FFFFF634 ; palette cycling - time until the next change (2 bytes)
v_random:		equ $FFFFF636 ; pseudo random number generator result (4 bytes)
f_pause:		equ $FFFFF63A ; flag set to pause the game (2 bytes)
	; $F63C-$F63F unused
v_vdp_dma_buffer:	equ $FFFFF640 ; VDP DMA command buffer (2 bytes)
	; $F642-$F643 unused
f_hblank_pal_change:	equ $FFFFF644 ; flag set to change palette during HBlank (0000 = no; 0001 = change) (2 bytes)
v_water_height_actual:	equ $FFFFF646 ; water height, actual (2 bytes)
v_water_height_normal:	equ $FFFFF648 ; water height, ignoring wobble (2 bytes)
v_water_height_next:	equ $FFFFF64A ; water height, next target (2 bytes)
v_water_direction:	equ $FFFFF64C ; water setting - 0 = no water; 1 = water moves down; -1 = water moves up
v_water_routine:	equ $FFFFF64D ; water event routine counter
f_water_pal_full:	equ $FFFFF64E ; flag set when water covers the entire screen (00 = partly/all dry; 01 = all underwater)
f_hblank_run_snd:	equ $FFFFF64F ; flag set when sound driver should be run from HBlank
v_palcycle_buffer:	equ $FFFFF650 ; palette data buffer (used for palette cycling) ($30 bytes)
v_plc_buffer:		equ $FFFFF680 ; pattern load cues buffer (maximum $10 PLCs) ($60 bytes)
v_nemdec_ptr:		equ $FFFFF6E0 ; pointer for nemesis decompression code ($1502 or $150C) (4 bytes)

f_plc_execute:	equ $FFFFF6F8	; flag set for pattern load cue execution (2 bytes)

v_screenposx:	equ $FFFFF700	; screen position x (2 bytes)
v_screenposy:	equ $FFFFF704	; screen position y (2 bytes)
v_bgscreenposx:	equ $FFFFF708	; background screen position x (2 bytes)
v_bgscreenposy:	equ $FFFFF70C	; background screen position y (2 bytes)
v_bg2screenposx:	equ $FFFFF710	; 2 bytes
v_bg2screenposy:	equ $FFFFF714	; 2 bytes
v_bg3screenposx:	equ $FFFFF718	; 2 bytes
v_bg3screenposy:	equ $FFFFF71C	; 2 bytes

v_limitleft1:	equ $FFFFF720	; left level boundary (2 bytes)
v_limitright1:	equ $FFFFF722	; right level boundary (2 bytes)
v_limittop1:	equ $FFFFF724	; top level boundary (2 bytes)
v_limitbtm1:	equ $FFFFF726	; bottom level boundary (2 bytes)
v_limitleft2:	equ $FFFFF728	; left level boundary (2 bytes)
v_limitright2:	equ $FFFFF72A	; right level boundary (2 bytes)
v_limittop2:	equ $FFFFF72C	; top level boundary (2 bytes)
v_limitbtm2:	equ $FFFFF72E	; bottom level boundary (2 bytes)

v_limitleft3:	equ $FFFFF732	; left level boundary, at the end of an act (2 bytes)

v_scrshiftx:	equ $FFFFF73A	; x-screen shift (new - last) * $100
v_scrshifty:	equ $FFFFF73C	; y-screen shift (new - last) * $100

v_lookshift:	equ $FFFFF73E	; screen shift when Sonic looks up/down (2 bytes)
v_dle_routine:	equ $FFFFF742	; dynamic level event - routine counter
f_nobgscroll:	equ $FFFFF744	; flag set to cancel background scrolling

v_fg_xblock:	equ	$FFFFF74A	; foreground x-block parity (for redraw)
v_fg_yblock:	equ	$FFFFF74B	; foreground y-block parity (for redraw)
v_bg1_xblock:	equ	$FFFFF74C	; background x-block parity (for redraw)
v_bg1_yblock:	equ	$FFFFF74D	; background y-block parity (for redraw)
v_bg2_xblock:	equ	$FFFFF74E	; secondary background x-block parity (for redraw)
v_bg2_yblock:	equ	$FFFFF74F	; secondary background y-block parity (unused)
v_bg3_xblock:	equ	$FFFFF750	; teritary background x-block parity (for redraw)
v_bg3_yblock:	equ	$FFFFF751	; teritary background y-block parity (unused)

v_fg_scroll_flags:	equ $FFFFF754	; screen redraw flags for foreground
v_bg1_scroll_flags:	equ $FFFFF756	; screen redraw flags for background 1
v_bg2_scroll_flags:	equ $FFFFF758	; screen redraw flags for background 2
v_bg3_scroll_flags:	equ $FFFFF75A	; screen redraw flags for background 3
f_bgscrollvert:	equ $FFFFF75C	; flag for vertical background scrolling

v_sonic_max_speed:	equ $FFFFF760 ; Sonic's maximum speed (2 bytes)
v_sonic_acceleration:	equ $FFFFF762 ; Sonic's acceleration (2 bytes)
v_sonic_deceleration:	equ $FFFFF764 ; Sonic's deceleration (2 bytes)
v_sonic_last_frame_id:	equ $FFFFF766 ; Sonic's last frame id, compared with current frame to determine if graphics need updating
f_sonic_dma_gfx:	equ $FFFFF767 ; flag set to DMA Sonic's graphics from RAM to VRAM
v_angle_right:		equ $FFFFF768 ; angle of floor on Sonic's right side

v_angle_left:		equ $FFFFF76A ; angle of floor on Sonic's left side

v_opl_routine:		equ $FFFFF76C ; ObjPosLoad - routine counter
	; $F76D unused
v_opl_screen_x_pos:	equ $FFFFF76E ; ObjPosLoad - screen x position, rounded down to nearest $80 (2 bytes)
v_opl_ptr_right:	equ $FFFFF770 ; ObjPosLoad - pointer to current objpos data (4 bytes)
v_opl_ptr_left:		equ $FFFFF774 ; ObjPosLoad - pointer to leftmost objpos data (4 bytes)
v_opl_ptr_alt_right:	equ $FFFFF778 ; ObjPosLoad - pointer to current secondary objpos data (4 bytes)
v_opl_ptr_alt_left:	equ $FFFFF77C ; ObjPosLoad - pointer to leftmost secondary objpos data (4 bytes)

v_ss_angle:		equ $FFFFF780 ; Special Stage angle (2 bytes)
v_ss_rotation_speed:	equ $FFFFF782 ; Special Stage rotation speed (2 bytes)

v_demo_input_counter:	equ $FFFFF790 ; tracks progress in the demo input data, increases by 2 when input changes (2 bytes)
v_demo_input_time:	equ $FFFFF792 ; time remaining for current demo "button press"

v_palfade_time:		equ $FFFFF794 ; palette fading - time until next change (2 bytes)
v_collision_index_ptr:	equ $FFFFF796 ; ROM address for collision index of current level (4 bytes)
v_palcycle_ss_num:	equ $FFFFF79A ; palette cycling in Special Stage - current index number (2 bytes)
v_palcycle_ss_time:	equ $FFFFF79C ; palette cycling in Special Stage - time until next change (2 bytes)
v_palcycle_ss_unused:	equ $FFFFF79E ; palette cycling in Special Stage - unused offset value, always 0 (2 bytes)
v_ss_bg_mode:		equ $FFFFF7A0 ; Special Stage fish/bird background animation mode (2 byes)

v_cstomp_y_pos:		equ $FFFFF7A4 ; y position of MZ chain stomper, used for interaction with pushable green block (2 bytes)

v_boss_status:		equ $FFFFF7A7 ; status of boss and prison capsule - 01 = boss defeated; 02 = prison opened
v_sonic_pos_tracker_num:	equ $FFFFF7A8 ; current location within position tracking data (2 bytes)
v_sonic_pos_tracker_num_low:	equ v_sonic_pos_tracker_num+1
f_boss_boundary:	equ $FFFFF7AA ; flag set to stop Sonic moving off the right side of the screen at a boss

v_256x256_with_loop_1:	equ $FFFFF7AC ; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256x256_with_loop_2:	equ $FFFFF7AD ; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256x256_with_tunnel_1:	equ $FFFFF7AE ; 256x256 level tile which contains a roll tunnel (GHZ)
v_256x256_with_tunnel_2:	equ $FFFFF7AF ; 256x256 level tile which contains a roll tunnel (GHZ)
v_levelani_0_frame:	equ $FFFFF7B0 ; level graphics animation 0 - current frame
v_levelani_0_time:	equ $FFFFF7B1 ; level graphics animation 0 - time until next frame
v_levelani_1_frame:	equ $FFFFF7B2 ; level graphics animation 1 - current frame
v_levelani_1_time:	equ $FFFFF7B3 ; level graphics animation 1 - time until next frame
v_levelani_2_frame:	equ $FFFFF7B4 ; level graphics animation 2 - current frame
v_levelani_2_time:	equ $FFFFF7B5 ; level graphics animation 2 - time until next frame
v_levelani_3_frame:	equ $FFFFF7B6 ; level graphics animation 3 - current frame
v_levelani_3_time:	equ $FFFFF7B7 ; level graphics animation 3 - time until next frame
v_levelani_4_frame:	equ $FFFFF7B8 ; level graphics animation 4 - current frame
v_levelani_4_time:	equ $FFFFF7B9 ; level graphics animation 4 - time until next frame
v_levelani_5_frame:	equ $FFFFF7BA ; level graphics animation 5 - current frame
v_levelani_5_time:	equ $FFFFF7BB ; level graphics animation 5 - time until next frame

v_giantring_gfx_offset:	equ $FFFFF7BE ; address of art for next giant ring frame, relative to Art_BigRing (counts backwards from $C40; 0 means no more art) (2 bytes)
f_convey_reverse:	equ $FFFFF7C0 ; flag set to reverse conveyor belts in LZ/SBZ
v_obj63:		equ $FFFFF7C1	; object 63 (LZ/SBZ platforms) variables (6 bytes)
f_wtunnelmode:	equ $FFFFF7C7	; LZ water tunnel mode
f_lockmulti:	equ $FFFFF7C8	; +1 = lock controls, lock Sonic's position & animation; +$80 = no collision with objects
f_wtunnelallow:	equ $FFFFF7C9	; LZ water tunnels (00 = enabled; 01 = disabled)
f_jumponly:	equ $FFFFF7CA	; flag set to lock controls apart from jumping
v_obj6B:		equ $FFFFF7CB	; object 6B (SBZ stomper) variable
f_lockctrl:	equ $FFFFF7CC	; flag set to lock controls during ending sequence
f_bigring:	equ $FFFFF7CD	; flag set when Sonic collects the giant ring
f_obj56:	equ $FFFFF7CE	; flag set for something related to obj56 (REV01 only)
v_itembonus:	equ $FFFFF7D0	; item bonus from broken enemies, blocks etc. (2 bytes)
v_timebonus:	equ $FFFFF7D2	; time bonus at the end of an act (2 bytes)
v_ringbonus:	equ $FFFFF7D4	; ring bonus at the end of an act (2 bytes)
f_endactbonus:	equ $FFFFF7D6	; time/ring bonus update flag at the end of an act
v_sonicend:	equ $FFFFF7D7	; routine counter for Sonic in the ending sequence
v_lz_deform:	equ	$FFFFF7D8	; LZ deformtaion offset, in units of $80 (2 bytes)
f_switch:	equ $FFFFF7E0	; flags set when Sonic stands on a switch ($10 bytes)
v_scroll_block_1_size:	equ $FFFFF7F0	; (2 bytes)
v_scroll_block_2_size:	equ $FFFFF7F2	; unused (2 bytes)
v_scroll_block_3_size:	equ $FFFFF7F4	; unused (2 bytes)
v_scroll_block_4_size:	equ $FFFFF7F6	; unused (2 bytes)

v_spritetablebuffer:	equ $FFFFF800 ; sprite table ($280 bytes, last $80 bytes are overwritten by v_pal_water_dup)
v_pal_water_dup:	equ $FFFFFA00 ; duplicate underwater palette, used for transitions ($80 bytes)
v_pal_water:	equ $FFFFFA80	; main underwater palette ($80 bytes)
v_pal_dry:	equ $FFFFFB00	; main palette ($80 bytes)
v_pal_dry_dup:	equ $FFFFFB80	; duplicate palette, used for transitions ($80 bytes)
v_objstate:	equ $FFFFFC00	; object state list ($100 bytes)


v_stack:		equ $FFFFFD00 ; stack ($100 bytes)
v_stack_pointer:	equ $FFFFFE00 ; stack pointer

f_restart:		equ $FFFFFE02 ; flag set to end/restart level (2 bytes)
v_frame_counter:	equ $FFFFFE04 ; frame counter, increments every frame (2 bytes)
v_frame_counter_low:	equ v_frame_counter+1 ; low byte for frame counter
v_debug_item_index:	equ $FFFFFE06 ; debug item currently selected (NOT the object id of the item)

v_debug_active:		equ $FFFFFE08 ; xx01 when debug mode is in use and Sonic is an item; 0 otherwise (2 bytes)
v_debug_active_hi:	equ $FFFFFE08 ; high byte of v_debug_active, routine counter for DebugMode (00/02)
v_debug_x_speed:	equ $FFFFFE0A ; debug mode - horizontal speed
v_debug_y_speed:	equ $FFFFFE0B ; debug mode - vertical speed
v_vblank_counter:	equ $FFFFFE0C ; vertical interrupt counter, increments every VBlank (4 bytes)
v_vblank_counter_word:	equ v_vblank_counter+2 ; low word for v_vblank_counter (2 bytes)
v_vblank_counter_byte:	equ v_vblank_counter_word+1 ; low byte for v_vblank_counter
v_zone:			equ $FFFFFE10 ; current zone number
v_act:			equ $FFFFFE11 ; current act number
v_lives:		equ $FFFFFE12 ; number of lives

v_air:			equ $FFFFFE14 ; air remaining while underwater (2 bytes)
v_last_ss_levelid:	equ $FFFFFE16 ; level id of most recent special stage played

v_continues:		equ $FFFFFE18 ; number of continues

f_time_over:		equ $FFFFFE1A ; time over flag
v_ring_reward:		equ $FFFFFE1B ; tracks which rewards have been given for rings - bit 0 = 50 rings (Special Stage); bit 1 = 100 rings; bit 2 = 200 rings
f_hud_lives_update:	equ $FFFFFE1C ; lives counter update flag
v_hud_rings_update:	equ $FFFFFE1D ; ring counter update flag - 1 = general update; $80 = reset to 0
f_hud_time_update:	equ $FFFFFE1E ; time counter update flag
f_hud_score_update:	equ $FFFFFE1F ; score counter update flag
v_rings:		equ $FFFFFE20 ; rings (2 bytes)
v_time:			equ $FFFFFE22 ; time (4 bytes)
v_time_min:		equ $FFFFFE23 ; time - minutes
v_time_sec:		equ $FFFFFE24 ; time - seconds
v_time_frames:		equ $FFFFFE25 ; time - frames
v_score:		equ $FFFFFE26 ; score (4 bytes)

v_shield:		equ $FFFFFE2C ; shield status - 00 = no; 01 = yes
v_invincibility:	equ $FFFFFE2D ; invinciblity status - 00 = no; 01 = yes
v_shoes:		equ $FFFFFE2E ; speed shoes status - 00 = no; 01 = yes

v_lastlamp:	equ $FFFFFE30	; number of the last lamppost you hit
v_lamp_xpos:	equ v_lastlamp+2	; x-axis for Sonic to respawn at lamppost (2 bytes)
v_lamp_ypos:	equ v_lastlamp+4	; y-axis for Sonic to respawn at lamppost (2 bytes)
v_lamp_rings:	equ v_lastlamp+6	; rings stored at lamppost (2 bytes)
v_lamp_time:	equ v_lastlamp+8	; time stored at lamppost (2 bytes)
v_lamp_dle:	equ v_lastlamp+$C	; dynamic level event routine counter at lamppost
v_lamp_limitbtm:	equ v_lastlamp+$E	; level bottom boundary at lamppost (2 bytes)
v_lamp_scrx:	equ v_lastlamp+$10 ; x-axis screen at lamppost (2 bytes)
v_lamp_scry:	equ v_lastlamp+$12 ; y-axis screen at lamppost (2 bytes)

v_lamp_wtrpos:	equ v_lastlamp+$20 ; water position at lamppost (2 bytes)
v_lamp_wtrrout:	equ v_lastlamp+$22 ; water routine at lamppost
v_lamp_wtrstat:	equ v_lastlamp+$23 ; water state at lamppost
v_lamp_lives:	equ v_lastlamp+$24 ; lives counter at lamppost
v_emeralds:	equ $FFFFFE57	; number of chaos emeralds
v_emldlist:	equ $FFFFFE58	; which individual emeralds you have (00 = no; 01 = yes) (6 bytes)
v_oscillate:	equ $FFFFFE5E	; values which oscillate - for swinging platforms, et al ($42 bytes)
v_ani0_time:	equ $FFFFFEC0	; synchronised sprite animation 0 - time until next frame (used for synchronised animations)
v_ani0_frame:	equ $FFFFFEC1	; synchronised sprite animation 0 - current frame
v_ani1_time:	equ $FFFFFEC2	; synchronised sprite animation 1 - time until next frame
v_ani1_frame:	equ $FFFFFEC3	; synchronised sprite animation 1 - current frame
v_ani2_time:	equ $FFFFFEC4	; synchronised sprite animation 2 - time until next frame
v_ani2_frame:	equ $FFFFFEC5	; synchronised sprite animation 2 - current frame
v_ani3_time:	equ $FFFFFEC6	; synchronised sprite animation 3 - time until next frame
v_ani3_frame:	equ $FFFFFEC7	; synchronised sprite animation 3 - current frame
v_ani3_buf:	equ $FFFFFEC8	; synchronised sprite animation 3 - info buffer (2 bytes)
v_limittopdb:	equ $FFFFFEF0	; level upper boundary, buffered for debug mode (2 bytes)
v_limitbtmdb:	equ $FFFFFEF2	; level bottom boundary, buffered for debug mode (2 bytes)

v_screenposx_dup:	equ $FFFFFF10	; screen position x (duplicate) (2 bytes)
v_screenposy_dup:	equ $FFFFFF14	; screen position y (duplicate) (2 bytes)
v_bgscreenposx_dup:	equ $FFFFFF18	; background screen position x (duplicate) (2 bytes)
v_bgscreenposy_dup:	equ $FFFFFF1C	; background screen position y (duplicate) (2 bytes)
v_bg2screenposx_dup:	equ $FFFFFF20	; 2 bytes
v_bg2screenposy_dup:	equ $FFFFFF24	; 2 bytes
v_bg3screenposx_dup:	equ $FFFFFF28	; 2 bytes
v_bg3screenposy_dup:	equ $FFFFFF2C	; 2 bytes
v_fg_scroll_flags_dup:	equ $FFFFFF30
v_bg1_scroll_flags_dup:	equ $FFFFFF32
v_bg2_scroll_flags_dup:	equ $FFFFFF34
v_bg3_scroll_flags_dup:	equ $FFFFFF36

v_levseldelay:	equ $FFFFFF80	; level select - time until change when up/down is held (2 bytes)
v_levselitem:	equ $FFFFFF82	; level select - item selected (2 bytes)
v_levselsound:	equ $FFFFFF84	; level select - sound selected (2 bytes)
v_scorecopy:	equ $FFFFFFC0	; score, duplicate (4 bytes)
v_scorelife:	equ $FFFFFFC0	; points required for an extra life (4 bytes) (JP1 only)
f_levselcheat:	equ $FFFFFFE0	; level select cheat flag
f_slomocheat:	equ $FFFFFFE1	; slow motion & frame advance cheat flag
f_debugcheat:	equ $FFFFFFE2	; debug mode cheat flag
f_creditscheat:	equ $FFFFFFE3	; hidden credits & press start cheat flag
v_title_dcount:	equ $FFFFFFE4	; number of times the d-pad is pressed on title screen (2 bytes)
v_title_ccount:	equ $FFFFFFE6	; number of times C is pressed on title screen (2 bytes)

f_demo:		equ $FFFFFFF0	; demo mode flag (0 = no; 1 = yes; $8001 = ending) (2 bytes)
v_demonum:	equ $FFFFFFF2	; demo level number (not the same as the level number) (2 bytes)
v_creditsnum:	equ $FFFFFFF4	; credits index number (2 bytes)
v_megadrive:	equ $FFFFFFF8	; Megadrive machine type
f_debugmode:	equ $FFFFFFFA	; debug mode flag (sometimes 2 bytes)
v_init:		equ $FFFFFFFC	; 'init' text string (4 bytes)
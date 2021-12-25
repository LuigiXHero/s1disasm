; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debug_active_hi).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jmp	Debug_Index(pc,d1.w)
; ===========================================================================
Debug_Index:	index *
		ptr Debug_Main
		ptr Debug_Action
; ===========================================================================

Debug_Main:	; Routine 0
		addq.b	#2,(v_debug_active_hi).w
		move.w	(v_boundary_top).w,(v_boundary_top_debugcopy).w ; buffer level top boundary
		move.w	(v_boundary_bottom_next).w,(v_boundary_bottom_debugcopy).w ; buffer level bottom boundary
		move.w	#0,(v_boundary_top).w
		move.w	#$720,(v_boundary_bottom_next).w	; set new boundaries
		andi.w	#$7FF,(v_ost_player+ost_y_pos).w
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		move.b	#0,ost_frame(a0)
		move.b	#0,ost_anim(a0)
		cmpi.b	#id_Special,(v_gamemode).w		; is game mode $10 (special stage)?
		bne.s	@islevel				; if not, branch

		move.w	#0,(v_ss_rotation_speed).w		; stop special stage rotating
		move.w	#0,(v_ss_angle).w			; make special stage "upright"
		moveq	#6,d0					; use 6th debug	item list
		bra.s	@selectlist
; ===========================================================================

@islevel:
		moveq	#0,d0
		move.b	(v_zone).w,d0

@selectlist:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2				; get address of debug list
		move.w	(a2)+,d6				; get number of items in list
		cmp.b	(v_debug_item_index).w,d6		; have you gone past the last item?
		bhi.s	@noreset				; if not, branch
		move.b	#0,(v_debug_item_index).w		; back to start of list

	@noreset:
		bsr.w	Debug_GetFrame				; get mappings, VRAM & frame id from debug list
		move.b	#12,(v_debug_move_delay).w
		move.b	#1,(v_debug_move_speed).w

Debug_Action:	; Routine 2
		moveq	#6,d0
		cmpi.b	#id_Special,(v_gamemode).w
		beq.s	@isntlevel

		moveq	#0,d0
		move.b	(v_zone).w,d0

	@isntlevel:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2				; get address of debug list
		move.w	(a2)+,d6				; get number of items in list
		bsr.w	Debug_Control
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine for controls while debug is in use

; input:
;	d6 = number of items in debug list
;	a2 = address of first item in debug list
; ---------------------------------------------------------------------------

Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(v_joypad_press_actual).w,d4
		andi.w	#btnDir,d4				; is up/down/left/right	pressed?
		bne.s	@dirpressed				; if yes, branch

		move.b	(v_joypad_hold_actual).w,d0
		andi.w	#btnDir,d0				; is up/down/left/right	held?
		bne.s	@dirheld				; if yes, branch

		move.b	#12,(v_debug_move_delay).w
		move.b	#15,(v_debug_move_speed).w
		bra.w	Debug_ChgItem
; ===========================================================================

@dirheld:
		subq.b	#1,(v_debug_move_delay).w		; decrement timer
		bne.s	@chk_up					; if not 0, branch
		move.b	#1,(v_debug_move_delay).w		; set delay timer to 1 frame
		addq.b	#1,(v_debug_move_speed).w		; increment speed
		bne.s	@dirpressed				; if not 0, branch
		move.b	#-1,(v_debug_move_speed).w

@dirpressed:
		move.b	(v_joypad_hold_actual).w,d4

	@chk_up:
		moveq	#0,d1
		move.b	(v_debug_move_speed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1					; d1 = speed * $1000
		move.l	ost_y_pos(a0),d2
		move.l	ost_x_pos(a0),d3
		btst	#bitUp,d4				; is up	being held?
		beq.s	@chk_down				; if not, branch
		sub.l	d1,d2					; move Sonic up
		bcc.s	@chk_down
		moveq	#0,d2					; keep Sonic within top boundary

	@chk_down:
		btst	#bitDn,d4				; is down being held?
		beq.s	@chk_left				; if not, branch
		add.l	d1,d2					; move Sonic down
		cmpi.l	#$7FF0000,d2				; is Sonic above $7FF? (bottom boundary)
		bcs.s	@chk_left				; if yes, branch
		move.l	#$7FF0000,d2				; keep Sonic within bottom boundary

	@chk_left:
		btst	#bitL,d4				; is left being held?
		beq.s	@chk_right				; if not, branch
		sub.l	d1,d3					; move Sonic left
		bcc.s	@chk_right
		moveq	#0,d3					; keep Sonic within left boundary

	@chk_right:
		btst	#bitR,d4				; is right being held?
		beq.s	@update_pos				; if not, branch
		add.l	d1,d3					; move Sonic right (no boundary check for right side)

	@update_pos:
		move.l	d2,ost_y_pos(a0)
		move.l	d3,ost_x_pos(a0)

Debug_ChgItem:
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	@createitem				; if not, branch
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	@nextitem				; if not, branch

		subq.b	#1,(v_debug_item_index).w		; go back 1 item
		bcc.s	@display				; if item is 0 or higher, branch
		add.b	d6,(v_debug_item_index).w		; if item is -1, loop to last item
		bra.s	@display
; ===========================================================================

@nextitem:
		btst	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	@createitem				; if not, branch
		addq.b	#1,(v_debug_item_index).w		; go forwards 1 item
		cmp.b	(v_debug_item_index).w,d6
		bhi.s	@display
		move.b	#0,(v_debug_item_index).w		; loop back to first item

	@display:
		bra.w	Debug_GetFrame
; ===========================================================================

@createitem:
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	@backtonormal				; if not, branch
		jsr	(FindFreeObj).l
		bne.s	@backtonormal
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_mappings(a0),0(a1)			; create object (object id is held in high byte of mappings pointer)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_render(a0),ost_status(a1)
		andi.b	#$FF-status_onscreen,ost_status(a1)	; remove onscreen flag from status
		moveq	#0,d0
		move.b	(v_debug_item_index).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),ost_subtype(a1)		; get subtype from debug list
		rts	
; ===========================================================================

@backtonormal:
		btst	#bitB,(v_joypad_press_actual).w		; is button B pressed?
		beq.s	@stayindebug				; if not, branch
		moveq	#0,d0
		move.w	d0,(v_debug_active).w			; deactivate debug mode
		move.l	#Map_Sonic,(v_ost_player+ost_mappings).w
		move.w	#vram_sonic/$20,(v_ost_player+ost_tile).w
		move.b	d0,(v_ost_player+ost_anim).w
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_y_sub(a0)
		move.w	(v_boundary_top_debugcopy).w,(v_boundary_top).w ; restore level boundaries
		move.w	(v_boundary_bottom_debugcopy).w,(v_boundary_bottom_next).w
		cmpi.b	#id_Special,(v_gamemode).w		; are you in the special stage?
		bne.s	@stayindebug				; if not, branch

		clr.w	(v_ss_angle).w
		move.w	#$40,(v_ss_rotation_speed).w		; set new level rotation speed
		move.l	#Map_Sonic,(v_ost_player+ost_mappings).w
		move.w	#vram_sonic/$20,(v_ost_player+ost_tile).w
		move.b	#id_Roll,(v_ost_player+ost_anim).w
		bset	#status_jump_bit,(v_ost_player+ost_status).w
		bset	#status_air_bit,(v_ost_player+ost_status).w

	@stayindebug:
		rts	
; End of function Debug_Control

; ---------------------------------------------------------------------------
; Subroutine to get mappings, VRAM & frame info from debug list
; ---------------------------------------------------------------------------

Debug_GetFrame:
		moveq	#0,d0
		move.b	(v_debug_item_index).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),ost_mappings(a0)		; load mappings for item
		move.w	6(a2,d0.w),ost_tile(a0)			; load VRAM setting for item
		move.b	5(a2,d0.w),ost_frame(a0)		; load frame number for item
		rts	
; End of function Debug_GetFrame

; ---------------------------------------------------------------------------
; Debug	mode item lists
; ---------------------------------------------------------------------------

DebugList:	index *
		ptr @GHZ
		ptr @LZ
		ptr @MZ
		ptr @SLZ
		ptr @SYZ
		ptr @SBZ
		zonewarning DebugList,2
		ptr @Ending

dbug:		macro map,object,subtype,frame,vram
		dc.l map+(id_\object<<24)
		dc.b subtype,frame
		dc.w vram
		endm

@GHZ:
		dc.w (@GHZend-@GHZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug 	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Crab,	Crabmeat,	0,	0,	tile_Nem_Crabmeat
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Nem_Buzz
		dbug	Map_Chop,	Chopper,	0,	0,	tile_Nem_Chopper
		dbug	Map_Spike,	Spikes,		0,	0,	tile_Nem_Spikes
		dbug	Map_Plat_GHZ,	BasicPlatform,	0,	0,	0+tile_pal3
		dbug	Map_PRock,	PurpleRock,	0,	0,	tile_Nem_PplRock+tile_pal4
		dbug	Map_Moto,	MotoBug,	0,	0,	tile_Nem_Motobug
		dbug	Map_Spring,	Springs,	0,	0,	tile_Nem_HSpring
		dbug	Map_Newt,	Newtron,	0,	0,	tile_Nem_Newtron+tile_pal2
		dbug	Map_Edge,	EdgeWalls,	0,	0,	tile_Nem_GhzWall2+tile_pal3
		dbug	Map_GBall,	Obj19,		0,	0,	tile_Nem_Ball+tile_pal3
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
		dbug	Map_GRing,	GiantRing,	0,	0,	$400+tile_pal2
		dbug	Map_Bonus,	HiddenBonus,	1,	id_frame_bonus_10000,	tile_Nem_Bonus+tile_hi
	@GHZend:

@LZ:
		dc.w (@LZend-@LZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Spring,	Springs,	0,	0,	tile_Nem_HSpring
		dbug	Map_Jaws,	Jaws,		8,	0,	tile_Nem_Jaws+tile_pal2
		dbug	Map_Burro,	Burrobot,	0,	id_frame_burro_dig1,	tile_Nem_Burrobot+tile_hi
		dbug	Map_Harp,	Harpoon,	0,	id_frame_harp_h_retracted,	tile_Nem_Harpoon
		dbug	Map_Harp,	Harpoon,	2,	id_frame_harp_v_retracted,	tile_Nem_Harpoon
		dbug	Map_Push,	PushBlock,	0,	0,	tile_Nem_LzPole+tile_pal3
		dbug	Map_But,	Button,		0,	0,	$513
		dbug	Map_Spike,	Spikes,		0,	0,	tile_Nem_Spikes
		dbug	Map_MBlockLZ,	MovingBlock,	4,	0,	tile_Nem_LzBlock3+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, 1,	id_frame_lblock_sinkblock,	tile_Nem_LzDoor2+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, $13,	id_frame_lblock_riseplatform,	tile_Nem_LzDoor2+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, 5,	id_frame_lblock_sinkblock,	tile_Nem_LzDoor2+tile_pal3
		dbug	Map_Gar,	Gargoyle,	0,	0,	$43E+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, $27,	id_frame_lblock_cork,	tile_Nem_LzDoor2+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, $30,	id_frame_lblock_block,	tile_Nem_LzDoor2+tile_pal3
		dbug	Map_LConv,	LabyrinthConvey, $7F,	0,	tile_Nem_LzWheel
		dbug	Map_Orb,	Orbinaut,	0,	0,	tile_Nem_Orbinaut_LZ
		dbug	Map_Bub,	Bubble,		$84,	id_frame_bubble_bubmaker1,	tile_Nem_Bubbles+tile_hi
		dbug	Map_WFall,	Waterfall,	2,	id_frame_wfall_cornermedium,	tile_Nem_Splash+tile_pal3+tile_hi
		dbug	Map_WFall,	Waterfall,	9,	id_frame_wfall_splash1,	tile_Nem_Splash+tile_pal3+tile_hi
		dbug	Map_Pole,	Pole,		0,	0,	tile_Nem_LzPole+tile_pal3
		dbug	Map_Flap,	FlapDoor,	2,	0,	tile_Nem_FlapDoor+tile_pal3
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
	@LZend:

@MZ:
		dc.w (@MZend-@MZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Nem_Buzz
		dbug	Map_Spike,	Spikes,		0,	0,	tile_Nem_Spikes
		dbug	Map_Spring,	Springs,	0,	0,	tile_Nem_HSpring
		dbug	Map_Fire,	LavaMaker,	0,	0,	tile_Nem_Fireball
		dbug	Map_Brick,	MarbleBrick,	0,	0,	0+tile_pal3
		dbug	Map_Geyser,	GeyserMaker,	0,	0,	tile_Nem_Lava+tile_pal4
		dbug	Map_LWall,	LavaWall,	0,	0,	tile_Nem_Lava+tile_pal4
		dbug	Map_Push,	PushBlock,	0,	0,	tile_Nem_MzBlock+tile_pal3
		dbug	Map_Yad,	Yadrin,		0,	0,	tile_Nem_Yadrin+tile_pal2
		dbug	Map_Smab,	SmashBlock,	0,	0,	tile_Nem_MzBlock+tile_pal3
		dbug	Map_MBlock,	MovingBlock,	0,	0,	tile_Nem_MzBlock
		dbug	Map_CFlo,	CollapseFloor,	0,	0,	tile_Nem_MzBlock+tile_pal4
		dbug	Map_LTag,	LavaTag,	0,	0,	tile_Nem_Monitors+tile_hi
		dbug	Map_Bat,	Batbrain,	0,	0,	tile_Nem_Batbrain
		dbug	Map_Cat,	Caterkiller,	0,	0,	tile_Nem_Cater+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
	@MZend:

@SLZ:
		dc.w (@SLZend-@SLZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Elev,	Elevator,	0,	0,	0+tile_pal3
		dbug	Map_CFlo,	CollapseFloor,	0,	id_frame_cfloor_slz,	tile_Nem_SlzBlock+tile_pal3
		dbug	Map_Plat_SLZ,	BasicPlatform,	0,	0,	0+tile_pal3
		dbug	Map_Circ,	CirclingPlatform, 0,	0,	0+tile_pal3
		dbug	Map_Stair,	Staircase,	0,	0,	0+tile_pal3
		dbug	Map_Fan,	Fan,		0,	0,	tile_Nem_Fan+tile_pal3
		dbug	Map_Seesaw,	Seesaw,		0,	0,	tile_Nem_Seesaw
		dbug	Map_Spring,	Springs,	0,	0,	tile_Nem_HSpring
		dbug	Map_Fire,	LavaMaker,	0,	0,	tile_Nem_Fireball_SLZ
		dbug	Map_Scen,	Scenery,	0,	0,	tile_Nem_SlzCannon+tile_pal3
		dbug	Map_Bomb,	Bomb,		0,	0,	tile_Nem_Bomb
		dbug	Map_Orb,	Orbinaut,	0,	0,	tile_Nem_Orbinaut+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
	@SLZend:

@SYZ:
		dc.w (@SYZend-@SYZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Spike,	Spikes,		0,	0,	tile_Nem_Spikes
		dbug	Map_Spring,	Springs,	0,	0,	tile_Nem_HSpring
		dbug	Map_Roll,	Roller,		0,	0,	tile_Nem_Roller
		dbug	Map_Light,	SpinningLight,	0,	0,	0
		dbug	Map_Bump,	Bumper,		0,	0,	tile_Nem_Bumper
		dbug	Map_Crab,	Crabmeat,	0,	0,	tile_Nem_Crabmeat
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Nem_Buzz
		dbug	Map_Yad,	Yadrin,		0,	0,	tile_Nem_Yadrin+tile_pal2
		dbug	Map_Plat_SYZ,	BasicPlatform,	0,	0,	0+tile_pal3
		dbug	Map_FBlock,	FloatingBlock,	0,	0,	0+tile_pal3
		dbug	Map_But,	Button,		0,	0,	$513
		dbug	Map_Cat,	Caterkiller,	0,	0,	tile_Nem_Cater+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
	@SYZend:

@SBZ:
		dc.w (@SBZend-@SBZ-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Nem_Monitors
		dbug	Map_Bomb,	Bomb,		0,	0,	tile_Nem_Bomb
		dbug	Map_Orb,	Orbinaut,	0,	0,	tile_Nem_Orbinaut
		dbug	Map_Cat,	Caterkiller,	0,	0,	tile_Nem_Cater_SBZ+tile_pal2
		dbug	Map_BBall,	SwingingPlatform, 7,	id_frame_bball_anchor,	tile_Nem_BigSpike_SBZ+tile_pal3
		dbug	Map_Disc,	RunningDisc,	$E0,	0,	tile_Nem_SbzWheel1+tile_pal3+tile_hi
		dbug	Map_MBlock,	MovingBlock,	$28,	id_frame_mblock_sbz,	tile_Nem_Stomper+tile_pal2
		dbug	Map_But,	Button,		0,	0,	$513
		dbug	Map_Trap,	SpinPlatform,	3,	0,	tile_Nem_TrapDoor+tile_pal3
		dbug	Map_Spin,	SpinPlatform,	$83,	0,	tile_Nem_SpinPform
		dbug	Map_Saw,	Saws,		2,	0,	tile_Nem_Cutter+tile_pal3
		dbug	Map_CFlo,	CollapseFloor,	0,	0,	tile_Nem_SbzFloor+tile_pal3
		dbug	Map_MBlock,	MovingBlock,	$39,	id_frame_mblock_sbzwide,	tile_Nem_SlideFloor+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	0,	id_frame_stomp_door,	tile_Nem_Stomper+tile_pal2
		dbug	Map_ADoor,	AutoDoor,	0,	0,	tile_Nem_SbzDoor1+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	$13,	id_frame_stomp_stomper,	tile_Nem_Stomper+tile_pal2
		dbug	Map_Saw,	Saws,		1,	id_frame_saw_pizzacutter1,	tile_Nem_Cutter+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	$24,	id_frame_stomp_stomper,	tile_Nem_Stomper+tile_pal2
		dbug	Map_Saw,	Saws,		4,	id_frame_saw_groundsaw1,	tile_Nem_Cutter+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	$34,	id_frame_stomp_stomper,	tile_Nem_Stomper+tile_pal2
		dbug	Map_VanP,	VanishPlatform, 0,	0,	tile_Nem_SbzBlock+tile_pal3
		dbug	Map_Flame,	Flamethrower,	$64,	id_frame_flame_pipe1,	tile_Nem_FlamePipe+tile_hi
		dbug	Map_Flame,	Flamethrower,	$64,	id_frame_flame_valve1,	tile_Nem_FlamePipe+tile_hi
		dbug	Map_Elec,	Electro,	4,	0,	tile_Nem_Electric
		dbug	Map_Gird,	Girder,		0,	0,	tile_Nem_Girder+tile_pal3
		dbug	Map_Invis,	Invisibarrier,	$11,	0,	tile_Nem_Monitors+tile_hi
		dbug	Map_Hog,	BallHog,	4,	0,	tile_Nem_BallHog+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Nem_Lamp
	@SBZend:

@Ending:
		dc.w (@Endingend-@Ending-2)/8

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Nem_Ring+tile_pal2
	if Revision=0
		dbug	Map_Bump,	Bumper,		0,	0,	$380
		dbug	Map_Animal2,	Animals,	$A,	0,	$5A0
		dbug	Map_Animal2,	Animals,	$B,	0,	$5A0
		dbug	Map_Animal2,	Animals,	$C,	0,	$5A0
		dbug	Map_Animal1,	Animals,	$D,	0,	$553
		dbug	Map_Animal1,	Animals,	$E,	0,	$553
		dbug	Map_Animal1,	Animals,	$F,	0,	$573
		dbug	Map_Animal1,	Animals,	$10,	0,	$573
		dbug	Map_Animal2,	Animals,	$11,	0,	$585
		dbug	Map_Animal3,	Animals,	$12,	0,	$593
		dbug	Map_Animal2,	Animals,	$13,	0,	$565
		dbug	Map_Animal3,	Animals,	$14,	0,	$5B3
	else
		dbug	Map_Ring,	Rings,		0,	id_frame_ring_blank,	tile_Nem_Ring+tile_pal2
	endc
	@Endingend:

		even

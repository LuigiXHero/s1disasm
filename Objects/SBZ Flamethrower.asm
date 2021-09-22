; ---------------------------------------------------------------------------
; Object 6D - flame thrower (SBZ)
; ---------------------------------------------------------------------------

Flamethrower:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Flame_Index(pc,d0.w),d1
		jmp	Flame_Index(pc,d1.w)
; ===========================================================================
Flame_Index:	index *,,2
		ptr Flame_Main
		ptr Flame_Action

ost_flame_time:		equ $30	; time until current action is complete (2 bytes)
ost_flame_on_master:	equ $32	; time flame is on (2 bytes)
ost_flame_off_master:	equ $34	; time flame is off (2 bytes)
ost_flame_last_frame:	equ $36	; last frame of animation
; ===========================================================================

Flame_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.l	#Map_Flame,ost_mappings(a0)
		move.w	#tile_Nem_FlamePipe+tile_hi,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#1,ost_priority(a0)
		move.w	ost_y_pos(a0),ost_flame_time(a0) ; store ost_y_pos (gets overwritten later though)
		move.b	#$C,ost_actwidth(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0		; read 1st digit of object type
		add.w	d0,d0		; multiply by 2
		move.w	d0,ost_flame_time(a0)
		move.w	d0,ost_flame_on_master(a0) ; set flaming time
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0		; read 2nd digit of object type
		lsl.w	#5,d0		; multiply by $20
		move.w	d0,ost_flame_off_master(a0) ; set pause time
		move.b	#$A,ost_flame_last_frame(a0)
		btst	#status_yflip_bit,ost_status(a0)
		beq.s	Flame_Action
		move.b	#id_ani_flame_valve_on,ost_anim(a0)
		move.b	#$15,ost_flame_last_frame(a0)

Flame_Action:	; Routine 2
		subq.w	#1,ost_flame_time(a0) ; subtract 1 from time
		bpl.s	loc_E57A	; if time remains, branch
		move.w	ost_flame_off_master(a0),ost_flame_time(a0) ; begin pause time
		bchg	#0,ost_anim(a0)
		beq.s	loc_E57A
		move.w	ost_flame_on_master(a0),ost_flame_time(a0) ; begin flaming time
		sfx	sfx_Flamethrower,0,0,0 ; play flame sound

loc_E57A:
		lea	(Ani_Flame).l,a1
		bsr.w	AnimateSprite
		move.b	#0,ost_col_type(a0)
		move.b	ost_flame_last_frame(a0),d0
		cmp.b	ost_frame(a0),d0
		bne.s	Flame_ChkDel
		move.b	#$A3,ost_col_type(a0)

Flame_ChkDel:
		out_of_range	DeleteObject
		bra.w	DisplaySprite

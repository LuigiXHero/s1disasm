; ---------------------------------------------------------------------------
; Object 5A - platforms	moving in circles (SLZ)
; ---------------------------------------------------------------------------

CirclingPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Circ_Index(pc,d0.w),d1
		jsr	Circ_Index(pc,d1.w)
		out_of_range	DeleteObject,ost_circ_x_start(a0)
		bra.w	DisplaySprite
; ===========================================================================
Circ_Index:	index *,,2
		ptr Circ_Main
		ptr Circ_Platform
		ptr Circ_Action

ost_circ_y_start:	equ $30					; original y-axis position (2 bytes)
ost_circ_x_start:	equ $32					; original x-axis position (2 bytes)
; ===========================================================================

Circ_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.l	#Map_Circ,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$18,ost_actwidth(a0)
		move.w	ost_x_pos(a0),ost_circ_x_start(a0)
		move.w	ost_y_pos(a0),ost_circ_y_start(a0)

Circ_Platform:	; Routine 2
		moveq	#0,d1
		move.b	ost_actwidth(a0),d1
		jsr	(DetectPlatform).l
		bra.w	Circ_Types
; ===========================================================================

Circ_Action:	; Routine 4
		moveq	#0,d1
		move.b	ost_actwidth(a0),d1
		jsr	(ExitPlatform).l
		move.w	ost_x_pos(a0),-(sp)
		bsr.w	Circ_Types
		move.w	(sp)+,d2
		jmp	(MoveWithPlatform2).l
; ===========================================================================

Circ_Types:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		andi.w	#$C,d0
		lsr.w	#1,d0
		move.w	@index(pc,d0.w),d1
		jmp	@index(pc,d1.w)
; ===========================================================================
@index:		index *
		ptr @type00
		ptr @type04
; ===========================================================================

@type00:
		move.b	(v_oscillating_table+$20).w,d1		; get rotating value
		subi.b	#$50,d1					; set radius of circle
		ext.w	d1
		move.b	(v_oscillating_table+$24).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,ost_subtype(a0)
		beq.s	@noshift00a
		neg.w	d1
		neg.w	d2

	@noshift00a:
		btst	#1,ost_subtype(a0)
		beq.s	@noshift00b
		neg.w	d1
		exg	d1,d2

	@noshift00b:
		add.w	ost_circ_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		add.w	ost_circ_y_start(a0),d2
		move.w	d2,ost_y_pos(a0)
		rts	
; ===========================================================================

@type04:
		move.b	(v_oscillating_table+$20).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	(v_oscillating_table+$24).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,ost_subtype(a0)
		beq.s	@noshift04a
		neg.w	d1
		neg.w	d2

	@noshift04a:
		btst	#1,ost_subtype(a0)
		beq.s	@noshift04b
		neg.w	d1
		exg	d1,d2

	@noshift04b:
		neg.w	d1
		add.w	ost_circ_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		add.w	ost_circ_y_start(a0),d2
		move.w	d2,ost_y_pos(a0)
		rts	

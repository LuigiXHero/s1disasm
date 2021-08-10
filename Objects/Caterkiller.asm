; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)
; ---------------------------------------------------------------------------

		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cat_Index(pc,d0.w),d1
		jmp	Cat_Index(pc,d1.w)
; ===========================================================================
Cat_Index:	index *,,2
		ptr Cat_Main
		ptr Cat_Head
		ptr Cat_BodySeg1
		ptr Cat_BodySeg2
		ptr Cat_BodySeg1
		ptr Cat_Delete
		ptr loc_16CC0

cat_parent:	equ $3C		; address of parent object
; ===========================================================================

locret_16950:
		rts	
; ===========================================================================

Cat_Main:	; Routine 0
		move.b	#7,ost_height(a0)
		move.b	#8,ost_width(a0)
		jsr	(ObjectFall).l
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_16950
		add.w	d1,ost_y_pos(a0)
		clr.w	ost_y_vel(a0)
		addq.b	#2,ost_routine(a0)
		move.l	#Map_Cat,ost_mappings(a0)
		move.w	#tile_Nem_Cater_SBZ+tile_pal2,ost_tile(a0)
		cmpi.b	#id_SBZ,(v_zone).w ; if level is SBZ, branch
		beq.s	@isscrapbrain
		move.w	#tile_Nem_Cater+tile_pal2,ost_tile(a0) ; MZ specific code

	@isscrapbrain:
		andi.b	#3,ost_render(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	ost_render(a0),ost_status(a0)
		move.b	#4,ost_priority(a0)
		move.b	#8,ost_actwidth(a0)
		move.b	#$B,ost_col_type(a0)
		move.w	ost_x_pos(a0),d2
		moveq	#$C,d5
		btst	#0,ost_status(a0)
		beq.s	@noflip
		neg.w	d5

	@noflip:
		move.b	#4,d6
		moveq	#0,d3
		moveq	#4,d4
		movea.l	a0,a2
		moveq	#2,d1

Cat_Loop:
		jsr	(FindNextFreeObj).l
		if Revision=0
		bne.s	@fail
		else
			bne.w	Cat_ChkGone
		endc
		move.b	#id_Caterkiller,0(a1) ; load body segment object
		move.b	d6,ost_routine(a1) ; goto Cat_BodySeg1 or Cat_BodySeg2 next
		addq.b	#2,d6		; alternate between the two
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	#5,ost_priority(a1)
		move.b	#8,ost_actwidth(a1)
		move.b	#$CB,ost_col_type(a1)
		add.w	d5,d2
		move.w	d2,ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	ost_status(a0),ost_render(a1)
		move.b	#8,ost_frame(a1)
		move.l	a2,cat_parent(a1)
		move.b	d4,cat_parent(a1)
		addq.b	#4,d4
		movea.l	a1,a2

	@fail:
		dbf	d1,Cat_Loop	; repeat sequence 2 more times

		move.b	#7,$2A(a0)
		clr.b	cat_parent(a0)

Cat_Head:	; Routine 2
		tst.b	ost_status(a0)
		bmi.w	loc_16C96
		moveq	#0,d0
		move.b	ost_routine2(a0),d0
		move.w	Cat_Index2(pc,d0.w),d1
		jsr	Cat_Index2(pc,d1.w)
		move.b	$2B(a0),d1
		bpl.s	@display
		lea	(Ani_Cat).l,a1
		move.b	ost_angle(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,ost_angle(a0)
		move.b	(a1,d0.w),d0
		bpl.s	@animate
		bclr	#7,$2B(a0)
		bra.s	@display

	@animate:
		andi.b	#$10,d1
		add.b	d1,d0
		move.b	d0,ost_frame(a0)

	@display:
		out_of_range	Cat_ChkGone
		jmp	(DisplaySprite).l

	Cat_ChkGone:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	@delete
		bclr	#7,2(a2,d0.w)

	@delete:
		move.b	#$A,ost_routine(a0)	; goto Cat_Delete next
		rts	
; ===========================================================================

Cat_Delete:	; Routine $A
		jmp	(DeleteObject).l
; ===========================================================================
Cat_Index2:	index *
		ptr @wait
		ptr loc_16B02
; ===========================================================================

@wait:
		subq.b	#1,$2A(a0)
		bmi.s	@move
		rts	
; ===========================================================================

@move:
		addq.b	#2,ost_routine2(a0)
		move.b	#$10,$2A(a0)
		move.w	#-$C0,ost_x_vel(a0)
		move.w	#$40,ost_inertia(a0)
		bchg	#4,$2B(a0)
		bne.s	loc_16AFC
		clr.w	ost_x_vel(a0)
		neg.w	ost_inertia(a0)

loc_16AFC:
		bset	#7,$2B(a0)

loc_16B02:
		subq.b	#1,$2A(a0)
		bmi.s	@loc_16B5E
		if Revision=0
		move.l	ost_x_pos(a0),-(sp)
		move.l	ost_x_pos(a0),d2
		else
			tst.w	ost_x_vel(a0)
			beq.s	@notmoving
			move.l	ost_x_pos(a0),d2
			move.l	d2,d3
		endc
		move.w	ost_x_vel(a0),d0
		btst	#0,ost_status(a0)
		beq.s	@noflip
		neg.w	d0

	@noflip:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,ost_x_pos(a0)
		if Revision=0
		jsr	(ObjFloorDist).l
		move.l	(sp)+,d2
		cmpi.w	#-8,d1
		blt.s	@loc_16B70
		cmpi.w	#$C,d1
		bge.s	@loc_16B70
		add.w	d1,ost_y_pos(a0)
		swap	d2
		cmp.w	ost_x_pos(a0),d2
		beq.s	@notmoving
		else
			swap	d3
			cmp.w	ost_x_pos(a0),d3
			beq.s	@notmoving
			jsr	(ObjFloorDist).l
			cmpi.w	#-8,d1
			blt.s	@loc_16B70
			cmpi.w	#$C,d1
			bge.s	@loc_16B70
			add.w	d1,ost_y_pos(a0)
		endc
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		move.b	d1,$2C(a0,d0.w)

	@notmoving:
		rts	
; ===========================================================================

@loc_16B5E:
		subq.b	#2,ost_routine2(a0)
		move.b	#7,$2A(a0)
		if Revision=0
		move.w	#0,ost_x_vel(a0)
		else
			clr.w	ost_x_vel(a0)
			clr.w	ost_inertia(a0)
		endc
		rts	
; ===========================================================================

@loc_16B70:
		if Revision=0
		move.l	d2,ost_x_pos(a0)
		bchg	#0,ost_status(a0)
		move.b	ost_status(a0),ost_render(a0)
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		move.b	#$80,$2C(a0,d0.w)
		else
			moveq	#0,d0
			move.b	cat_parent(a0),d0
			move.b	#$80,$2C(a0,d0)
			neg.w	ost_x_pos+2(a0)
			beq.s	@loc_1730A
			btst	#0,ost_status(a0)
			beq.s	@loc_1730A
			subq.w	#1,ost_x_pos(a0)
			addq.b	#1,cat_parent(a0)
			moveq	#0,d0
			move.b	cat_parent(a0),d0
			clr.b	$2C(a0,d0)
	@loc_1730A:
			bchg	#0,ost_status(a0)
			move.b	ost_status(a0),ost_render(a0)
		endc
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		rts	
; ===========================================================================

Cat_BodySeg2:	; Routine 6
		movea.l	cat_parent(a0),a1
		move.b	$2B(a1),$2B(a0)
		bpl.s	Cat_BodySeg1
		lea	(Ani_Cat).l,a1
		move.b	ost_angle(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,ost_angle(a0)
		tst.b	4(a1,d0.w)
		bpl.s	Cat_AniBody
		addq.b	#4,ost_angle(a0)

Cat_AniBody:
		move.b	(a1,d0.w),d0
		addq.b	#8,d0
		move.b	d0,ost_frame(a0)

Cat_BodySeg1:	; Routine 4, 8
		movea.l	cat_parent(a0),a1
		tst.b	ost_status(a0)
		bmi.w	loc_16C90
		move.b	$2B(a1),$2B(a0)
		move.b	ost_routine2(a1),ost_routine2(a0)
		beq.w	loc_16C64
		move.w	ost_inertia(a1),ost_inertia(a0)
		move.w	ost_x_vel(a1),d0
		if Revision=0
		add.w	ost_inertia(a1),d0
		else
			add.w	ost_inertia(a0),d0
		endc
		move.w	d0,ost_x_vel(a0)
		move.l	ost_x_pos(a0),d2
		move.l	d2,d3
		move.w	ost_x_vel(a0),d0
		btst	#0,ost_status(a0)
		beq.s	loc_16C0C
		neg.w	d0

loc_16C0C:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,ost_x_pos(a0)
		swap	d3
		cmp.w	ost_x_pos(a0),d3
		beq.s	loc_16C64
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		move.b	$2C(a1,d0.w),d1
		cmpi.b	#$80,d1
		bne.s	loc_16C50
		if Revision=0
		swap	d3
		move.l	d3,ost_x_pos(a0)
		move.b	d1,$2C(a0,d0.w)
		else
			move.b	d1,$2C(a0,d0)
			neg.w	ost_x_pos+2(a0)
			beq.s	locj_173E4
			btst	#0,ost_status(a0)
			beq.s	locj_173E4
			cmpi.w	#-$C0,ost_x_vel(a0)
			bne.s	locj_173E4
			subq.w	#1,ost_x_pos(a0)
			addq.b	#1,cat_parent(a0)
			moveq	#0,d0
			move.b	cat_parent(a0),d0
			clr.b	$2C(a0,d0)
	locj_173E4:
		endc
		bchg	#0,ost_status(a0)
		move.b	ost_status(a0),1(a0)
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		bra.s	loc_16C64
; ===========================================================================

loc_16C50:
		ext.w	d1
		add.w	d1,ost_y_pos(a0)
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		move.b	d1,$2C(a0,d0.w)

loc_16C64:
		cmpi.b	#$C,ost_routine(a1)
		beq.s	loc_16C90
		cmpi.b	#id_ExplosionItem,0(a1)
		beq.s	loc_16C7C
		cmpi.b	#$A,ost_routine(a1)
		bne.s	loc_16C82

loc_16C7C:
		move.b	#$A,ost_routine(a0)

loc_16C82:
		jmp	(DisplaySprite).l

; ===========================================================================
Cat_FragSpeed:	dc.w -$200, -$180, $180, $200
; ===========================================================================

loc_16C90:
		bset	#7,ost_status(a1)

loc_16C96:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cat_FragSpeed-2(pc,d0.w),d0
		btst	#0,ost_status(a0)
		beq.s	loc_16CAA
		neg.w	d0

loc_16CAA:
		move.w	d0,ost_x_vel(a0)
		move.w	#-$400,ost_y_vel(a0)
		move.b	#$C,ost_routine(a0)
		andi.b	#$F8,ost_frame(a0)

loc_16CC0:	; Routine $C
		jsr	(ObjectFall).l
		tst.w	ost_y_vel(a0)
		bmi.s	loc_16CE0
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	loc_16CE0
		add.w	d1,ost_y_pos(a0)
		move.w	#-$400,ost_y_vel(a0)

loc_16CE0:
		tst.b	ost_render(a0)
		bpl.w	Cat_ChkGone
		jmp	(DisplaySprite).l

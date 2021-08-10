; ---------------------------------------------------------------------------
; Object 72 - teleporter (SBZ)
; ---------------------------------------------------------------------------

		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Tele_Index(pc,d0.w),d1
		jsr	Tele_Index(pc,d1.w)
		out_of_range.s	@delete
		rts	

	@delete:
		jmp	(DeleteObject).l
; ===========================================================================
Tele_Index:	index *,,2
		ptr Tele_Main
		ptr loc_166C8
		ptr loc_1675E
		ptr loc_16798
; ===========================================================================

Tele_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Tele_Data(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,$3A(a0)
		move.l	a2,$3C(a0)
		move.w	(a2)+,$36(a0)
		move.w	(a2)+,$38(a0)

loc_166C8:	; Routine 2
		lea	(v_player).w,a1
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0
		btst	#0,ost_status(a0)
		beq.s	loc_166E0
		addi.w	#$F,d0

loc_166E0:
		cmpi.w	#$10,d0
		bcc.s	locret_1675C
		move.w	ost_y_pos(a1),d1
		sub.w	ost_y_pos(a0),d1
		addi.w	#$20,d1
		cmpi.w	#$40,d1
		bcc.s	locret_1675C
		tst.b	(f_lockmulti).w
		bne.s	locret_1675C
		cmpi.b	#7,ost_subtype(a0)
		bne.s	loc_1670E
		cmpi.w	#50,(v_rings).w
		bcs.s	locret_1675C

loc_1670E:
		addq.b	#2,ost_routine(a0)
		move.b	#$81,(f_lockmulti).w ; lock controls
		move.b	#id_Roll,ost_anim(a1) ; use Sonic's rolling animation
		move.w	#$800,ost_inertia(a1)
		move.w	#0,ost_x_vel(a1)
		move.w	#0,ost_y_vel(a1)
		bclr	#5,ost_status(a0)
		bclr	#5,ost_status(a1)
		bset	#1,ost_status(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		clr.b	$32(a0)
		sfx	sfx_Roll,0,0,0	; play Sonic rolling sound

locret_1675C:
		rts	
; ===========================================================================

loc_1675E:	; Routine 4
		lea	(v_player).w,a1
		move.b	$32(a0),d0
		addq.b	#2,$32(a0)
		jsr	(CalcSine).l
		asr.w	#5,d0
		move.w	ost_y_pos(a0),d2
		sub.w	d0,d2
		move.w	d2,ost_y_pos(a1)
		cmpi.b	#$80,$32(a0)
		bne.s	locret_16796
		bsr.w	sub_1681C
		addq.b	#2,ost_routine(a0)
		sfx	sfx_Teleport,0,0,0	; play teleport sound

locret_16796:
		rts	
; ===========================================================================

loc_16798:	; Routine 6
		addq.l	#4,sp
		lea	(v_player).w,a1
		subq.b	#1,$2E(a0)
		bpl.s	loc_167DA
		move.w	$36(a0),ost_x_pos(a1)
		move.w	$38(a0),ost_y_pos(a1)
		moveq	#0,d1
		move.b	$3A(a0),d1
		addq.b	#4,d1
		cmp.b	$3B(a0),d1
		bcs.s	loc_167C2
		moveq	#0,d1
		bra.s	loc_16800
; ===========================================================================

loc_167C2:
		move.b	d1,$3A(a0)
		movea.l	$3C(a0),a2
		move.w	(a2,d1.w),$36(a0)
		move.w	2(a2,d1.w),$38(a0)
		bra.w	sub_1681C
; ===========================================================================

loc_167DA:
		move.l	ost_x_pos(a1),d2
		move.l	ost_y_pos(a1),d3
		move.w	ost_x_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	ost_y_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,ost_x_pos(a1)
		move.l	d3,ost_y_pos(a1)
		rts	
; ===========================================================================

loc_16800:
		andi.w	#$7FF,ost_y_pos(a1)
		clr.b	ost_routine(a0)
		clr.b	(f_lockmulti).w
		move.w	#0,ost_x_vel(a1)
		move.w	#$200,ost_y_vel(a1)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1681C:
		moveq	#0,d0
		move.w	#$1000,d2
		move.w	$36(a0),d0
		sub.w	ost_x_pos(a1),d0
		bge.s	loc_16830
		neg.w	d0
		neg.w	d2

loc_16830:
		moveq	#0,d1
		move.w	#$1000,d3
		move.w	$38(a0),d1
		sub.w	ost_y_pos(a1),d1
		bge.s	loc_16844
		neg.w	d1
		neg.w	d3

loc_16844:
		cmp.w	d0,d1
		bcs.s	loc_1687A
		moveq	#0,d1
		move.w	$38(a0),d1
		sub.w	ost_y_pos(a1),d1
		swap	d1
		divs.w	d3,d1
		moveq	#0,d0
		move.w	$36(a0),d0
		sub.w	ost_x_pos(a1),d0
		beq.s	loc_16866
		swap	d0
		divs.w	d1,d0

loc_16866:
		move.w	d0,ost_x_vel(a1)
		move.w	d3,ost_y_vel(a1)
		tst.w	d1
		bpl.s	loc_16874
		neg.w	d1

loc_16874:
		move.w	d1,$2E(a0)
		rts	
; ===========================================================================

loc_1687A:
		moveq	#0,d0
		move.w	$36(a0),d0
		sub.w	ost_x_pos(a1),d0
		swap	d0
		divs.w	d2,d0
		moveq	#0,d1
		move.w	$38(a0),d1
		sub.w	ost_y_pos(a1),d1
		beq.s	loc_16898
		swap	d1
		divs.w	d0,d1

loc_16898:
		move.w	d1,ost_y_vel(a1)
		move.w	d2,ost_x_vel(a1)
		tst.w	d0
		bpl.s	loc_168A6
		neg.w	d0

loc_168A6:
		move.w	d0,$2E(a0)
		rts	
; End of function sub_1681C

; ===========================================================================
Tele_Data:	index *
		ptr @type00
		ptr @type01
		ptr @type02
		ptr @type03
		ptr @type04
		ptr @type05
		ptr @type06
		ptr @type07
@type00:	dc.w 4,	$794, $98C
@type01:	dc.w 4,	$94, $38C
@type02:	dc.w $1C, $794,	$2E8
		dc.w $7A4, $2C0, $7D0
		dc.w $2AC, $858, $2AC
		dc.w $884, $298, $894
		dc.w $270, $894, $190
@type03:	dc.w 4,	$894, $690
@type04:	dc.w $1C, $1194, $470
		dc.w $1184, $498, $1158
		dc.w $4AC, $FD0, $4AC
		dc.w $FA4, $4C0, $F94
		dc.w $4E8, $F94, $590
@type05:	dc.w 4,	$1294, $490
@type06:	dc.w $1C, $1594, $FFE8
		dc.w $1584, $FFC0, $1560
		dc.w $FFAC, $14D0, $FFAC
		dc.w $14A4, $FF98, $1494
		dc.w $FF70, $1494, $FD90
@type07:	dc.w 4,	$894, $90

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_AnglePos:
		btst	#status_platform_bit,ost_status(a0)
		beq.s	loc_14602
		moveq	#0,d0
		move.b	d0,(v_angle_right).w
		move.b	d0,(v_angle_left).w
		rts	
; ===========================================================================

loc_14602:
		moveq	#3,d0
		move.b	d0,(v_angle_right).w
		move.b	d0,(v_angle_left).w
		move.b	ost_angle(a0),d0
		addi.b	#$20,d0
		bpl.s	loc_14624
		move.b	ost_angle(a0),d0
		bpl.s	loc_1461E
		subq.b	#1,d0

loc_1461E:
		addi.b	#$20,d0
		bra.s	loc_14630
; ===========================================================================

loc_14624:
		move.b	ost_angle(a0),d0
		bpl.s	loc_1462C
		addq.b	#1,d0

loc_1462C:
		addi.b	#$1F,d0

loc_14630:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_angle_right).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	ost_width(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	(v_angle_left).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_146BE
		bpl.s	loc_146C0
		cmpi.w	#-$E,d1
		blt.s	locret_146E6
		add.w	d1,ost_y_pos(a0)

locret_146BE:
		rts	
; ===========================================================================

loc_146C0:
		cmpi.w	#$E,d1
		bgt.s	loc_146CC

loc_146C6:
		add.w	d1,ost_y_pos(a0)
		rts	
; ===========================================================================

loc_146CC:
		tst.b	ost_sonic_sbz_disc(a0)
		bne.s	loc_146C6
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#1,ost_anim_next(a0)
		rts	
; ===========================================================================

locret_146E6:
		rts	
; End of function Sonic_AnglePos

; ===========================================================================
		move.l	ost_x_pos(a0),d2
		move.w	ost_x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,ost_x_pos(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,ost_y_pos(a0)
		rts	
; ===========================================================================

locret_1470A:
		rts	
; ===========================================================================
		move.l	ost_y_pos(a0),d3
		move.w	ost_y_vel(a0),d0
		subi.w	#$38,d0
		move.w	d0,ost_y_vel(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,ost_y_pos(a0)
		rts	
		rts	
; ===========================================================================
		move.l	ost_x_pos(a0),d2
		move.l	ost_y_pos(a0),d3
		move.w	ost_x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	ost_y_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,ost_x_pos(a0)
		move.l	d3,ost_y_pos(a0)
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Angle:
		move.b	(v_angle_left).w,d2
		cmp.w	d0,d1
		ble.s	loc_1475E
		move.b	(v_angle_right).w,d2
		move.w	d0,d1

loc_1475E:
		btst	#0,d2
		bne.s	loc_1476A
		move.b	d2,ost_angle(a0)
		rts	
; ===========================================================================

loc_1476A:
		move.b	ost_angle(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2
		move.b	d2,ost_angle(a0)
		rts	
; End of function Sonic_Angle

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertR:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_angle_right).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_angle_left).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_147F0
		bpl.s	loc_147F2
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		add.w	d1,ost_x_pos(a0)

locret_147F0:
		rts	
; ===========================================================================

loc_147F2:
		cmpi.w	#$E,d1
		bgt.s	loc_147FE

loc_147F8:
		add.w	d1,ost_x_pos(a0)
		rts	
; ===========================================================================

loc_147FE:
		tst.b	ost_sonic_sbz_disc(a0)
		bne.s	loc_147F8
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#1,ost_anim_next(a0)
		rts	
; End of function Sonic_WalkVertR

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkCeiling:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_angle_right).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	ost_width(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(v_angle_left).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14892
		bpl.s	loc_14894
		cmpi.w	#-$E,d1
		blt.w	locret_146E6
		sub.w	d1,ost_y_pos(a0)

locret_14892:
		rts	
; ===========================================================================

loc_14894:
		cmpi.w	#$E,d1
		bgt.s	loc_148A0

loc_1489A:
		sub.w	d1,ost_y_pos(a0)
		rts	
; ===========================================================================

loc_148A0:
		tst.b	ost_sonic_sbz_disc(a0)
		bne.s	loc_1489A
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#1,ost_anim_next(a0)
		rts	
; End of function Sonic_WalkCeiling

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertL:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(v_angle_right).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(v_angle_left).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14934
		bpl.s	loc_14936
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		sub.w	d1,ost_x_pos(a0)

locret_14934:
		rts	
; ===========================================================================

loc_14936:
		cmpi.w	#$E,d1
		bgt.s	loc_14942

loc_1493C:
		sub.w	d1,ost_x_pos(a0)
		rts	
; ===========================================================================

loc_14942:
		tst.b	ost_sonic_sbz_disc(a0)
		bne.s	loc_1493C
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#1,ost_anim_next(a0)
		rts	
; End of function Sonic_WalkVertL

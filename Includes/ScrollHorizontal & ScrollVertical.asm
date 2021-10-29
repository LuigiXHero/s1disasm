; ---------------------------------------------------------------------------
; Subroutine to	scroll the level horizontally as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHorizontal:
		move.w	(v_camera_x_pos).w,d4 ; save old screen position
		bsr.s	MoveScreenHoriz
		move.w	(v_camera_x_pos).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_x_redraw_flag).w,d1
		eor.b	d1,d0
		bne.s	@return
		eori.b	#$10,(v_fg_x_redraw_flag).w
		move.w	(v_camera_x_pos).w,d0
		sub.w	d4,d0		; compare new with old screen position
		bpl.s	@scrollRight

		bset	#redraw_left_bit,(v_fg_redraw_direction).w ; screen moves backward
		rts	

	@scrollRight:
		bset	#redraw_right_bit,(v_fg_redraw_direction).w ; screen moves forward

	@return:
		rts	
; End of function ScrollHorizontal


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveScreenHoriz:
		move.w	(v_ost_player+ost_x_pos).w,d0
		sub.w	(v_camera_x_pos).w,d0 ; Sonic's distance from left edge of screen
		subi.w	#144,d0		; is distance less than 144px?
		bcs.s	SH_BehindMid	; if yes, branch
		subi.w	#16,d0		; is distance more than 160px?
		bcc.s	SH_AheadOfMid	; if yes, branch
		clr.w	(v_camera_x_diff).w
		rts	
; ===========================================================================

SH_AheadOfMid:
		cmpi.w	#16,d0		; is Sonic within 16px of middle area?
		bcs.s	SH_Ahead16	; if yes, branch
		move.w	#16,d0		; set to 16 if greater

	SH_Ahead16:
		add.w	(v_camera_x_pos).w,d0
		cmp.w	(v_boundary_right).w,d0
		blt.s	SH_SetScreen
		move.w	(v_boundary_right).w,d0

SH_SetScreen:
		move.w	d0,d1
		sub.w	(v_camera_x_pos).w,d1
		asl.w	#8,d1
		move.w	d0,(v_camera_x_pos).w ; set new screen position
		move.w	d1,(v_camera_x_diff).w ; set distance for screen movement
		rts	
; ===========================================================================

SH_BehindMid:
		add.w	(v_camera_x_pos).w,d0
		cmp.w	(v_boundary_left).w,d0
		bgt.s	SH_SetScreen
		move.w	(v_boundary_left).w,d0
		bra.s	SH_SetScreen
; End of function MoveScreenHoriz

; ===========================================================================
		tst.w	d0
		bpl.s	loc_6610
		move.w	#-2,d0
		bra.s	SH_BehindMid

loc_6610:
		move.w	#2,d0
		bra.s	SH_AheadOfMid

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level vertically as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollVertical:
		moveq	#0,d1
		move.w	(v_ost_player+ost_y_pos).w,d0
		sub.w	(v_camera_y_pos).w,d0 ; Sonic's distance from top of screen
		btst	#status_jump_bit,(v_ost_player+ost_status).w ; is Sonic jumping/rolling?
		beq.s	SV_NotRolling	; if not, branch
		subq.w	#5,d0

	SV_NotRolling:
		btst	#status_air_bit,(v_ost_player+ost_status).w ; is Sonic jumping?
		beq.s	loc_664A	; if not, branch

		addi.w	#32,d0
		sub.w	(v_camera_y_shift).w,d0
		bcs.s	loc_6696
		subi.w	#64,d0
		bcc.s	loc_6696
		tst.b	(f_boundary_bottom_change).w
		bne.s	loc_66A8
		bra.s	loc_6656
; ===========================================================================

loc_664A:
		sub.w	(v_camera_y_shift).w,d0
		bne.s	loc_665C
		tst.b	(f_boundary_bottom_change).w
		bne.s	loc_66A8

loc_6656:
		clr.w	(v_camera_y_diff).w
		rts	
; ===========================================================================

loc_665C:
		cmpi.w	#$60,(v_camera_y_shift).w
		bne.s	loc_6684
		move.w	(v_ost_player+ost_inertia).w,d1
		bpl.s	loc_666C
		neg.w	d1

loc_666C:
		cmpi.w	#$800,d1
		bcc.s	loc_6696
		move.w	#$600,d1
		cmpi.w	#6,d0
		bgt.s	loc_66F6
		cmpi.w	#-6,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6684:
		move.w	#$200,d1
		cmpi.w	#2,d0
		bgt.s	loc_66F6
		cmpi.w	#-2,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6696:
		move.w	#$1000,d1
		cmpi.w	#$10,d0
		bgt.s	loc_66F6
		cmpi.w	#-$10,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_66A8:
		moveq	#0,d0
		move.b	d0,(f_boundary_bottom_change).w

loc_66AE:
		moveq	#0,d1
		move.w	d0,d1
		add.w	(v_camera_y_pos).w,d1
		tst.w	d0
		bpl.w	loc_6700
		bra.w	loc_66CC
; ===========================================================================

loc_66C0:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	(v_camera_y_pos).w,d1
		swap	d1

loc_66CC:
		cmp.w	(v_boundary_top).w,d1
		bgt.s	loc_6724
		cmpi.w	#-$100,d1
		bgt.s	loc_66F0
		andi.w	#$7FF,d1
		andi.w	#$7FF,(v_ost_player+ost_y_pos).w
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		bra.s	loc_6724
; ===========================================================================

loc_66F0:
		move.w	(v_boundary_top).w,d1
		bra.s	loc_6724
; ===========================================================================

loc_66F6:
		ext.l	d1
		asl.l	#8,d1
		add.l	(v_camera_y_pos).w,d1
		swap	d1

loc_6700:
		cmp.w	(v_boundary_bottom).w,d1
		blt.s	loc_6724
		subi.w	#$800,d1
		bcs.s	loc_6720
		andi.w	#$7FF,(v_ost_player+ost_y_pos).w
		subi.w	#$800,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		bra.s	loc_6724
; ===========================================================================

loc_6720:
		move.w	(v_boundary_bottom).w,d1

loc_6724:
		move.w	(v_camera_y_pos).w,d4
		swap	d1
		move.l	d1,d3
		sub.l	(v_camera_y_pos).w,d3
		ror.l	#8,d3
		move.w	d3,(v_camera_y_diff).w
		move.l	d1,(v_camera_y_pos).w
		move.w	(v_camera_y_pos).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_y_redraw_flag).w,d1
		eor.b	d1,d0
		bne.s	@return
		eori.b	#$10,(v_fg_y_redraw_flag).w
		move.w	(v_camera_y_pos).w,d0
		sub.w	d4,d0
		bpl.s	@scrollBottom
		bset	#redraw_top_bit,(v_fg_redraw_direction).w
		rts	
; ===========================================================================

	@scrollBottom:
		bset	#redraw_bottom_bit,(v_fg_redraw_direction).w

	@return:
		rts	
; End of function ScrollVertical

; ---------------------------------------------------------------------------
; Subroutine to	draw 16x16 tiles at the edge of the screen as the camera moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Background only - used by title screen
DrawTilesWhenMoving_BGOnly:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_redraw_direction).w,a2
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+level_max_width).w,a4
		move.w	#$6000,d2
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_redraw_direction).w,a2
		lea	(v_bg2_x_pos).w,a3
		bra.w	DrawBGScrollBlock2

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

DrawTilesWhenMoving:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6

		; Background
		lea	(v_bg1_redraw_direction_copy).w,a2
		lea	(v_bg1_x_pos_copy).w,a3
		lea	(v_level_layout+level_max_width).w,a4
		move.w	#$6000,d2
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_redraw_direction_copy).w,a2
		lea	(v_bg2_x_pos_copy).w,a3
		bsr.w	DrawBGScrollBlock2
		if Revision=0
		else
		; REV01 added a third scroll block
			lea	(v_bg3_redraw_direction_copy).w,a2
			lea	(v_bg3_x_pos_copy).w,a3
			bsr.w	DrawBGScrollBlock3
		endc
		; Foreground
		lea	(v_fg_redraw_direction_copy).w,a2
		lea	(v_camera_x_pos_copy).w,a3
		lea	(v_level_layout).w,a4
		move.w	#$4000,d2
		tst.b	(a2)					; are any redraw flags set?
		beq.s	@exit					; if not, branch
		bclr	#redraw_top_bit,(a2)			; clear flag for redraw top
		beq.s	@chk_bottom				; branch if already clear
		; Draw new tiles at the top
		moveq	#-16,d4					; y coordinate - 16px (size of block) above top
		moveq	#-16,d5					; x coordinate - 16px outside left edge
		bsr.w	Calc_VRAM_Pos				; d0 = VDP command for fg nametable
		moveq	#-16,d4					; y coordinate
		moveq	#-16,d5					; x coordinate
		bsr.w	DrawBlocks_LR

	@chk_bottom:
		bclr	#redraw_bottom_bit,(a2)			; clear flag for redraw bottom
		beq.s	@chk_left				; branch if already clear
		; Draw new tiles at the bottom
		move.w	#224,d4					; y coordinate - bottom of screen
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

	@chk_left:
		bclr	#redraw_left_bit,(a2)			; clear flag for redraw left
		beq.s	@chk_right				; branch if already clear
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

	@chk_right:
		bclr	#redraw_right_bit,(a2)			; clear flag for redraw right
		beq.s	@exit					; branch if already clear
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5					; x coordinate - right edge of screen
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	DrawBlocks_TB

@exit:
		rts	
; End of function DrawTilesWhenMoving

; ---------------------------------------------------------------------------
; Subroutines to draw 16x16 tiles on the background in sections

; input:
;	d2 = VRAM something
;	a5 = vdp_control_port
;	a6 = vdp_data_port
;	(a2) = redraw direction flags
;	(a3) = bg x position
;	4(a3) = bg y position
;	(a4) = bg layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

DrawBGScrollBlock1:
		tst.b	(a2)					; are any redraw flags set?
		beq.w	@exit					; if not, branch
		bclr	#redraw_top_bit,(a2)			; clear flag for redraw top
		beq.s	@chk_bottom				; branch if already clear
		; Draw new tiles at the top
		moveq	#-16,d4					; y coordinate - 16px (size of block) above top
		moveq	#-16,d5					; x coordinate - 16px outside left edge
		bsr.w	Calc_VRAM_Pos				; d0 = VDP command for fg nametable
		moveq	#-16,d4					; y coordinate
		moveq	#-16,d5					; x coordinate
		if Revision=0
			moveq	#(512/16)-1,d6			; draw entire row of plane
			bsr.w	DrawBlocks_LR_2
		else
			bsr.w	DrawBlocks_LR
		endc

	@chk_bottom:
		bclr	#redraw_bottom_bit,(a2)			; clear flag for redraw bottom
		beq.s	@chk_left				; branch if already clear
		; Draw new tiles at the bottom
		move.w	#224,d4					; y coordinate - bottom of screen
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		if Revision=0
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_2
		else
			bsr.w	DrawBlocks_LR
		endc

	@chk_left:
		bclr	#redraw_left_bit,(a2)			; clear flag for redraw left
		beq.s	@chk_right				; branch if already clear
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5

		if Revision=0
			move.w	(v_scroll_block_1_height).w,d6	; get bg block 1 height (GHZ = $70; others = $800)
			move.w	4(a3),d1			; get bg y position
			andi.w	#-16,d1				; round down to nearest 16
			sub.w	d1,d6
			blt.s	@chk_right			; if bg block 1 is offscreen, skip loading its tiles
			lsr.w	#4,d6				; d6 = number of rows not above the screen
			cmpi.w	#((224+16+16)/16)-1,d6		; compare with height of screen + 16px either side
			blo.s	@bg_covers_partial		; branch if less
			moveq	#((224+16+16)/16)-1,d6		; limit to height of screen + 16px either side
	@bg_covers_partial:
			bsr.w	DrawBlocks_TB_2
		else
			bsr.w	DrawBlocks_TB
		endc

	@chk_right:
		bclr	#redraw_right_bit,(a2)			; clear flag for redraw right
		if Revision=0
			beq.s	@exit				; branch if already clear
		else
			beq.s	@chk_topall
		endc
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5

		if Revision=0
			move.w	(v_scroll_block_1_height).w,d6
			move.w	4(a3),d1
			andi.w	#-16,d1
			sub.w	d1,d6
			blt.s	@exit
			lsr.w	#4,d6
			cmpi.w	#((224+16+16)/16)-1,d6
			blo.s	@bg_covers_partial2
			moveq	#((224+16+16)/16)-1,d6
	@bg_covers_partial2:
			bsr.w	DrawBlocks_TB_2
		else
			bsr.w	DrawBlocks_TB

	@chk_topall:
			bclr	#redraw_topall_bit,(a2)
			beq.s	@chk_bottomall
		; Draw entire row at the top
			moveq	#-16,d4
			moveq	#0,d5
			bsr.w	Calc_VRAM_Pos_2
			moveq	#-16,d4
			moveq	#0,d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	@chk_bottomall:
			bclr	#redraw_bottomall_bit,(a2)
			beq.s	@exit
		; Draw entire row at the bottom
			move.w	#224,d4
			moveq	#0,d5
			bsr.w	Calc_VRAM_Pos_2
			move.w	#224,d4
			moveq	#0,d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
		endc

@exit:
		rts	
; End of function DrawBGScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Essentially, this draws everything that isn't scroll block 1
DrawBGScrollBlock2:
		tst.b	(a2)					; are any redraw flags set?
		beq.w	@exit					; if not, branch
		if Revision=0
			bclr	#redraw_left_bit,(a2)		; clear flag for redraw left
			beq.s	@chk_right			; branch if already clear
		; Draw new tiles on the left
			cmpi.w	#16,(a3)			; is bg block 2 within 16px of left edge?
			blo.s	@chk_right			; if yes, branch

			move.w	(v_scroll_block_1_height).w,d4	; get bg block 1 height (GHZ = $70; others = $800)
			move.w	4(a3),d1			; get bg y position
			andi.w	#-16,d1				; round down to nearest 16
			sub.w	d1,d4				; d4 = height of screen that isn't bg block 1
			move.w	d4,-(sp)			; save to stack
			moveq	#-16,d5				; x coordinate
			bsr.w	Calc_VRAM_Pos			; d0 = VDP command for bg nametable
			move.w	(sp)+,d4			; retrieve y coordinate from stack
			moveq	#-16,d5
			move.w	(v_scroll_block_1_height).w,d6
			move.w	4(a3),d1
			andi.w	#-16,d1
			sub.w	d1,d6				; d6 = height of screen that isn't bg block 1
			blt.s	@chk_right			; branch if bg block 1 is completely off screen
			lsr.w	#4,d6				; divide by 16
			subi.w	#((224+16)/16)-1,d6		; d6 = rows for bg block 2, minus rows for whole screen
			bhs.s	@chk_right
			neg.w	d6
			bsr.w	DrawBlocks_TB_2
	@chk_right:
			bclr	#redraw_right_bit,(a2)		; clear flag for redraw right
			beq.s	@exit			; branch if already clear
		; Draw new tiles on the right
			move.w	(v_scroll_block_1_height).w,d4
			move.w	4(a3),d1
			andi.w	#-16,d1
			sub.w	d1,d4
			move.w	d4,-(sp)
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	(sp)+,d4
			move.w	#320,d5
			move.w	(v_scroll_block_1_height).w,d6
			move.w	4(a3),d1
			andi.w	#-16,d1
			sub.w	d1,d6
			blt.s	@exit
			lsr.w	#4,d6
			subi.w	#((224+16)/16)-1,d6
			bhs.s	@exit
			neg.w	d6
			bsr.w	DrawBlocks_TB_2
		else
			cmpi.b	#id_SBZ,(v_zone).w
			beq.w	Draw_SBz
			bclr	#redraw_top_bit,(a2)
			beq.s	@chk_right
		; Draw new tiles on the left
			move.w	#224/2,d4			; Draw the bottom half of the screen
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			moveq	#-16,d5
			moveq	#3-1,d6				; Draw three rows... could this be a repurposed version of the above unused code?
			bsr.w	DrawBlocks_TB_2
	@chk_right:
			bclr	#redraw_bottom_bit,(a2)
			beq.s	@exit
		; Draw new tiles on the right
			move.w	#224/2,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			move.w	#320,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
		endc
@exit:
		rts	
; End of function DrawBGScrollBlock2

; ===========================================================================

; Abandoned unused scroll block code.
; This would have drawn a scroll block that started at 208 pixels down, and was 48 pixels long.
		if Revision=0
		tst.b	(a2)
		beq.s	locret_6AD6
		bclr	#redraw_left_bit,(a2)
		beq.s	loc_6AAC
		; Draw new tiles on the left
		move.w	#224-16,d4				; Note that full screen coverage is normally 224+16+16. This is exactly three blocks less.
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos_Unknown
		move.w	(sp)+,d4
		moveq	#-16,d5
		moveq	#3-1,d6					; Draw only three rows
		bsr.w	DrawBlocks_TB_2

loc_6AAC:
		bclr	#redraw_right_bit,(a2)
		beq.s	locret_6AD6
		; Draw new tiles on the right
		move.w	#224-16,d4
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos_Unknown
		move.w	(sp)+,d4
		move.w	#320,d5
		moveq	#3-1,d6
		bsr.w	DrawBlocks_TB_2

locret_6AD6:
		rts
		endc
;===============================================================================
		
		if Revision=0
		else
	locj_6DF4:
			dc.b $00,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$04
			dc.b $04,$04,$04,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00						
;===============================================================================
	Draw_SBz:
			moveq	#-16,d4
			bclr	#redraw_top_bit,(a2)
			bne.s	locj_6E28
			bclr	#redraw_bottom_bit,(a2)
			beq.s	locj_6E72
			move.w	#224,d4
	locj_6E28:
			lea	(locj_6DF4+1).l,a0
			move.w	(v_bg1_y_pos).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			lea	(locj_6FE4).l,a3
			movea.w	(a3,d0.w),a3
			beq.s	locj_6E5E
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_6E72
;===============================================================================
	locj_6E5E:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_6E72:
			tst.b	(a2)
			bne.s	locj_6E78
			rts
;===============================================================================			
	locj_6E78:
			moveq	#-16,d4
			moveq	#-16,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6E8C
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#320,d5
	locj_6E8C:
			lea	(locj_6DF4).l,a0
			move.w	(v_bg1_y_pos).w,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			lea	(a0,d0.w),a0
			bra.w	locj_6FEC
			
		endc
;===============================================================================

DrawBGScrollBlock3:
		if Revision=0
		else
			tst.b	(a2)
			beq.w	locj_6EF0
			cmpi.b	#id_MZ,(v_zone).w
			beq.w	Draw_Mz
			bclr	#redraw_top_bit,(a2)
			beq.s	locj_6ED0
								; Draw new tiles on the left
			move.w	#$40,d4
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#$40,d4
			moveq	#-16,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6ED0:
			bclr	#redraw_bottom_bit,(a2)
			beq.s	locj_6EF0
								; Draw new tiles on the right
			move.w	#$40,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#$40,d4
			move.w	#320,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6EF0:
			rts
	locj_6EF2:
			dc.b $00,$00,$00,$00,$00,$00,$06,$06,$04,$04,$04,$04,$04,$04,$04,$04
			dc.b $04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00
;===============================================================================
	Draw_Mz:
			moveq	#-16,d4
			bclr	#redraw_top_bit,(a2)
			bne.s	locj_6F66
			bclr	#redraw_bottom_bit,(a2)
			beq.s	locj_6FAE
			move.w	#224,d4
	locj_6F66:
			lea	(locj_6EF2+1).l,a0
			move.w	(v_bg1_y_pos).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			movea.w	locj_6FE4(pc,d0.w),a3
			beq.s	locj_6F9A
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_6FAE
;===============================================================================
	locj_6F9A:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_6FAE:
			tst.b	(a2)
			bne.s	locj_6FB4
			rts
;===============================================================================			
	locj_6FB4:
			moveq	#-16,d4
			moveq	#-16,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6FC8
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#320,d5
	locj_6FC8:
			lea	(locj_6EF2).l,a0
			move.w	(v_bg1_y_pos).w,d0
			subi.w	#$200,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			lea	(a0,d0.w),a0
			bra.w	locj_6FEC
;===============================================================================			
	locj_6FE4:
			dc.w v_bg1_x_pos_copy, v_bg1_x_pos_copy, v_bg2_x_pos_copy, v_bg3_x_pos_copy
	locj_6FEC:
			moveq	#((224+16+16)/16)-1,d6
			move.l	#$800000,d7
	locj_6FF4:			
			moveq	#0,d0
			move.b	(a0)+,d0
			btst	d0,(a2)
			beq.s	locj_701C
			move.w	locj_6FE4(pc,d0.w),a3
			movem.l	d4/d5/a0,-(sp)
			movem.l	d4/d5,-(sp)
			bsr.w	GetBlockData
			movem.l	(sp)+,d4/d5
			bsr.w	Calc_VRAM_Pos
			bsr.w	DrawBlock
			movem.l	(sp)+,d4/d5/a0
	locj_701C:
			addi.w	#16,d4
			dbf	d6,locj_6FF4
			clr.b	(a2)
			rts			

		endc

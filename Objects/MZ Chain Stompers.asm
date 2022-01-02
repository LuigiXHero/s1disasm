; ---------------------------------------------------------------------------
; Object 31 - stomping metal blocks on chains (MZ)
; ---------------------------------------------------------------------------

ChainStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	CStom_Index(pc,d0.w),d1
		jmp	CStom_Index(pc,d1.w)
; ===========================================================================
CStom_Index:	index *,,2
		ptr CStom_Main
		ptr CStom_Block
		ptr CStom_Spikes
		ptr CStom_Ceiling
		ptr CStom_Chain

CStom_SwchNums:	dc.b 0,	0					; switch number, replacement subtype
		dc.b 1,	0

CStom_Var:	dc.b id_CStom_Block, 0, id_frame_cstomp_wideblock ; routine number, y-position, frame number
		dc.b id_CStom_Spikes, $1C, id_frame_cstomp_spikes
		dc.b id_CStom_Chain, $CC, id_frame_cstomp_chain1
		dc.b id_CStom_Ceiling, $F0, id_frame_cstomp_ceiling

CStom_Lengths:
CStom_Length_0:	dc.w $7000					; 0
CStom_Length_1:	dc.w $A000					; 1
CStom_Length_2:	dc.w $5000					; 2
CStom_Length_3:	dc.w $7800					; 3
CStom_Length_4:	dc.w $3800					; 4 - unused
CStom_Length_5:	dc.w $5800					; 5 - unused
CStom_Length_6:	dc.w $B800					; 6 - unused

ost_cstomp_y_start:		equ $30				; original y position (2 bytes)
ost_cstomp_chain_length:	equ $32				; current chain length (2 bytes)
ost_cstomp_chain_max:		equ $34				; maximum chain length (2 bytes)
ost_cstomp_rise_flag:		equ $36				; 0 = falling; 1 = rising (2 bytes)
ost_cstomp_delay_time:		equ $38				; time delay between fully extended and rising again (2 bytes)
ost_cstomp_switch_id:		equ $3A				; switch number for the current stomper
ost_cstomp_parent:		equ $3C				; address of OST of parent object (4 bytes)
; ===========================================================================

CStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		bpl.s	@not_80					; branch if 0-$7F
		andi.w	#$7F,d0
		add.w	d0,d0
		lea	CStom_SwchNums(pc,d0.w),a2
		move.b	(a2)+,ost_cstomp_switch_id(a0)		; get switch number
		move.b	(a2)+,d0				; get replacement subtype
		move.b	d0,ost_subtype(a0)			; change subtype to 0

	@not_80:
		andi.b	#$F,d0					; read low nybble of subtype
		add.w	d0,d0
		move.w	CStom_Lengths(pc,d0.w),d2		; get length
		tst.w	d0
		bne.s	loc_B6E0
		move.w	d2,ost_cstomp_chain_length(a0)		; if subtype is 0, chain starts at max length

loc_B6E0:
		lea	(CStom_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	CStom_MakeStomper
; ===========================================================================

CStom_Loop:
		bsr.w	FindNextFreeObj
		bne.w	CStom_SetSize

CStom_MakeStomper:
		move.b	(a2)+,ost_routine(a1)
		move.b	#id_ChainStomp,ost_id(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	ost_y_pos(a0),d0
		move.w	d0,ost_y_pos(a1)
		move.l	#Map_CStom,ost_mappings(a1)
		move.w	#tile_Nem_MzMetal,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.w	ost_y_pos(a1),ost_cstomp_y_start(a1)
		move.b	ost_subtype(a0),ost_subtype(a1)
		move.b	#$10,ost_actwidth(a1)
		move.w	d2,ost_cstomp_chain_max(a1)
		move.b	#4,ost_priority(a1)
		move.b	(a2)+,ost_frame(a1)
		cmpi.b	#id_frame_cstomp_spikes,ost_frame(a1)	; is the spikes component being loaded?
		bne.s	@not_spikes				; if not, branch
		subq.w	#1,d1
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of subtype
		cmpi.w	#$20,d0					; is subtype $2x (no spikes)?
		beq.s	CStom_MakeStomper			; if yes, branch
		move.b	#$38,ost_actwidth(a1)
		move.b	#id_col_40x16+id_col_hurt,ost_col_type(a1) ; make spikes harmful
		addq.w	#1,d1

	@not_spikes:
		move.l	a0,ost_cstomp_parent(a1)
		dbf	d1,CStom_Loop

		move.b	#3,ost_priority(a1)

CStom_SetSize:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		lsr.w	#3,d0
		andi.b	#$E,d0					; read only high nybble
		lea	CStom_Var2(pc,d0.w),a2
		move.b	(a2)+,ost_actwidth(a0)
		move.b	(a2)+,ost_frame(a0)
		bra.s	CStom_Block
; ===========================================================================
CStom_Var2:
CStom_Var2_0:	dc.b $38, id_frame_cstomp_wideblock		; width, frame number
CStom_Var2_1:	dc.b $30, id_frame_cstomp_mediumblock
CStom_Var2_2:	dc.b $10, id_frame_cstomp_smallblock

sizeof_cstom_var2:	equ CStom_Var2_1-CStom_Var2
; ===========================================================================

CStom_Block:	; Routine 2
		bsr.w	CStom_Types
		move.w	ost_y_pos(a0),(v_cstomp_y_pos).w	; store y position for pushable green block interaction
		moveq	#0,d1
		move.b	ost_actwidth(a0),d1
		addi.w	#$B,d1
		move.w	#$C,d2
		move.w	#$D,d3
		move.w	ost_x_pos(a0),d4
		bsr.w	SolidObject
		btst	#status_platform_bit,ost_status(a0)	; is Sonic standing on it?
		beq.s	@display				; if not, branch
		cmpi.b	#$10,ost_cstomp_chain_length(a0)	; is chain longer than $10?
		bcc.s	@display				; if yes, branch
		movea.l	a0,a2
		lea	(v_ost_player).w,a0
		jsr	(KillSonic).l				; Sonic gets crushed against ceiling
		movea.l	a2,a0

	@display:
		bsr.w	DisplaySprite
		bra.w	CStom_ChkDel
; ===========================================================================

CStom_Chain:	; Routine 8
		move.b	#$80,ost_height(a0)
		bset	#render_useheight_bit,ost_render(a0)
		movea.l	ost_cstomp_parent(a0),a1
		move.b	ost_cstomp_chain_length(a1),d0		; get current chain length
		lsr.b	#5,d0
		addq.b	#3,d0					; convert to frame number
		move.b	d0,ost_frame(a0)			; update frame

CStom_Spikes:	; Routine 4
		movea.l	ost_cstomp_parent(a0),a1
		moveq	#0,d0
		move.b	ost_cstomp_chain_length(a1),d0
		add.w	ost_cstomp_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)			; update y position (chain and spikes)

CStom_Ceiling:	; Routine 6
		bsr.w	DisplaySprite

CStom_ChkDel:
		out_of_range	DeleteObject
		rts	
; ===========================================================================

CStom_Types:
		move.b	ost_subtype(a0),d0			; get subtype (for button-controlled stompers this will have changed to 0)
		andi.w	#$F,d0					; read low nybble
		add.w	d0,d0
		move.w	CStom_TypeIndex(pc,d0.w),d1
		jmp	CStom_TypeIndex(pc,d1.w)
; ===========================================================================
CStom_TypeIndex:index *
		ptr CStom_Type00				; 0
		ptr CStom_Type01				; 1
		ptr CStom_Type01				; 2
		ptr CStom_Type03				; 3
		ptr CStom_Type01				; 4
		ptr CStom_Type03				; 5
		ptr CStom_Type01				; 6
; ===========================================================================

CStom_Type00:
		lea	(v_button_state).w,a2			; load switch statuses
		moveq	#0,d0
		move.b	ost_cstomp_switch_id(a0),d0		; move number 0 or 1 to d0
		tst.b	(a2,d0.w)				; has switch (d0) been pressed?
		beq.s	loc_B8A8				; if not, branch
		tst.w	(v_cstomp_y_pos).w
		bpl.s	loc_B872
		cmpi.b	#$10,ost_cstomp_chain_length(a0)
		beq.s	loc_B8A0

loc_B872:
		tst.w	ost_cstomp_chain_length(a0)
		beq.s	loc_B8A0
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$F,d0
		bne.s	loc_B892
		tst.b	1(a0)
		bpl.s	loc_B892
		play.w	1, jsr, sfx_ChainRise			; play rising chain sound

loc_B892:
		subi.w	#$80,ost_cstomp_chain_length(a0)
		bcc.s	CStom_Restart
		move.w	#0,ost_cstomp_chain_length(a0)

loc_B8A0:
		move.w	#0,ost_y_vel(a0)
		bra.s	CStom_Restart
; ===========================================================================

loc_B8A8:
		move.w	ost_cstomp_chain_max(a0),d1
		cmp.w	ost_cstomp_chain_length(a0),d1
		beq.s	CStom_Restart
		move.w	ost_y_vel(a0),d0
		addi.w	#$70,ost_y_vel(a0)			; make object fall
		add.w	d0,ost_cstomp_chain_length(a0)
		cmp.w	ost_cstomp_chain_length(a0),d1
		bhi.s	CStom_Restart
		move.w	d1,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)			; stop object falling
		tst.b	ost_render(a0)
		bpl.s	CStom_Restart
		play.w	1, jsr, sfx_ChainStomp			; play stomping sound

CStom_Restart:
		moveq	#0,d0
		move.b	ost_cstomp_chain_length(a0),d0
		add.w	ost_cstomp_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)
		rts	
; ===========================================================================

CStom_Type01:
		tst.w	ost_cstomp_rise_flag(a0)
		beq.s	loc_B938
		tst.w	ost_cstomp_delay_time(a0)
		beq.s	loc_B902
		subq.w	#1,ost_cstomp_delay_time(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B902:
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$F,d0
		bne.s	loc_B91C
		tst.b	ost_render(a0)
		bpl.s	loc_B91C
		play.w	1, jsr, sfx_ChainRise			; play rising chain sound

loc_B91C:
		subi.w	#$80,ost_cstomp_chain_length(a0)
		bcc.s	loc_B97C
		move.w	#0,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)
		move.w	#0,ost_cstomp_rise_flag(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B938:
		move.w	ost_cstomp_chain_max(a0),d1
		cmp.w	ost_cstomp_chain_length(a0),d1
		beq.s	loc_B97C
		move.w	ost_y_vel(a0),d0
		addi.w	#$70,ost_y_vel(a0)			; make object fall
		add.w	d0,ost_cstomp_chain_length(a0)
		cmp.w	ost_cstomp_chain_length(a0),d1
		bhi.s	loc_B97C
		move.w	d1,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)			; stop object falling
		move.w	#1,ost_cstomp_rise_flag(a0)
		move.w	#$3C,ost_cstomp_delay_time(a0)
		tst.b	ost_render(a0)
		bpl.s	loc_B97C
		play.w	1, jsr, sfx_ChainStomp			; play stomping sound

loc_B97C:
		bra.w	CStom_Restart
; ===========================================================================

CStom_Type03:
		move.w	(v_ost_player+ost_x_pos).w,d0
		sub.w	ost_x_pos(a0),d0
		bcc.s	loc_B98C
		neg.w	d0

loc_B98C:
		cmpi.w	#$90,d0					; is Sonic within $90 pixels?
		bcc.s	loc_B996				; if not, branch
		addq.b	#1,ost_subtype(a0)			; allow stomper to drop by changing subtype

loc_B996:
		bra.w	CStom_Restart

; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)
; ---------------------------------------------------------------------------

		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Obj75_Index(pc,d0.w),d1
		jmp	Obj75_Index(pc,d1.w)
; ===========================================================================
Obj75_Index:	index *,,2
		ptr Obj75_Main
		ptr Obj75_ShipMain
		ptr Obj75_FaceMain
		ptr Obj75_FlameMain
		ptr Obj75_SpikeMain

Obj75_ObjData:	dc.b 2,	0, 5		; routine number, animation, priority
		dc.b 4,	1, 5
		dc.b 6,	7, 5
		dc.b 8,	0, 5
; ===========================================================================

Obj75_Main:	; Routine 0
		move.w	#$2DB0,ost_x_pos(a0)
		move.w	#$4DA,ost_y_pos(a0)
		move.w	ost_x_pos(a0),$30(a0)
		move.w	ost_y_pos(a0),$38(a0)
		move.b	#$F,ost_col_type(a0)
		move.b	#8,ost_col_property(a0) ; set number of hits to 8
		lea	Obj75_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj75_LoadBoss
; ===========================================================================

Obj75_Loop:
		jsr	(FindNextFreeObj).l
		bne.s	Obj75_ShipMain
		move.b	#id_BossSpringYard,(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)

Obj75_LoadBoss:
		bclr	#0,ost_status(a0)
		clr.b	ost_routine2(a1)
		move.b	(a2)+,ost_routine(a1)
		move.b	(a2)+,ost_anim(a1)
		move.b	(a2)+,ost_priority(a1)
		move.l	#Map_Eggman,ost_mappings(a1)
		move.w	#tile_Nem_Eggman,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#$20,ost_actwidth(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj75_Loop	; repeat sequence 3 more times

Obj75_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ost_routine2(a0),d0
		move.w	Obj75_ShipIndex(pc,d0.w),d1
		jsr	Obj75_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
		moveq	#3,d0
		and.b	ost_status(a0),d0
		andi.b	#$FC,ost_render(a0)
		or.b	d0,ost_render(a0)
		jmp	(DisplaySprite).l
; ===========================================================================
Obj75_ShipIndex:index *
		ptr loc_191CC
		ptr loc_19270
		ptr loc_192EC
		ptr loc_19474
		ptr loc_194AC
		ptr loc_194F2
; ===========================================================================

loc_191CC:
		move.w	#-$100,ost_x_vel(a0)
		cmpi.w	#$2D38,$30(a0)
		bcc.s	loc_191DE
		addq.b	#2,ost_routine2(a0)

loc_191DE:
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#2,d0
		move.w	d0,ost_y_vel(a0)

loc_191F2:
		bsr.w	BossMove
		move.w	$38(a0),ost_y_pos(a0)
		move.w	$30(a0),ost_x_pos(a0)

loc_19202:
		move.w	8(a0),d0
		subi.w	#$2C00,d0
		lsr.w	#5,d0
		move.b	d0,$34(a0)
		cmpi.b	#6,ost_routine2(a0)
		bcc.s	locret_19256
		tst.b	ost_status(a0)
		bmi.s	loc_19258
		tst.b	ost_col_type(a0)
		bne.s	locret_19256
		tst.b	$3E(a0)
		bne.s	loc_1923A
		move.b	#$20,$3E(a0)
		sfx	sfx_HitBoss,0,0,0	; play boss damage sound

loc_1923A:
		lea	(v_pal_dry+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_19248
		move.w	#cWhite,d0

loc_19248:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_19256
		move.b	#$F,ost_col_type(a0)

locret_19256:
		rts	
; ===========================================================================

loc_19258:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,ost_routine2(a0)
		move.w	#$B4,$3C(a0)
		clr.w	ost_x_vel(a0)
		rts	
; ===========================================================================

loc_19270:
		move.w	$30(a0),d0
		move.w	#$140,ost_x_vel(a0)
		btst	#0,ost_status(a0)
		bne.s	loc_1928E
		neg.w	ost_x_vel(a0)
		cmpi.w	#$2C08,d0
		bgt.s	loc_1929E
		bra.s	loc_19294
; ===========================================================================

loc_1928E:
		cmpi.w	#$2D38,d0
		blt.s	loc_1929E

loc_19294:
		bchg	#0,ost_status(a0)
		clr.b	standonobject(a0)

loc_1929E:
		subi.w	#$2C10,d0
		andi.w	#$1F,d0
		subi.w	#$1F,d0
		bpl.s	loc_192AE
		neg.w	d0

loc_192AE:
		subq.w	#1,d0
		bgt.s	loc_192E8
		tst.b	standonobject(a0)
		bne.s	loc_192E8
		move.w	(v_player+ost_x_pos).w,d1
		subi.w	#$2C00,d1
		asr.w	#5,d1
		cmp.b	$34(a0),d1
		bne.s	loc_192E8
		moveq	#0,d0
		move.b	$34(a0),d0
		asl.w	#5,d0
		addi.w	#$2C10,d0
		move.w	d0,$30(a0)
		bsr.w	Obj75_FindBlocks
		addq.b	#2,ost_routine2(a0)
		clr.w	ost_subtype(a0)
		clr.w	ost_x_vel(a0)

loc_192E8:
		bra.w	loc_191DE
; ===========================================================================

loc_192EC:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	off_192FA(pc,d0.w),d0
		jmp	off_192FA(pc,d0.w)
; ===========================================================================
off_192FA:	index *
		ptr loc_19302
		ptr loc_19348
		ptr loc_1938E
		ptr loc_193D0
; ===========================================================================

loc_19302:
		move.w	#$180,ost_y_vel(a0)
		move.w	$38(a0),d0
		cmpi.w	#$556,d0
		bcs.s	loc_19344
		move.w	#$556,$38(a0)
		clr.w	$3C(a0)
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_1933C
		movea.l	d0,a1
		move.b	#-1,$29(a1)
		move.b	#-1,$29(a0)
		move.l	a0,$34(a1)
		move.w	#$32,$3C(a0)

loc_1933C:
		clr.w	ost_y_vel(a0)
		addq.b	#2,ost_subtype(a0)

loc_19344:
		bra.w	loc_191F2
; ===========================================================================

loc_19348:
		subq.w	#1,$3C(a0)
		bpl.s	loc_19366
		addq.b	#2,ost_subtype(a0)
		move.w	#-$800,ost_y_vel(a0)
		tst.w	$36(a0)
		bne.s	loc_19362
		asr	ost_y_vel(a0)

loc_19362:
		moveq	#0,d0
		bra.s	loc_1937C
; ===========================================================================

loc_19366:
		moveq	#0,d0
		cmpi.w	#$1E,$3C(a0)
		bgt.s	loc_1937C
		moveq	#2,d0
		btst	#1,standonobject(a0)
		beq.s	loc_1937C
		neg.w	d0

loc_1937C:
		add.w	$38(a0),d0
		move.w	d0,ost_y_pos(a0)
		move.w	$30(a0),ost_x_pos(a0)
		bra.w	loc_19202
; ===========================================================================

loc_1938E:
		move.w	#$4DA,d0
		tst.w	$36(a0)
		beq.s	loc_1939C
		subi.w	#$18,d0

loc_1939C:
		cmp.w	$38(a0),d0
		blt.s	loc_193BE
		move.w	#8,$3C(a0)
		tst.w	$36(a0)
		beq.s	loc_193B4
		move.w	#$2D,$3C(a0)

loc_193B4:
		addq.b	#2,ost_subtype(a0)
		clr.w	ost_y_vel(a0)
		bra.s	loc_193CC
; ===========================================================================

loc_193BE:
		cmpi.w	#-$40,ost_y_vel(a0)
		bge.s	loc_193CC
		addi.w	#$C,ost_y_vel(a0)

loc_193CC:
		bra.w	loc_191F2
; ===========================================================================

loc_193D0:
		subq.w	#1,$3C(a0)
		bgt.s	loc_19406
		bmi.s	loc_193EE
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_193E8
		movea.l	d0,a1
		move.b	#$A,$29(a1)

loc_193E8:
		clr.w	$36(a0)
		bra.s	loc_19406
; ===========================================================================

loc_193EE:
		cmpi.w	#-$1E,$3C(a0)
		bne.s	loc_19406
		clr.b	$29(a0)
		subq.b	#2,ost_routine2(a0)
		move.b	#-1,standonobject(a0)
		bra.s	loc_19446
; ===========================================================================

loc_19406:
		moveq	#1,d0
		tst.w	$36(a0)
		beq.s	loc_19410
		moveq	#2,d0

loc_19410:
		cmpi.w	#$4DA,$38(a0)
		beq.s	loc_19424
		blt.s	loc_1941C
		neg.w	d0

loc_1941C:
		tst.w	$36(a0)
		add.w	d0,$38(a0)

loc_19424:
		moveq	#0,d0
		tst.w	$36(a0)
		beq.s	loc_19438
		moveq	#2,d0
		btst	#0,standonobject(a0)
		beq.s	loc_19438
		neg.w	d0

loc_19438:
		add.w	$38(a0),d0
		move.w	d0,ost_y_pos(a0)
		move.w	$30(a0),8(a0)

loc_19446:
		bra.w	loc_19202

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj75_FindBlocks:
		clr.w	$36(a0)
		lea	(v_objspace+$40).w,a1
		moveq	#$3E,d0
		moveq	#$76,d1
		move.b	$34(a0),d2

Obj75_FindLoop:
		cmp.b	(a1),d1		; is object a SYZ boss block?
		bne.s	loc_1946A	; if not, branch
		cmp.b	ost_subtype(a1),d2
		bne.s	loc_1946A
		move.w	a1,$36(a0)
		bra.s	locret_19472
; ===========================================================================

loc_1946A:
		lea	$40(a1),a1	; next object RAM entry
		dbf	d0,Obj75_FindLoop

locret_19472:
		rts	
; End of function Obj75_FindBlocks

; ===========================================================================

loc_19474:
		subq.w	#1,$3C(a0)
		bmi.s	loc_1947E
		bra.w	BossDefeated
; ===========================================================================

loc_1947E:
		addq.b	#2,ost_routine2(a0)
		clr.w	ost_y_vel(a0)
		bset	#0,ost_status(a0)
		bclr	#7,ost_status(a0)
		clr.w	ost_x_vel(a0)
		move.w	#-1,$3C(a0)
		tst.b	(v_bossstatus).w
		bne.s	loc_194A8
		move.b	#1,(v_bossstatus).w

loc_194A8:
		bra.w	loc_19202
; ===========================================================================

loc_194AC:
		addq.w	#1,$3C(a0)
		beq.s	loc_194BC
		bpl.s	loc_194C2
		addi.w	#$18,ost_y_vel(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194BC:
		clr.w	ost_y_vel(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194C2:
		cmpi.w	#$20,$3C(a0)
		bcs.s	loc_194DA
		beq.s	loc_194E0
		cmpi.w	#$2A,$3C(a0)
		bcs.s	loc_194EE
		addq.b	#2,ost_routine2(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194DA:
		subq.w	#8,ost_y_vel(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194E0:
		clr.w	ost_y_vel(a0)
		music	bgm_SYZ,0,0,0		; play SYZ music

loc_194EE:
		bra.w	loc_191F2
; ===========================================================================

loc_194F2:
		move.w	#$400,ost_x_vel(a0)
		move.w	#-$40,ost_y_vel(a0)
		cmpi.w	#$2D40,(v_limitright2).w
		bcc.s	loc_1950C
		addq.w	#2,(v_limitright2).w
		bra.s	loc_19512
; ===========================================================================

loc_1950C:
		tst.b	ost_render(a0)
		bpl.s	Obj75_ShipDelete

loc_19512:
		bsr.w	BossMove
		bra.w	loc_191DE
; ===========================================================================

Obj75_ShipDelete:
		jmp	(DeleteObject).l
; ===========================================================================

Obj75_FaceMain:	; Routine 4
		moveq	#1,d1
		movea.l	$34(a0),a1
		moveq	#0,d0
		move.b	ost_routine2(a1),d0
		move.w	off_19546(pc,d0.w),d0
		jsr	off_19546(pc,d0.w)
		move.b	d1,ost_anim(a0)
		move.b	(a0),d0
		cmp.b	(a1),d0
		bne.s	Obj75_FaceDelete
		bra.s	loc_195BE
; ===========================================================================

Obj75_FaceDelete:
		jmp	(DeleteObject).l
; ===========================================================================
off_19546:	index *
		ptr loc_19574
		ptr loc_19574
		ptr loc_1955A
		ptr loc_19552
		ptr loc_19552
		ptr loc_19556
; ===========================================================================

loc_19552:
		moveq	#$A,d1
		rts	
; ===========================================================================

loc_19556:
		moveq	#6,d1
		rts	
; ===========================================================================

loc_1955A:
		moveq	#0,d0
		move.b	ost_subtype(a1),d0
		move.w	off_19568(pc,d0.w),d0
		jmp	off_19568(pc,d0.w)
; ===========================================================================
off_19568:	index *
		ptr loc_19570
		ptr loc_19572
		ptr loc_19570
		ptr loc_19570
; ===========================================================================

loc_19570:
		bra.s	loc_19574
; ===========================================================================

loc_19572:
		moveq	#6,d1

loc_19574:
		tst.b	ost_col_type(a1)
		bne.s	loc_1957E
		moveq	#5,d1
		rts	
; ===========================================================================

loc_1957E:
		cmpi.b	#4,(v_player+ost_routine).w
		bcs.s	locret_19588
		moveq	#4,d1

locret_19588:
		rts	
; ===========================================================================

Obj75_FlameMain:; Routine 6
		move.b	#7,ost_anim(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,ost_routine2(a1)
		bne.s	loc_195AA
		move.b	#$B,ost_anim(a0)
		tst.b	1(a0)
		bpl.s	Obj75_FlameDelete
		bra.s	loc_195B6
; ===========================================================================

loc_195AA:
		tst.w	ost_x_vel(a1)
		beq.s	loc_195B6
		move.b	#8,ost_anim(a0)

loc_195B6:
		bra.s	loc_195BE
; ===========================================================================

Obj75_FlameDelete:
		jmp	(DeleteObject).l
; ===========================================================================

loc_195BE:
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
		movea.l	$34(a0),a1
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)

loc_195DA:
		move.b	ost_status(a1),ost_status(a0)
		moveq	#3,d0
		and.b	ost_status(a0),d0
		andi.b	#$FC,ost_render(a0)
		or.b	d0,ost_render(a0)
		jmp	(DisplaySprite).l
; ===========================================================================

Obj75_SpikeMain:; Routine 8
		move.l	#Map_BossItems,ost_mappings(a0)
		move.w	#tile_Nem_Weapons+tile_pal2,ost_tile(a0)
		move.b	#5,ost_frame(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,ost_routine2(a1)
		bne.s	loc_1961C
		tst.b	ost_render(a0)
		bpl.s	Obj75_SpikeDelete

loc_1961C:
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.w	$3C(a0),d0
		cmpi.b	#4,ost_routine2(a1)
		bne.s	loc_19652
		cmpi.b	#6,ost_subtype(a1)
		beq.s	loc_1964C
		tst.b	ost_subtype(a1)
		bne.s	loc_19658
		cmpi.w	#$94,d0
		bge.s	loc_19658
		addq.w	#7,d0
		bra.s	loc_19658
; ===========================================================================

loc_1964C:
		tst.w	$3C(a1)
		bpl.s	loc_19658

loc_19652:
		tst.w	d0
		ble.s	loc_19658
		subq.w	#5,d0

loc_19658:
		move.w	d0,$3C(a0)
		asr.w	#2,d0
		add.w	d0,ost_y_pos(a0)
		move.b	#8,ost_actwidth(a0)
		move.b	#$C,ost_height(a0)
		clr.b	ost_col_type(a0)
		movea.l	$34(a0),a1
		tst.b	ost_col_type(a1)
		beq.s	loc_19688
		tst.b	$29(a1)
		bne.s	loc_19688
		move.b	#$84,ost_col_type(a0)

loc_19688:
		bra.w	loc_195DA
; ===========================================================================

Obj75_SpikeDelete:
		jmp	(DeleteObject).l

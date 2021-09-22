; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)
; ---------------------------------------------------------------------------

Scenery:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Scen_Index(pc,d0.w),d1
		jmp	Scen_Index(pc,d1.w)
; ===========================================================================
Scen_Index:	index *
		ptr Scen_Main
		ptr Scen_ChkDel
; ===========================================================================

Scen_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0 ; copy object subtype to d0
		mulu.w	#$A,d0		; multiply by $A
		lea	Scen_Values(pc,d0.w),a1
		move.l	(a1)+,ost_mappings(a0)
		move.w	(a1)+,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	(a1)+,ost_frame(a0)
		move.b	(a1)+,ost_actwidth(a0)
		move.b	(a1)+,ost_priority(a0)
		move.b	(a1)+,ost_col_type(a0)

Scen_ChkDel:	; Routine 2
		out_of_range	DeleteObject
		bra.w	DisplaySprite
		
; ---------------------------------------------------------------------------
; Variables for	object $1C are stored in an array
; ---------------------------------------------------------------------------
Scen_Values:	dc.l Map_Scen		; mappings address
		dc.w tile_Nem_SlzCannon+tile_pal3 ; VRAM setting
		dc.b id_frame_scen_cannon, 8, 2, 0 ; frame, width, priority, collision response
		dc.l Map_Scen
		dc.w tile_Nem_SlzCannon+tile_pal3
		dc.b id_frame_scen_cannon, 8, 2, 0
		dc.l Map_Scen
		dc.w tile_Nem_SlzCannon+tile_pal3
		dc.b id_frame_scen_cannon, 8, 2, 0
		dc.l Map_Bri
		dc.w tile_Nem_Bridge+tile_pal3
		dc.b id_frame_bridge_stump, $10, 1, 0
		even

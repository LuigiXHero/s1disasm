; ---------------------------------------------------------------------------
; Animation script - shield and invincibility stars
; ---------------------------------------------------------------------------
		index *
		ptr @shield
		ptr @stars1
		ptr @stars2
		ptr @stars3
		ptr @stars4
		
@shield:	dc.b 1,	1, 0, 2, 0, 3, 0, afEnd
@stars1:	dc.b 5,	4, 5, 6, 7, afEnd
@stars2:	dc.b 0,	4, 4, 0, 4, 4, 0, 5, 5,	0, 5, 5, 0, 6, 6, 0, 6
		dc.b 6,	0, 7, 7, 0, 7, 7, 0, afEnd
@stars3:	dc.b 0,	4, 4, 0, 4, 0, 0, 5, 5,	0, 5, 0, 0, 6, 6, 0, 6
		dc.b 0,	0, 7, 7, 0, 7, 0, 0, afEnd
@stars4:	dc.b 0,	4, 0, 0, 4, 0, 0, 5, 0,	0, 5, 0, 0, 6, 0, 0, 6
		dc.b 0,	0, 7, 0, 0, 7, 0, 0, afEnd
		even

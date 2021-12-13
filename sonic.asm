;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth, Esrael L.G. Neto and the Sonic Retro Github

; ===========================================================================

		opt	l@					; @ is the local label symbol
		opt	ae-					; automatic even's are disabled by default
		opt	ws+					; allow statements to contain white-spaces
		opt	w+					; print warnings
		opt	m+					; do not expand macros - if enabled, this can break assembling

		include "Mega Drive.asm"
		include "Macros - More CPUs.asm"
		include "Macros - 68k Extended.asm"
		include "Constants.asm"
		include "sound\Sounds.asm"
		include "sound\Sound Equates.asm"
		include "RAM Addresses.asm"
		include "Macros - General.asm"
		include "Macros - Sonic.asm"
		include "Includes\Compatibility.asm"

		cpu	68000

EnableSRAM:	equ 0						; change to 1 to enable SRAM
BackupSRAM:	equ 1
AddressSRAM:	equ 3						; 0 = odd+even; 2 = even only; 3 = odd only

; Change to 0 to build the original version of the game, dubbed REV00
; Change to 1 to build the later vesion, dubbed REV01, which includes various bugfixes and enhancements
; Change to 2 to build the version from Sonic Mega Collection, dubbed REVXB, which fixes the infamous "spike bug"
	if ~def(Revision)					; bit-perfect check will automatically set this variable
Revision:	equ 1
	endc

ZoneCount:	equ 6						; discrete zones are: GHZ, MZ, SYZ, LZ, SLZ, and SBZ

		include "Nemesis File List.asm"
; ===========================================================================

StartOfRom:
Vectors:	dc.l v_stack_pointer&$FFFFFF			; Initial stack pointer value
		dc.l EntryPoint					; Start of program
		dc.l BusError					; Bus error
		dc.l AddressError				; Address error (4)
		dc.l IllegalInstr				; Illegal instruction
		dc.l ZeroDivide					; Division by zero
		dc.l ChkInstr					; CHK exception
		dc.l TrapvInstr					; TRAPV exception (8)
		dc.l PrivilegeViol				; Privilege violation
		dc.l Trace					; TRACE exception
		dc.l Line1010Emu				; Line-A emulator
		dc.l Line1111Emu				; Line-F emulator (12)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (16)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (20)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (24)
		dc.l ErrorExcept				; Spurious exception
		dc.l ErrorTrap					; IRQ level 1
		dc.l ErrorTrap					; IRQ level 2
		dc.l ErrorTrap					; IRQ level 3 (28)
		dc.l HBlank					; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap					; IRQ level 5
		dc.l VBlank					; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap					; IRQ level 7 (32)
		dc.l ErrorTrap					; TRAP #00 exception
		dc.l ErrorTrap					; TRAP #01 exception
		dc.l ErrorTrap					; TRAP #02 exception
		dc.l ErrorTrap					; TRAP #03 exception (36)
		dc.l ErrorTrap					; TRAP #04 exception
		dc.l ErrorTrap					; TRAP #05 exception
		dc.l ErrorTrap					; TRAP #06 exception
		dc.l ErrorTrap					; TRAP #07 exception (40)
		dc.l ErrorTrap					; TRAP #08 exception
		dc.l ErrorTrap					; TRAP #09 exception
		dc.l ErrorTrap					; TRAP #10 exception
		dc.l ErrorTrap					; TRAP #11 exception (44)
		dc.l ErrorTrap					; TRAP #12 exception
		dc.l ErrorTrap					; TRAP #13 exception
		dc.l ErrorTrap					; TRAP #14 exception
		dc.l ErrorTrap					; TRAP #15 exception (48)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		if Revision<>2
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
			dc.l ErrorTrap				; Unused (reserved)
		else
	loc_E0:
								; Relocated code from Spik_Hurt. REVXB was a nasty hex-edit.
			move.l	ost_y_pos(a0),d3
			move.w	ost_y_vel(a0),d0
			ext.l	d0
			asl.l	#8,d0
			jmp	(loc_D5A2).l

			dc.w ErrorTrap
			dc.l ErrorTrap
			dc.l ErrorTrap
			dc.l ErrorTrap
		endc
Console:	dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name)
Date:		dc.b "(C)SEGA 1991.APR"				; Copyright holder and release date (generally year)
Title_Local:	dc.b "SONIC THE               HEDGEHOG                " ; Domestic name
Title_Int:	dc.b "SONIC THE               HEDGEHOG                " ; International name

Serial:
	if Revision=0
		dc.b "GM 00001009-00"				; Serial/version number (Rev 0)
	else
		dc.b "GM 00004049-01"				; Serial/version number (Rev non-0)
	endc

Checksum: 	dc.w $0
		dc.b "J               "				; I/O support
RomStartLoc:	dc.l StartOfRom					; Start address of ROM
RomEndLoc:	dc.l EndOfRom-1					; End address of ROM
RamStartLoc:	dc.l $FF0000					; Start address of RAM
RamEndLoc:	dc.l $FFFFFF					; End address of RAM

SRAMSupport:
	if EnableSRAM=1
		dc.b "RA", $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
		dc.l $200001					; SRAM start
		dc.l $200FFF					; SRAM end
	else
		dc.l $20202020					; dummy values (SRAM disabled)
		dc.l $20202020					; SRAM start
		dc.l $20202020					; SRAM end
	endc

Notes:		dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
Region:		dc.b "JUE             "				; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too

ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap
; ===========================================================================

EntryPoint:
		tst.l	(port_1_control_hi).l			; test port A & B control registers
		bne.s	PortA_Ok
		tst.w	(port_e_control_hi).l			; test port C control register

PortA_Ok:
		bne.s	SkipSetup				; Skip the VDP and Z80 setup code if port A, B or C is ok...?
		lea	SetupValues(pc),a5			; Load setup values array address.
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	console_version-z80_bus_request(a1),d0	; get hardware version (from $A10001)
		andi.b	#$F,d0
		beq.s	SkipSecurity				; If the console has no TMSS, skip the security stuff.
		move.l	#'SEGA',tmss_sega-z80_bus_request(a1)	; move "SEGA" to TMSS register ($A14000)

SkipSecurity:
		move.w	(a4),d0					; clear write-pending flag in VDP to prevent issues if the 68k has been reset in the middle of writing a command long word to the VDP.
		moveq	#0,d0					; clear d0
		movea.l	d0,a6					; clear a6
		move.l	a6,usp					; set usp to $0

		moveq	#SetupVDP_end-SetupVDP-1,d1
VDPInitLoop:
		move.b	(a5)+,d5				; add $8000 to value
		move.w	d5,(a4)					; move value to	VDP register
		add.w	d7,d5					; next register
		dbf	d1,VDPInitLoop

		move.l	(a5)+,(a4)
		move.w	d0,(a3)					; clear	the VRAM
		move.w	d7,(a1)					; stop the Z80
		move.w	d7,(a2)					; reset	the Z80

@waitz80
		btst	d0,(a1)					; has the Z80 stopped?
		bne.s	@waitz80				; if not, branch
		moveq	#Z80_Startup_size-1,d2			; load the number of bytes in Z80_Startup program into d2

@loadz80
		move.b	(a5)+,(a0)+				; load the Z80_Startup program byte by byte to Z80 RAM
		dbf	d2,@loadz80

		move.w	d0,(a2)
		move.w	d0,(a1)					; start	the Z80
		move.w	d7,(a2)					; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)				; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop				; repeat until the entire RAM is clear
		move.l	(a5)+,(a4)				; set VDP display mode and increment mode
		move.l	(a5)+,(a4)				; set VDP to CRAM write

		moveq	#$1F,d3					; set repeat times
ClrCRAMLoop:
		move.l	d0,(a3)					; clear 2 palettes
		dbf	d3,ClrCRAMLoop				; repeat until the entire CRAM is clear
		move.l	(a5)+,(a4)				; set VDP to VSRAM write

		moveq	#$13,d4
ClrVSRAMLoop:
		move.l	d0,(a3)					; clear 4 bytes of VSRAM.
		dbf	d4,ClrVSRAMLoop				; repeat until the entire VSRAM is clear
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)				; reset	the PSG
		dbf	d5,PSGInitLoop				; repeat for other channels
		move.w	d0,(a2)
		movem.l	(a6),d0-a6				; clear all registers
		disable_ints

SkipSetup:
		bra.s	GameProgram				; begin game

; ===========================================================================
SetupValues:	dc.w $8000					; VDP register start number
		dc.w $3FFF					; size of RAM/4
		dc.w $100					; VDP register diff

		dc.l z80_ram					; start	of Z80 RAM
		dc.l z80_bus_request				; Z80 bus request
		dc.l z80_reset					; Z80 reset
		dc.l vdp_data_port				; VDP data
		dc.l vdp_control_port				; VDP control

SetupVDP:	dc.b 4						; VDP $80 - normal colour mode
		dc.b $14					; VDP $81 - Mega Drive mode, DMA enable
		dc.b ($C000>>10)				; VDP $82 - foreground nametable address
		dc.b ($F000>>10)				; VDP $83 - window nametable address
		dc.b ($E000>>13)				; VDP $84 - background nametable address
		dc.b ($D800>>9)					; VDP $85 - sprite table address
		dc.b 0						; VDP $86 - unused
		dc.b 0						; VDP $87 - background colour
		dc.b 0						; VDP $88 - unused
		dc.b 0						; VDP $89 - unused
		dc.b 255					; VDP $8A - HBlank register
		dc.b 0						; VDP $8B - full screen scroll
		dc.b $81					; VDP $8C - 40 cell display
		dc.b ($DC00>>10)				; VDP $8D - hscroll table address
		dc.b 0						; VDP $8E - unused
		dc.b 1						; VDP $8F - VDP increment
		dc.b 1						; VDP $90 - 64x32 cell plane size
		dc.b 0						; VDP $91 - window h position
		dc.b 0						; VDP $92 - window v position
		dc.w $FFFF					; VDP $93/94 - DMA length
		dc.w 0						; VDP $95/96 - DMA source
		dc.b $80					; VDP $97 - DMA fill VRAM
SetupVDP_end:
		dc.l $40000080					; VRAM address 0

Z80_Startup:
		cpu	z80
		phase 	0

	; fill the Z80 RAM with 00's (with the exception of this program)
		xor	a					; a = 00h
		ld	bc,2000h-(@end+1)			; load the number of bytes to fill
		ld	de,@end+1				; load the destination address of the RAM fill (1 byte after end of program)
		ld	hl,@end					; load the source address of the RAM fill (a single 00 byte)
		ld	sp,hl					; set stack pointer to end of program(?)
		ld	(hl),a					; clear the first byte after the program code
		ldir						; fill the rest of the Z80 RAM with 00's

	; clear all registers
		pop	ix
		pop	iy
		ld	i,a
		ld	r,a
		pop	de
		pop	hl
		pop	af

		ex	af,af					; swap af with af'
		exx						; swap bc, de, and hl
		pop	bc
		pop	de
		pop	hl
		pop	af
		ld	sp,hl					; clear stack pointer

	; put z80 into an infinite loop
		di						; disable interrupts
		im	1					; set interrupt mode to 1 (the only officially supported interrupt mode on the MD)
		ld	(hl),0E9h				; set the first byte into a jp	(hl) instruction
		jp	(hl)					; jump to the first byte, causing an infinite loop to occur.

	@end:							; the space from here til end of Z80 RAM will be filled with 00's
		even						; align the Z80 start up code to the next even byte. Values below require alignment

Z80_Startup_size:
		cpu	68000
		dephase

		dc.w $8104					; VDP display mode
		dc.w $8F02					; VDP increment
		dc.l $C0000000					; CRAM write mode
		dc.l $40000010					; VSRAM address 0

		dc.b $9F, $BF, $DF, $FF				; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,(port_e_control).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',(v_checksum_pass).w		; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
		movea.l	#EndOfHeader,a0				; start	checking bytes after the header	($200)
		movea.l	#RomEndLoc,a1				; stop at end of ROM
		move.l	(a1),d0
		moveq	#0,d1

	@loop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bhs.s	@loop
		movea.l	#Checksum,a1				; read the checksum
		cmp.w	(a1),d1					; compare checksum in header to ROM
		bne.w	CheckSumError				; if they don't match, branch

	CheckSumOk:
		lea	(v_keep_after_reset).w,a6		; $FFFFFE00
		moveq	#0,d7
		move.w	#(($FFFFFFFF-v_keep_after_reset+1)/4)-1,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM				; clear RAM ($FE00-$FFFF)

		move.b	(console_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_console_region).w			; get region setting
		move.l	#'init',(v_checksum_pass).w		; set flag so checksum won't run again

GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#((v_keep_after_reset&$FFFF)/4)-1,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM				; clear RAM ($0000-$FDFF)

		bsr.w	VDPSetupGame
		bsr.w	DacDriverLoad
		bsr.w	JoypadInit
		move.b	#id_Sega,(v_gamemode).w			; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$1C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------
gmptr:		macro
		id_\1:	equ *-GameModeArray
		if narg=1
		bra.w	GM_\1
		else
		bra.w	GM_\2
		endc
		endm

GameModeArray:
		gmptr Sega					; Sega Screen ($00)
		gmptr Title					; Title	Screen ($04)
		gmptr Demo, Level				; Demo Mode ($08)
		gmptr Level					; Normal Level ($0C)
		gmptr Special					; Special Stage	($10)
		gmptr Continue					; Continue Screen ($14)
		gmptr Ending					; End of game sequence ($18)
		gmptr Credits					; Credits ($1C)
		rts
; ===========================================================================

CheckSumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		moveq	#$3F,d7

	@fillred:
		move.w	#cRed,(vdp_data_port).l			; fill palette with red
		dbf	d7,@fillred				; repeat $3F more times

	@endlessloop:
		bra.s	@endlessloop
; ===========================================================================

BusError:
		move.b	#2,(v_error_type).w
		bra.s	loc_43A

AddressError:
		move.b	#4,(v_error_type).w
		bra.s	loc_43A

IllegalInstr:
		move.b	#6,(v_error_type).w
		addq.l	#2,2(sp)
		bra.s	loc_462

ZeroDivide:
		move.b	#8,(v_error_type).w
		bra.s	loc_462

ChkInstr:
		move.b	#$A,(v_error_type).w
		bra.s	loc_462

TrapvInstr:
		move.b	#$C,(v_error_type).w
		bra.s	loc_462

PrivilegeViol:
		move.b	#$E,(v_error_type).w
		bra.s	loc_462

Trace:
		move.b	#$10,(v_error_type).w
		bra.s	loc_462

Line1010Emu:
		move.b	#$12,(v_error_type).w
		addq.l	#2,2(sp)
		bra.s	loc_462

Line1111Emu:
		move.b	#$14,(v_error_type).w
		addq.l	#2,2(sp)
		bra.s	loc_462

ErrorExcept:
		move.b	#0,(v_error_type).w
		bra.s	loc_462
; ===========================================================================

loc_43A:
		disable_ints
		addq.w	#2,sp
		move.l	(sp)+,(v_sp_buffer).w
		addq.w	#2,sp
		movem.l	d0-a7,(v_reg_buffer).w
		bsr.w	ShowErrorMessage
		move.l	2(sp),d0
		bsr.w	ShowErrorValue
		move.l	(v_sp_buffer).w,d0
		bsr.w	ShowErrorValue
		bra.s	loc_478
; ===========================================================================

loc_462:
		disable_ints
		movem.l	d0-a7,(v_reg_buffer).w
		bsr.w	ShowErrorMessage
		move.l	2(sp),d0
		bsr.w	ShowErrorValue

loc_478:
		bsr.w	ErrorWaitForC
		movem.l	(v_reg_buffer).w,d0-a7
		enable_ints
		rte	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowErrorMessage:
		lea	(vdp_data_port).l,a6
		locVRAM	$F800
		lea	(Art_Text).l,a0				; level select text graphics
		move.w	#((sizeof_art_text-$20)/2)-1,d1		; -$20 because the last letter (X) is missed off
	@loadgfx:
		move.w	(a0)+,(a6)
		dbf	d1,@loadgfx

		moveq	#0,d0					; clear	d0
		move.b	(v_error_type).w,d0			; load error code
		move.w	ErrorText(pc,d0.w),d0
		lea	ErrorText(pc,d0.w),a0
		locVRAM	(vram_fg+$604)
		moveq	#$12,d1					; number of characters (minus 1)

	@showchars:
		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#$790,d0
		move.w	d0,(a6)
		dbf	d1,@showchars				; repeat for number of characters
		rts	
; End of function ShowErrorMessage

; ===========================================================================
ErrorText:	index *
		ptr @exception
		ptr @bus
		ptr @address
		ptr @illinstruct
		ptr @zerodivide
		ptr @chkinstruct
		ptr @trapv
		ptr @privilege
		ptr @trace
		ptr @line1010
		ptr @line1111
@exception:	dc.b "ERROR EXCEPTION    "
@bus:		dc.b "BUS ERROR          "
@address:	dc.b "ADDRESS ERROR      "
@illinstruct:	dc.b "ILLEGAL INSTRUCTION"
@zerodivide:	dc.b "@ERO DIVIDE        "
@chkinstruct:	dc.b "CHK INSTRUCTION    "
@trapv:		dc.b "TRAPV INSTRUCTION  "
@privilege:	dc.b "PRIVILEGE VIOLATION"
@trace:		dc.b "TRACE              "
@line1010:	dc.b "LINE 1010 EMULATOR "
@line1111:	dc.b "LINE 1111 EMULATOR "
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowErrorValue:
		move.w	#$7CA,(a6)				; display "$" symbol
		moveq	#7,d2

	@loop:
		rol.l	#4,d0
		bsr.s	@shownumber				; display 8 numbers
		dbf	d2,@loop
		rts	
; End of function ShowErrorValue


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


@shownumber:
		move.w	d0,d1
		andi.w	#$F,d1
		cmpi.w	#$A,d1
		blo.s	@chars0to9
		addq.w	#7,d1					; add 7 for characters A-F

	@chars0to9:
		addi.w	#$7C0,d1
		move.w	d1,(a6)
		rts	
; End of function sub_5CA


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ErrorWaitForC:
		bsr.w	ReadJoypads
		cmpi.b	#btnC,(v_joypad_press_actual).w		; is button C pressed?
		bne.w	ErrorWaitForC				; if not, branch
		rts	
; End of function ErrorWaitForC

; ===========================================================================

Art_Text:	incbin	"Graphics\Level Select & Debug Text.bin" ; text used in level select and debug mode
		even

		include	"Includes\VBlank & HBlank.asm"

; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,(port_1_control).l			; init port 1 (joypad 1)
		move.b	d0,(port_2_control).l			; init port 2 (joypad 2)
		move.b	d0,(port_e_control).l			; init port 3 (expansion/extra)
		startZ80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(v_joypad_hold_actual).w,a0		; address where joypad states are written
		lea	(port_1_data).l,a1			; first joypad port
		bsr.s	@read					; do the first joypad
		addq.w	#2,a1					; do the second	joypad

	@read:
		move.b	#0,(a1)					; set port to read 00SA00DU
		nop	
		nop	
		move.b	(a1),d0					; d0 = 00SA00DU
		lsl.b	#2,d0					; d0 = SA00DU00
		andi.b	#$C0,d0					; d0 = SA000000
		move.b	#$40,(a1)				; set port to read 00CBRLDU
		nop	
		nop	
		move.b	(a1),d1					; d1 = 00CBRLDU
		andi.b	#$3F,d1					; d1 = 00CBRLDU
		or.b	d1,d0					; d0 = SACBRLDU
		not.b	d0					; invert bits
		move.b	(a0),d1					; d1 = previous joypad state
		eor.b	d0,d1
		move.b	d0,(a0)+				; v_joypad_hold_actual = SACBRLDU
		and.b	d0,d1					; d1 = new joypad inputs only
		move.b	d1,(a0)+				; v_joypad_press_actual = SACBRLDU (new only)
		rts	
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea	(vdp_control_port).l,a0
		lea	(vdp_data_port).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#((VDPSetupArray_end-VDPSetupArray)/2)-1,d7

	@setreg:
		move.w	(a2)+,(a0)
		dbf	d7,@setreg				; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_mode_buffer).w		; save $8134 to buffer for later use
		move.w	#$8A00+223,(v_vdp_hint_counter).w	; horizontal interrupt every 224th scanline
		moveq	#0,d0
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		move.w	#$40-1,d7

	@clrCRAM:
		move.w	d0,(a1)
		dbf	d7,@clrCRAM				; clear	the CRAM

		clr.l	(v_fg_y_pos_vsram).w
		clr.l	(v_fg_x_pos_hscroll).w
		move.l	d1,-(sp)
		dma_fill	0,$FFFF,0

	@waitforDMA:
		move.w	(a5),d1
		btst	#1,d1					; is dma_fill still running?
		bne.s	@waitforDMA				; if yes, branch

		move.w	#$8F02,(a5)				; set VDP increment size
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004					; normal colour mode
		dc.w $8134					; enable V.interrupts, enable DMA
		dc.w $8200+(vram_fg>>10)			; set foreground nametable address
		dc.w $8300+(vram_window>>10)			; set window nametable address
		dc.w $8400+(vram_bg>>13)			; set background nametable address
		dc.w $8500+(vram_sprites>>9)			; set sprite table address
		dc.w $8600					; unused
		dc.w $8700					; set background colour (palette entry 0)
		dc.w $8800					; unused
		dc.w $8900					; unused
		dc.w $8A00					; default H.interrupt register
		dc.w $8B00					; full-screen vertical scrolling
		dc.w $8C81					; 40-cell display mode
		dc.w $8D00+(vram_hscroll>>10)			; set background hscroll address
		dc.w $8E00					; unused
		dc.w $8F02					; set VDP increment size
		dc.w $9001					; 64x32 cell plane size
		dc.w $9100					; window horizontal position
		dc.w $9200					; window vertical position
	VDPSetupArray_end:

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		dma_fill	0,$FFF,vram_fg			; clear foreground namespace

	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		dma_fill	0,$FFF,vram_bg			; clear background namespace

	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		if Revision=0
		move.l	#0,(v_fg_y_pos_vsram).w
		move.l	#0,(v_fg_x_pos_hscroll).w
		else
		clr.l	(v_fg_y_pos_vsram).w
		clr.l	(v_fg_x_pos_hscroll).w
		endc

		lea	(v_sprite_buffer).w,a1
		moveq	#0,d0
		move.w	#($280/4),d1				; This should be ($280/4)-1, leading to a slight bug (first bit of v_pal_water is cleared)

	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites			; clear sprite table (in RAM)

		lea	(v_hscroll_buffer).w,a1
		moveq	#0,d0
		move.w	#($400/4),d1				; This should be ($400/4)-1, leading to a slight bug (first bit of the Sonic object's RAM is cleared)

	@clearhscroll:
		move.l	d0,(a1)+
		dbf	d1,@clearhscroll			; clear hscroll table (in RAM)
		rts	
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Functions for loading the DAC driver and playing sounds
; ---------------------------------------------------------------------------

	include "sound/PlaySound + DacDriverLoad.asm"

; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:
		nop	
		tst.b	(v_lives).w				; do you have any lives	left?
		beq.s	Unpause					; if not, branch
		tst.w	(f_pause).w				; is game already paused?
		bne.s	Pause_StopGame				; if yes, branch
		btst	#bitStart,(v_joypad_press_actual).w	; is Start button pressed?
		beq.s	Pause_DoNothing				; if not, branch

Pause_StopGame:
		move.w	#1,(f_pause).w				; freeze time
		move.b	#1,(v_snddriver_ram+f_pause_sound).w	; pause music

Pause_Loop:
		move.b	#id_VBlank_Pause,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		tst.b	(f_slowmotion_cheat).w			; is slow-motion cheat on?
		beq.s	Pause_ChkStart				; if not, branch
		btst	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	Pause_ChkBC				; if not, branch
		move.b	#id_Title,(v_gamemode).w		; set game mode to 4 (title screen)
		nop	
		bra.s	Pause_EndMusic
; ===========================================================================

Pause_ChkBC:
		btst	#bitB,(v_joypad_hold_actual).w		; is button B pressed?
		bne.s	Pause_SlowMo				; if yes, branch
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		bne.s	Pause_SlowMo				; if yes, branch

Pause_ChkStart:
		btst	#bitStart,(v_joypad_press_actual).w	; is Start button pressed?
		beq.s	Pause_Loop				; if not, branch

Pause_EndMusic:
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; unpause the music

Unpause:
		move.w	#0,(f_pause).w				; unpause the game

Pause_DoNothing:
		rts	
; ===========================================================================

Pause_SlowMo:
		move.w	#1,(f_pause).w
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; Unpause the music
		rts	
; End of function PauseGame

; ---------------------------------------------------------------------------
; Subroutine to	copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TilemapToVRAM:
		lea	(vdp_data_port).l,a6
		move.l	#sizeof_vram_row<<16,d4			; d4 = $800000

	@loop_row:
		move.l	d0,4(a6)				; move d0 to vdp_control_port
		move.w	d1,d3

	@loop_cell:
		move.w	(a1)+,(a6)				; write value to namespace
		dbf	d3,@loop_cell				; next tile
		add.l	d4,d0					; goto next line
		dbf	d2,@loop_row				; next line
		rts	
; End of function TilemapToVRAM

		include "Includes\Nemesis Decompression.asm"
		include "Includes\AddPLC, NewPLC, RunPLC, ProcessPLC & QuickPLC.asm"

		include "Includes\Enigma Decompression.asm"
		include "Includes\Kosinski Decompression.asm"

PaletteCycle:	include "Includes\PaletteCycle.asm"
Pal_TitleCyc:	incbin	"Palettes\Cycle - Title Screen Water.bin"
Pal_GHZCyc:	incbin	"Palettes\Cycle - GHZ.bin"
Pal_LZCyc1:	incbin	"Palettes\Cycle - LZ Waterfall.bin"
Pal_LZCyc2:	incbin	"Palettes\Cycle - LZ Conveyor Belt.bin"
Pal_LZCyc3:	incbin	"Palettes\Cycle - LZ Conveyor Belt Underwater.bin"
Pal_SBZ3Cyc1:	incbin	"Palettes\Cycle - SBZ3 Waterfall.bin"
Pal_SLZCyc:	incbin	"Palettes\Cycle - SLZ.bin"
Pal_SYZCyc1:	incbin	"Palettes\Cycle - SYZ1.bin"
Pal_SYZCyc2:	incbin	"Palettes\Cycle - SYZ2.bin"

; ---------------------------------------------------------------------------
; Scrap Brain Zone palette cycling script
; ---------------------------------------------------------------------------

mSBZp:	macro duration,colours,paladdress,ramaddress
	dc.b duration, colours
	dc.w paladdress, ramaddress
	endm

; duration in frames, number of colours, palette address, RAM address

Pal_SBZCycList1:
	dc.w ((end_SBZCycList1-Pal_SBZCycList1-2)/6)-1
	mSBZp	7,8,Pal_SBZCyc1,v_pal_dry+$50
	mSBZp	$D,8,Pal_SBZCyc2,v_pal_dry+$52
	mSBZp	$E,8,Pal_SBZCyc3,v_pal_dry+$6E
	mSBZp	$B,8,Pal_SBZCyc5,v_pal_dry+$70
	mSBZp	7,8,Pal_SBZCyc6,v_pal_dry+$72
	mSBZp	$1C,$10,Pal_SBZCyc7,v_pal_dry+$7E
	mSBZp	3,3,Pal_SBZCyc8,v_pal_dry+$78
	mSBZp	3,3,Pal_SBZCyc8+2,v_pal_dry+$7A
	mSBZp	3,3,Pal_SBZCyc8+4,v_pal_dry+$7C
end_SBZCycList1:
	even

Pal_SBZCycList2:
	dc.w ((end_SBZCycList2-Pal_SBZCycList2-2)/6)-1
	mSBZp	7,8,Pal_SBZCyc1,v_pal_dry+$50
	mSBZp	$D,8,Pal_SBZCyc2,v_pal_dry+$52
	mSBZp	9,8,Pal_SBZCyc9,v_pal_dry+$70
	mSBZp	7,8,Pal_SBZCyc6,v_pal_dry+$72
	mSBZp	3,3,Pal_SBZCyc8,v_pal_dry+$78
	mSBZp	3,3,Pal_SBZCyc8+2,v_pal_dry+$7A
	mSBZp	3,3,Pal_SBZCyc8+4,v_pal_dry+$7C
end_SBZCycList2:
	even

Pal_SBZCyc1:	incbin	"Palettes\Cycle - SBZ 1.bin"
Pal_SBZCyc2:	incbin	"Palettes\Cycle - SBZ 2.bin"
Pal_SBZCyc3:	incbin	"Palettes\Cycle - SBZ 3.bin"
Pal_SBZCyc4:	incbin	"Palettes\Cycle - SBZ 4.bin"
Pal_SBZCyc5:	incbin	"Palettes\Cycle - SBZ 5.bin"
Pal_SBZCyc6:	incbin	"Palettes\Cycle - SBZ 6.bin"
Pal_SBZCyc7:	incbin	"Palettes\Cycle - SBZ 7.bin"
Pal_SBZCyc8:	incbin	"Palettes\Cycle - SBZ 8.bin"
Pal_SBZCyc9:	incbin	"Palettes\Cycle - SBZ 9.bin"
Pal_SBZCyc10:	incbin	"Palettes\Cycle - SBZ 10.bin"

		include	"Includes\PaletteFadeIn, PaletteFadeOut, PaletteWhiteIn & PaletteWhiteOut.asm"
		include	"Includes\GM_Sega.asm"
Pal_Sega1:	incbin	"Palettes\Sega1.bin"
Pal_Sega2:	incbin	"Palettes\Sega2.bin"

		include "Includes\PalLoad & PalPointers.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------

Pal_SegaBG:	incbin	"Palettes\Sega Background.bin"
Pal_Title:	incbin	"Palettes\Title Screen.bin"
Pal_LevelSel:	incbin	"Palettes\Level Select.bin"
Pal_Sonic:	incbin	"Palettes\Sonic.bin"
Pal_GHZ:	incbin	"Palettes\Green Hill Zone.bin"
Pal_LZ:		incbin	"Palettes\Labyrinth Zone.bin"
Pal_LZWater:	incbin	"Palettes\Labyrinth Zone Underwater.bin"
Pal_MZ:		incbin	"Palettes\Marble Zone.bin"
Pal_SLZ:	incbin	"Palettes\Star Light Zone.bin"
Pal_SYZ:	incbin	"Palettes\Spring Yard Zone.bin"
Pal_SBZ1:	incbin	"Palettes\SBZ Act 1.bin"
Pal_SBZ2:	incbin	"Palettes\SBZ Act 2.bin"
Pal_Special:	incbin	"Palettes\Special Stage.bin"
Pal_SBZ3:	incbin	"Palettes\SBZ Act 3.bin"
Pal_SBZ3Water:	incbin	"Palettes\SBZ Act 3 Underwater.bin"
Pal_LZSonWater:	incbin	"Palettes\Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:	incbin	"Palettes\Sonic - SBZ3 Underwater.bin"
Pal_SSResult:	incbin	"Palettes\Special Stage Results.bin"
Pal_Continue:	incbin	"Palettes\Special Stage Continue Bonus.bin"
Pal_Ending:	incbin	"Palettes\Ending.bin"

		include "Includes\WaitForVBlank.asm"
		include "Objects\_RandomNumber.asm"
		include "Objects\_CalcSine & CalcAngle.asm"

		include_Sega					; "Includes\GM_Sega.asm"
		include "Includes\GM_Title.asm"

; ---------------------------------------------------------------------------
; Music playlist
; ---------------------------------------------------------------------------
MusicList:
		dc.b mus_GHZ					; GHZ
		dc.b mus_LZ					; LZ
		dc.b mus_MZ					; MZ
		dc.b mus_SLZ					; SLZ
		dc.b mus_SYZ					; SYZ
		dc.b mus_SBZ					; SBZ
		zonewarning MusicList,1
		dc.b mus_FZ					; Ending
		even
; ===========================================================================

		include "Includes\GM_Level.asm"
		include "Includes\LZWaterFeatures.asm"

		include "Includes\MoveSonicInDemo & DemoRecorder.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo sequence	pointers
; ---------------------------------------------------------------------------
DemoDataPtr:	dc.l Demo_GHZ					; demos run after the title screen
		dc.l Demo_GHZ
		dc.l Demo_MZ
		dc.l Demo_MZ
		dc.l Demo_SYZ
		dc.l Demo_SYZ
		dc.l Demo_SS
		dc.l Demo_SS

DemoEndDataPtr:	dc.l Demo_EndGHZ1				; demos run during the credits
		dc.l Demo_EndMZ
		dc.l Demo_EndSYZ
		dc.l Demo_EndLZ
		dc.l Demo_EndSLZ
		dc.l Demo_EndSBZ1
		dc.l Demo_EndSBZ2
		dc.l Demo_EndGHZ2

		; unused demo data
		dc.b   0, $8B,   8, $37,   0, $42,   8, $5C,   0, $6A,   8, $5F,   0, $2F,   8, $2C
		dc.b   0, $21,   8,   3, $28, $30,   8,   8,   0, $2E,   8, $15,   0,  $F,   8, $46
		dc.b   0, $1A,   8, $FF,   8, $CA,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
		even

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#2,d0
		move.l	ColPointers(pc,d0.w),(v_collision_index_ptr).w
		rts	
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:	dc.l Col_GHZ
		dc.l Col_LZ
		dc.l Col_MZ
		dc.l Col_SLZ
		dc.l Col_SYZ
		dc.l Col_SBZ
		zonewarning ColPointers,4
;		dc.l Col_GHZ ; Pointer for Ending is missing by default.

		include "Includes\OscillateNumInit & OscillateNumDo.asm"
		include "Includes\SynchroAnimate.asm"

; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SignpostArtLoad:
		tst.w	(v_debug_active).w			; is debug mode	being used?
		bne.w	@exit					; if yes, branch
		cmpi.b	#2,(v_act).w				; is act number 02 (act 3)?
		beq.s	@exit					; if yes, branch

		move.w	(v_camera_x_pos).w,d0
		move.w	(v_boundary_right).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0					; has Sonic reached the	edge of	the level?
		blt.s	@exit					; if not, branch
		tst.b	(f_hud_time_update).w
		beq.s	@exit
		cmp.w	(v_boundary_left).w,d1
		beq.s	@exit
		move.w	d1,(v_boundary_left).w			; move left boundary to current screen position
		moveq	#id_PLC_Signpost,d0
		bra.w	NewPLC					; load signpost	patterns

	@exit:
		rts	
; End of function SignpostArtLoad

; ===========================================================================
Demo_GHZ:	incbin	"demodata\Intro - GHZ.bin"
Demo_MZ:	incbin	"demodata\Intro - MZ.bin"
Demo_SYZ:	incbin	"demodata\Intro - SYZ.bin"
Demo_SS:	incbin	"demodata\Intro - Special Stage.bin"
; ===========================================================================

		include "Includes\GM_Special.asm"

Pal_SSCyc1:	incbin	"Palettes\Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	incbin	"Palettes\Cycle - Special Stage 2.bin"
		even

		include_Special_2				; Includes\GM_Special.asm

		include "Includes\GM_Continue.asm"

		include "Objects\Continue Screen Items.asm"	; ContScrItem
		include "Objects\Continue Screen Sonic.asm"	; ContSonic
		include "Animations\Continue Screen Sonic.asm"	; Ani_CSon
		include "Mappings\Continue Screen.asm"		; Map_ContScr

		include "Includes\GM_Ending.asm"

		include "Objects\Ending Sonic.asm"		; EndSonic
		include "Animations\Ending Sonic.asm"		; Ani_ESon

		include "Objects\Ending Chaos Emeralds.asm"	; EndChaos
		include "Objects\Ending StH Text.asm"		; EndSTH

		include "Mappings\Ending Sonic.asm"		; Map_ESon
		include "Mappings\Ending Chaos Emeralds.asm"	; Map_ECha
		include "Mappings\Ending StH Text.asm"		; Map_ESth

		include "Includes\GM_Credits.asm"

		include "Objects\Ending Eggman Try Again.asm"	; EndEggman
		include "Animations\Ending Eggman Try Again.asm" ; Ani_EEgg

		include "Objects\Ending Chaos Emeralds Try Again.asm" ; TryChaos

		include "Mappings\Ending Eggman Try Again.asm"	; Map_EEgg

; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	"demodata\Ending - GHZ1.bin"
		even
Demo_EndMZ:	incbin	"demodata\Ending - MZ.bin"
		even
Demo_EndSYZ:	incbin	"demodata\Ending - SYZ.bin"
		even
Demo_EndLZ:	incbin	"demodata\Ending - LZ.bin"
		even
Demo_EndSLZ:	incbin	"demodata\Ending - SLZ.bin"
		even
Demo_EndSBZ1:	incbin	"demodata\Ending - SBZ1.bin"
		even
Demo_EndSBZ2:	incbin	"demodata\Ending - SBZ2.bin"
		even
Demo_EndGHZ2:	incbin	"demodata\Ending - GHZ2.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelSizeLoad:
		moveq	#0,d0
		move.b	d0,(v_levelsizeload_unused_1).w
		move.b	d0,(v_levelsizeload_unused_2).w
		move.b	d0,(v_levelsizeload_unused_3).w
		move.b	d0,(v_levelsizeload_unused_4).w
		move.b	d0,(v_dle_routine).w
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	LevelSizeArray(pc,d0.w),a0		; load level boundaries
		move.w	(a0)+,d0
		move.w	d0,(v_boundary_unused).w
		move.l	(a0)+,d0
		move.l	d0,(v_boundary_left).w
		move.l	d0,(v_boundary_left_next).w
		move.l	(a0)+,d0
		move.l	d0,(v_boundary_top).w
		move.l	d0,(v_boundary_top_next).w
		move.w	(v_boundary_left).w,d0
		addi.w	#$240,d0
		move.w	d0,(v_boundary_left_unused).w
		move.w	#$1010,(v_fg_x_redraw_flag).w
		move.w	(a0)+,d0
		move.w	d0,(v_camera_y_shift).w
		bra.w	LevSz_ChkLamp
; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array
; ---------------------------------------------------------------------------
LevelSizeArray:
		; GHZ
		dc.w $0004, $0000, $24BF, $0000, $0300, $0060
		dc.w $0004, $0000, $1EBF, $0000, $0300, $0060
		dc.w $0004, $0000, $2960, $0000, $0300, $0060
		dc.w $0004, $0000, $2ABF, $0000, $0300, $0060
		; LZ
		dc.w $0004, $0000, $19BF, $0000, $0530, $0060
		dc.w $0004, $0000, $10AF, $0000, $0720, $0060
		dc.w $0004, $0000, $202F, $FF00, $0800, $0060
		dc.w $0004, $0000, $20BF, $0000, $0720, $0060
		; MZ
		dc.w $0004, $0000, $17BF, $0000, $01D0, $0060
		dc.w $0004, $0000, $17BF, $0000, $0520, $0060
		dc.w $0004, $0000, $1800, $0000, $0720, $0060
		dc.w $0004, $0000, $16BF, $0000, $0720, $0060
		; SLZ
		dc.w $0004, $0000, $1FBF, $0000, $0640, $0060
		dc.w $0004, $0000, $1FBF, $0000, $0640, $0060
		dc.w $0004, $0000, $2000, $0000, $06C0, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0720, $0060
		; SYZ
		dc.w $0004, $0000, $22C0, $0000, $0420, $0060
		dc.w $0004, $0000, $28C0, $0000, $0520, $0060
		dc.w $0004, $0000, $2C00, $0000, $0620, $0060
		dc.w $0004, $0000, $2EC0, $0000, $0620, $0060
		; SBZ
		dc.w $0004, $0000, $21C0, $0000, $0720, $0060
		dc.w $0004, $0000, $1E40, $FF00, $0800, $0060
		dc.w $0004, $2080, $2460, $0510, $0510, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0720, $0060
		zonewarning LevelSizeArray,$30
		; Ending
		dc.w $0004, $0000, $0500, $0110, $0110, $0060
		dc.w $0004, $0000, $0DC0, $0110, $0110, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060

; ---------------------------------------------------------------------------
; Ending start location array
; ---------------------------------------------------------------------------
EndingStLocArray:

		incbin	"startpos\ghz1 (Credits demo 1).bin"
		incbin	"startpos\mz2 (Credits demo).bin"
		incbin	"startpos\syz3 (Credits demo).bin"
		incbin	"startpos\lz3 (Credits demo).bin"
		incbin	"startpos\slz3 (Credits demo).bin"
		incbin	"startpos\sbz1 (Credits demo).bin"
		incbin	"startpos\sbz2 (Credits demo).bin"
		incbin	"startpos\ghz1 (Credits demo 2).bin"
		even

; ===========================================================================

LevSz_ChkLamp:
		tst.b	(v_last_lamppost).w			; have any lampposts been hit?
		beq.s	LevSz_StartLoc				; if not, branch

		jsr	(Lamp_LoadInfo).l
		move.w	(v_ost_player+ost_x_pos).w,d1
		move.w	(v_ost_player+ost_y_pos).w,d0
		bra.s	LevSz_SkipStartPos
; ===========================================================================

LevSz_StartLoc:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1		; load Sonic's start location
		tst.w	(v_demo_mode).w				; is ending demo mode on?
		bpl.s	LevSz_SonicPos				; if not, branch

		move.w	(v_credits_num).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	EndingStLocArray(pc,d0.w),a1		; load Sonic's start location

LevSz_SonicPos:
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,(v_ost_player+ost_x_pos).w		; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(v_ost_player+ost_y_pos).w		; set Sonic's position on y-axis

SetScreen:
	LevSz_SkipStartPos:
		subi.w	#160,d1					; is Sonic more than 160px from left edge?
		bcc.s	SetScr_WithinLeft			; if yes, branch
		moveq	#0,d1

	SetScr_WithinLeft:
		move.w	(v_boundary_right).w,d2
		cmp.w	d2,d1					; is Sonic inside the right edge?
		bcs.s	SetScr_WithinRight			; if yes, branch
		move.w	d2,d1

	SetScr_WithinRight:
		move.w	d1,(v_camera_x_pos).w			; set horizontal screen position

		subi.w	#96,d0					; is Sonic within 96px of upper edge?
		bcc.s	SetScr_WithinTop			; if yes, branch
		moveq	#0,d0

	SetScr_WithinTop:
		cmp.w	(v_boundary_bottom).w,d0		; is Sonic above the bottom edge?
		blt.s	SetScr_WithinBottom			; if yes, branch
		move.w	(v_boundary_bottom).w,d0

	SetScr_WithinBottom:
		move.w	d0,(v_camera_y_pos).w			; set vertical screen position
		bsr.w	BgScrollSpeed
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.b	#2,d0
		move.l	LoopTileNums(pc,d0.w),(v_256x256_with_loop_1).w
		if revision=0
		bra.w	LevSz_LoadScrollBlockSize
		else
		rts
		endc
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic start location array
; ---------------------------------------------------------------------------
StartLocArray:

		incbin	"startpos\ghz1.bin"
		incbin	"startpos\ghz2.bin"
		incbin	"startpos\ghz3.bin"
		dc.w	$80,$A8

		incbin	"startpos\lz1.bin"
		incbin	"startpos\lz2.bin"
		incbin	"startpos\lz3.bin"
		incbin	"startpos\sbz3.bin"

		incbin	"startpos\mz1.bin"
		incbin	"startpos\mz2.bin"
		incbin	"startpos\mz3.bin"
		dc.w	$80,$A8

		incbin	"startpos\slz1.bin"
		incbin	"startpos\slz2.bin"
		incbin	"startpos\slz3.bin"
		dc.w	$80,$A8

		incbin	"startpos\syz1.bin"
		incbin	"startpos\syz2.bin"
		incbin	"startpos\syz3.bin"
		dc.w	$80,$A8

		incbin	"startpos\sbz1.bin"
		incbin	"startpos\sbz2.bin"
		incbin	"startpos\fz.bin"
		dc.w	$80,$A8

		zonewarning StartLocArray,$10

		incbin	"startpos\end1.bin"
		incbin	"startpos\end2.bin"
		dc.w	$80,$A8
		dc.w	$80,$A8

		even

; ---------------------------------------------------------------------------
; Which	256x256	tiles contain loops or roll-tunnels
; ---------------------------------------------------------------------------

LoopTileNums:

; 		loop	loop	tunnel	tunnel

	dc.b	$B5,	$7F,	$1F,	$20			; Green Hill
	dc.b	$7F,	$7F,	$7F,	$7F			; Labyrinth
	dc.b	$7F,	$7F,	$7F,	$7F			; Marble
	dc.b	$AA,	$B4,	$7F,	$7F			; Star Light
	dc.b	$7F,	$7F,	$7F,	$7F			; Spring Yard
	dc.b	$7F,	$7F,	$7F,	$7F			; Scrap Brain
	zonewarning LoopTileNums,4
	dc.b	$7F,	$7F,	$7F,	$7F			; Ending (Green Hill)

		even

; ===========================================================================

		if revision=0

; LevSz_Unk:
LevSz_LoadScrollBlockSize:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#3,d0
		lea	BGScrollBlockSizes(pc,d0.w),a1
		lea	(v_scroll_block_1_height).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		rts	
; End of function LevelSizeLoad

; ===========================================================================
; dword_61B4:
BGScrollBlockSizes:
		; GHZ
		dc.w $70
		dc.w $100					; I guess these used to be per act?
		dc.w $100					; Or maybe each scroll block got its own size?
		dc.w $100					; Either way, these are unused now.
		; LZ
		dc.w $800
		dc.w $100
		dc.w $100
		dc.w 0
		; MZ
		dc.w $800
		dc.w $100
		dc.w $100
		dc.w 0
		; SLZ
		dc.w $800
		dc.w $100
		dc.w $100
		dc.w 0
		; SYZ
		dc.w $800
		dc.w $100
		dc.w $100
		dc.w 0
		; SBZ
		dc.w $800
		dc.w $100
		dc.w $100
		dc.w 0
		zonewarning BGScrollBlockSizes,8
		; Ending
		dc.w $70
		dc.w $100
		dc.w $100
		dc.w $100
		
		endc

; ---------------------------------------------------------------------------
; Subroutine to	set scroll speed of some backgrounds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BgScrollSpeed:
		tst.b	(v_last_lamppost).w
		bne.s	loc_6206
		move.w	d0,(v_bg1_y_pos).w
		move.w	d0,(v_bg2_y_pos).w
		move.w	d1,(v_bg1_x_pos).w
		move.w	d1,(v_bg2_x_pos).w
		move.w	d1,(v_bg3_x_pos).w

loc_6206:
		moveq	#0,d2
		move.b	(v_zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ===========================================================================
BgScroll_Index:	index *
		ptr BgScroll_GHZ
		ptr BgScroll_LZ
		ptr BgScroll_MZ
		ptr BgScroll_SLZ
		ptr BgScroll_SYZ
		ptr BgScroll_SBZ
		zonewarning BgScroll_Index,2
		ptr BgScroll_End
; ===========================================================================

BgScroll_GHZ:
		if revision=0
		bra.w	Deform_GHZ
		else
		clr.l	(v_bg1_x_pos).w
		clr.l	(v_bg1_y_pos).w
		clr.l	(v_bg2_y_pos).w
		clr.l	(v_bg3_y_pos).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
		endc
; ===========================================================================

BgScroll_LZ:
		asr.l	#1,d0
		move.w	d0,(v_bg1_y_pos).w
		rts	
; ===========================================================================

BgScroll_MZ:
		rts	
; ===========================================================================

BgScroll_SLZ:
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,(v_bg1_y_pos).w
		if revision=0
		else
		clr.l	(v_bg1_x_pos).w
		endc
		rts	
; ===========================================================================

BgScroll_SYZ:
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		if revision=0
		move.w	d0,(v_bg1_y_pos).w
		move.w	d0,(v_bg2_y_pos).w
		else
		addq.w	#1,d0
		move.w	d0,(v_bg1_y_pos).w
		clr.l	(v_bg1_x_pos).w
		endc
		rts	
; ===========================================================================

BgScroll_SBZ:
		if revision=0
		asl.l	#4,d0
		asl.l	#1,d0
		asr.l	#8,d0
		else
		andi.w	#$7F8,d0
		asr.w	#3,d0
		addq.w	#1,d0
		endc
		move.w	d0,(v_bg1_y_pos).w
		rts	
; ===========================================================================

BgScroll_End:
		if revision=0
		move.w	#$1E,(v_bg1_y_pos).w
		move.w	#$1E,(v_bg2_y_pos).w
		rts	
; ===========================================================================
		move.w	#$A8,(v_bg1_x_pos).w
		move.w	#$1E,(v_bg1_y_pos).w
		move.w	#-$40,(v_bg2_x_pos).w
		move.w	#$1E,(v_bg2_y_pos).w
		rts
		else
		move.w	(v_camera_x_pos).w,d0
		asr.w	#1,d0
		move.w	d0,(v_bg1_x_pos).w
		move.w	d0,(v_bg2_x_pos).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(v_bg3_x_pos).w
		clr.l	(v_bg1_y_pos).w
		clr.l	(v_bg2_y_pos).w
		clr.l	(v_bg3_y_pos).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
		endc

		include	"Includes\DeformLayers.asm"

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6886:
LoadTilesAsYouMove_BGOnly:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_redraw_direction).w,a2
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+$40).w,a4
		move.w	#$6000,d2
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_redraw_direction).w,a2
		lea	(v_bg2_x_pos).w,a3
		bra.w	DrawBGScrollBlock2
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		; First, update the background
		lea	(v_bg1_redraw_direction_copy).w,a2	; Scroll block 1 scroll flags
		lea	(v_bg1_x_pos_copy).w,a3			; Scroll block 1 X coordinate
		lea	(v_level_layout+$40).w,a4
		move.w	#$6000,d2				; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_redraw_direction_copy).w,a2	; Scroll block 2 scroll flags
		lea	(v_bg2_x_pos_copy).w,a3			; Scroll block 2 X coordinate
		bsr.w	DrawBGScrollBlock2
		if Revision>=1
		; REV01 added a third scroll block, though, technically,
		; the RAM for it was already there in REV00
		lea	(v_bg3_redraw_direction_copy).w,a2	; Scroll block 3 scroll flags
		lea	(v_bg3_x_pos_copy).w,a3			; Scroll block 3 X coordinate
		bsr.w	DrawBGScrollBlock3
		endc
		; Then, update the foreground
		lea	(v_fg_redraw_direction_copy).w,a2	; Foreground scroll flags
		lea	(v_camera_x_pos_copy).w,a3		; Foreground X coordinate
		lea	(v_level_layout).w,a4
		move.w	#$4000,d2				; VRAM thing for selecting Plane A
		; The FG's update function is inlined here
		tst.b	(a2)
		beq.s	locret_6952				; If there are no flags set, nothing needs updating
		bclr	#0,(a2)
		beq.s	loc_6908
		; Draw new tiles at the top
		moveq	#-16,d4					; Y coordinate. Note that 16 is the size of a block in pixels
		moveq	#-16,d5					; X coordinate
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4					; Y coordinate
		moveq	#-16,d5					; X coordinate
		bsr.w	DrawBlocks_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		; Draw new tiles at the bottom
		move.w	#224,d4					; Start at bottom of the screen. Since this draws from top to bottom, we don't need 224+16
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	DrawBlocks_TB

locret_6952:
		rts	
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6954:
DrawBGScrollBlock1:
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#redraw_top_bit,(a2)
		beq.s	loc_6972
		; Draw new tiles at the top
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		if Revision=0
			moveq	#(512/16)-1,d6			; Draw entire row of plane
			bsr.w	DrawBlocks_LR_2
		else
			bsr.w	DrawBlocks_LR
		endc

loc_6972:
		bclr	#redraw_bottom_bit,(a2)
		beq.s	loc_698E
		; Draw new tiles at the top
		move.w	#224,d4
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

loc_698E:
		bclr	#redraw_left_bit,(a2)

		if Revision=0
			beq.s	loc_69BE
								; Draw new tiles on the left
			moveq	#-16,d4
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			moveq	#-16,d4
			moveq	#-16,d5
			move.w	(v_scroll_block_1_height).w,d6
			move.w	4(a3),d1
			andi.w	#-16,d1				; Floor camera Y coordinate to the nearest block
			sub.w	d1,d6
			blt.s	loc_69BE			; If scroll block 1 is offscreen, skip loading its tiles
			lsr.w	#4,d6				; Get number of rows not above the screen
			cmpi.w	#((224+16+16)/16)-1,d6
			blo.s	loc_69BA
			moveq	#((224+16+16)/16)-1,d6		; Cap at height of screen

	loc_69BA:
			bsr.w	DrawBlocks_TB_2

	loc_69BE:
			bclr	#redraw_right_bit,(a2)
			beq.s	locret_69F2
								; Draw new tiles on the right
			moveq	#-16,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			moveq	#-16,d4
			move.w	#320,d5
			move.w	(v_scroll_block_1_height).w,d6
			move.w	4(a3),d1
			andi.w	#-16,d1
			sub.w	d1,d6
			blt.s	locret_69F2
			lsr.w	#4,d6
			cmpi.w	#((224+16+16)/16)-1,d6
			blo.s	loc_69EE
			moveq	#((224+16+16)/16)-1,d6

	loc_69EE:
			bsr.w	DrawBlocks_TB_2

		else

			beq.s	locj_6D56
								; Draw new tiles on the left
			moveq	#-16,d4
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			moveq	#-16,d4
			moveq	#-16,d5
			bsr.w	DrawBlocks_TB
	locj_6D56:

			bclr	#redraw_right_bit,(a2)
			beq.s	locj_6D70
								; Draw new tiles on the right
			moveq	#-16,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			moveq	#-16,d4
			move.w	#320,d5
			bsr.w	DrawBlocks_TB
	locj_6D70:

			bclr	#redraw_topall_bit,(a2)
			beq.s	locj_6D88
								; Draw entire row at the top
			moveq	#-16,d4
			moveq	#0,d5
			bsr.w	Calc_VRAM_Pos_2
			moveq	#-16,d4
			moveq	#0,d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_6D88:

			bclr	#redraw_bottomall_bit,(a2)
			beq.s	locret_69F2
								; Draw entire row at the bottom
			move.w	#224,d4
			moveq	#0,d5
			bsr.w	Calc_VRAM_Pos_2
			move.w	#224,d4
			moveq	#0,d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
		endc

locret_69F2:
		rts	
; End of function DrawBGScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Essentially, this draws everything that isn't scroll block 1
; sub_69F4:
DrawBGScrollBlock2:
		if Revision=0

		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#redraw_left_bit,(a2)
		beq.s	loc_6A3E
		; Draw new tiles on the left
		cmpi.w	#16,(a3)
		blo.s	loc_6A3E
		move.w	(v_scroll_block_1_height).w,d4
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4					; Get remaining coverage of screen that isn't scroll block 1
		move.w	d4,-(sp)
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		moveq	#-16,d5
		move.w	(v_scroll_block_1_height).w,d6
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d6
		blt.s	loc_6A3E				; If scroll block 1 is completely offscreen, branch?
		lsr.w	#4,d6
		subi.w	#((224+16)/16)-1,d6			; Get however many of the rows on screen are not scroll block 1
		bhs.s	loc_6A3E
		neg.w	d6
		bsr.w	DrawBlocks_TB_2

loc_6A3E:
		bclr	#redraw_right_bit,(a2)
		beq.s	locret_6A80
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
		blt.s	locret_6A80
		lsr.w	#4,d6
		subi.w	#((224+16)/16)-1,d6
		bhs.s	locret_6A80
		neg.w	d6
		bsr.w	DrawBlocks_TB_2

locret_6A80:
		rts	
; End of function DrawBGScrollBlock2

; ===========================================================================

; Abandoned unused scroll block code.
; This would have drawn a scroll block that started at 208 pixels down, and was 48 pixels long.
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

		else

			tst.b	(a2)
			beq.w	locj_6DF2
			cmpi.b	#id_SBZ,(v_zone).w
			beq.w	Draw_SBz
			bclr	#redraw_top_bit,(a2)
			beq.s	locj_6DD2
								; Draw new tiles on the left
			move.w	#224/2,d4			; Draw the bottom half of the screen
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			moveq	#-16,d5
			moveq	#3-1,d6				; Draw three rows... could this be a repurposed version of the above unused code?
			bsr.w	DrawBlocks_TB_2
	locj_6DD2:
			bclr	#redraw_bottom_bit,(a2)
			beq.s	locj_6DF2
								; Draw new tiles on the right
			move.w	#224/2,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			move.w	#320,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6DF2:
			rts
;===============================================================================
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
;===============================================================================


	; locj_6EA4:
	DrawBGScrollBlock3:
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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from left to right
; when the camera's moving up or down
; DrawTiles_LR:
DrawBlocks_LR:
		moveq	#((320+16+16)/16)-1,d6			; Draw the entire width of the screen + two extra columns
; DrawTiles_LR_2:
DrawBlocks_LR_2:
		move.l	#$800000,d7				; Delta between rows of tiles
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1					; Two tiles ahead
		andi.b	#$7F,d1					; Wrap around row
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5					; Move X coordinate one block ahead
		dbf	d6,@loop
		rts
; End of function DrawBlocks_LR

		if Revision>=1
; DrawTiles_LR_3:
DrawBlocks_LR_3:
		move.l	#$800000,d7
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData_2
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5
		dbf	d6,@loop
		rts	
; End of function DrawBlocks_LR_3
		endc


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from top to bottom
; when the camera's moving left or right
; DrawTiles_TB:
DrawBlocks_TB:
		moveq	#((224+16+16)/16)-1,d6			; Draw the entire height of the screen + two extra rows
; DrawTiles_TB_2:
DrawBlocks_TB_2:
		move.l	#$800000,d7				; Delta between rows of tiles
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addi.w	#$100,d1				; Two rows ahead
		andi.w	#$FFF,d1				; Wrap around plane
		movem.l	(sp)+,d4-d5
		addi.w	#16,d4					; Move X coordinate one block ahead
		dbf	d6,@loop
		rts	
; End of function DrawBlocks_TB_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Draws a block's worth of tiles
; Parameters:
; a0 = Pointer to block metadata (block index and X/Y flip)
; a1 = Pointer to block
; a5 = Pointer to VDP command port
; a6 = Pointer to VDP data port
; d0 = VRAM command to access plane
; d2 = VRAM plane A/B specifier
; d7 = Plane row delta
; DrawTiles:
DrawBlock:
		or.w	d2,d0					; OR in that plane A/B specifier to the VRAM command
		swap	d0
		btst	#4,(a0)					; Check Y-flip bit
		bne.s	DrawFlipY
		btst	#3,(a0)					; Check X-flip bit
		bne.s	DrawFlipX
		move.l	d0,(a5)
		move.l	(a1)+,(a6)				; Write top two tiles
		add.l	d7,d0					; Next row
		move.l	d0,(a5)
		move.l	(a1)+,(a6)				; Write bottom two tiles
		rts	
; ===========================================================================

DrawFlipX:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4				; Invert X-flip bits of each tile
		swap	d4					; Swap the tiles around
		move.l	d4,(a6)					; Write top two tiles
		add.l	d7,d0					; Next row
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)					; Write bottom two tiles
		rts	
; ===========================================================================

DrawFlipY:
		btst	#3,(a0)
		bne.s	DrawFlipXY
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts	
; ===========================================================================

DrawFlipXY:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts	
; End of function DrawBlocks

; ===========================================================================
; unused garbage
		if Revision=0
; This is interesting. It draws a block, but not before
; incrementing its palette lines by 1. This may have been
; a debug function to discolour mirrored tiles, to test
; if they're loading properly.
		rts	
		move.l	d0,(a5)
		move.w	#$2000,d5
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		rts
		endc

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Gets address of block at a certain coordinate
; Parameters:
; a4 = Pointer to level layout
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns:
; a0 = Address of block metadata
; a1 = Address of block
; DrawBlocks:
GetBlockData:
		if Revision=0
		lea	(v_16x16_tiles).w,a1
		add.w	4(a3),d4				; Add camera Y coordinate to relative coordinate
		add.w	(a3),d5					; Add camera X coordinate to relative coordinate
		else
			add.w	(a3),d5
	GetBlockData_2:
			add.w	4(a3),d4
			lea	(v_16x16_tiles).w,a1
		endc
		; Turn Y coordinate into index into level layout
		move.w	d4,d3
		lsr.w	#1,d3
		andi.w	#$380,d3
		; Turn X coordinate into index into level layout
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#5,d0
		andi.w	#$7F,d0
		; Get chunk from level layout
		add.w	d3,d0
		moveq	#-1,d3
		move.b	(a4,d0.w),d3
		beq.s	locret_6C1E				; If chunk 00, just return a pointer to the first block (expected to be empty)
		; Turn chunk ID into index into chunk table
		subq.b	#1,d3
		andi.w	#$7F,d3
		ror.w	#7,d3
		; Turn Y coordinate into index into chunk
		add.w	d4,d4
		andi.w	#$1E0,d4
		; Turn X coordinate into index into chunk
		andi.w	#$1E,d5
		; Get block metadata from chunk
		add.w	d4,d3
		add.w	d5,d3
		movea.l	d3,a0
		move.w	(a0),d3
		; Turn block ID into address
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts	
; End of function GetBlockData


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Produces a VRAM plane access command from coordinates
; Parameters:
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns VDP command in d0
Calc_VRAM_Pos:
		if Revision=0
		add.w	4(a3),d4				; Add camera Y coordinate
		add.w	(a3),d5					; Add camera X coordinate
		else
			add.w	(a3),d5
	Calc_VRAM_Pos_2:
			add.w	4(a3),d4
		endc
		; Floor the coordinates to the nearest pair of tiles (the size of a block).
		; Also note that this wraps the value to the size of the plane:
		; The plane is 64*8 wide, so wrap at $100, and it's 32*8 tall, so wrap at $200
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		; Transform the adjusted coordinates into a VDP command
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0					; Highest bits of plane VRAM address
		swap	d0
		move.w	d4,d0
		rts	
; End of function Calc_VRAM_Pos


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; not used

; This is just like Calc_VRAM_Pos, but seemingly for an earlier
; VRAM layout: the only difference is the high bits of the
; plane's VRAM address, which are 10 instead of 11.
; Both the foreground and background are at $C000 and $E000
; respectively, so this one starting at $8000 makes no sense.
; sub_6C3C:
Calc_VRAM_Pos_Unknown:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts	
; End of function Calc_VRAM_Pos_Unknown

; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_camera_x_pos).w,a3
		lea	(v_level_layout).w,a4
		move.w	#$4000,d2
		bsr.s	DrawChunks
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+level_max_width).w,a4
		move.w	#$6000,d2
		if Revision=0
		else
			tst.b	(v_zone).w
			beq.w	Draw_GHz_Bg
			cmpi.b	#id_MZ,(v_zone).w
			beq.w	Draw_Mz_Bg
			cmpi.w	#(id_SBZ<<8)+0,(v_zone).w
			beq.w	Draw_SBz_Bg
			cmpi.b	#id_EndZ,(v_zone).w
			beq.w	Draw_GHz_Bg
		endc
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawChunks:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6

	@loop:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf	d6,@loop
		rts	
; End of function DrawChunks

		if Revision>=1
	Draw_GHz_Bg:
			moveq	#0,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_7224:			
			movem.l	d4-d6,-(sp)
			lea	(locj_724a),a0
			move.w	(v_bg1_y_pos).w,d0
			add.w	d4,d0
			andi.w	#$F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_7224
			rts
	locj_724a:
			dc.b $00,$00,$00,$00,$06,$06,$06,$04,$04,$04,$00,$00,$00,$00,$00,$00
;-------------------------------------------------------------------------------
	Draw_Mz_Bg:;locj_725a:
			moveq	#-16,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_725E:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6EF2+1),a0
			move.w	(v_bg1_y_pos).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_725E
			rts
;-------------------------------------------------------------------------------
	Draw_SBz_Bg:;locj_7288:
			moveq	#-16,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_728C:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6DF4+1),a0
			move.w	(v_bg1_y_pos).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_728C
			rts
;-------------------------------------------------------------------------------
	locj_72B2:
			dc.w v_bg1_x_pos, v_bg1_x_pos, v_bg2_x_pos, v_bg3_x_pos
	locj_72Ba:
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			movea.w	locj_72B2(pc,d0.w),a3
			beq.s	locj_72da
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_72EE
	locj_72da:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_72EE:
			rts
		endc

		include "Includes\LevelDataLoad, LevelLayoutLoad & LevelHeaders.asm"
		include "Includes\DynamicLevelEvents.asm"

		include "Objects\GHZ Bridge.asm"		; Bridge

		include "Objects\_DetectPlatform.asm"
		include "Objects\_SlopeObject.asm"

		include "Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm" ; SwingingPlatform
		
		include_Bridge_2				; Objects\GHZ Bridge.asm

		include "Objects\_ExitPlatform.asm"

		include_Bridge_3				; Objects\GHZ Bridge.asm
		include "Mappings\GHZ Bridge.asm"		; Map_Bri

		include_SwingingPlatform_1			; Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm

		include "Objects\_MoveWithPlatform.asm"

		include_SwingingPlatform_2			; Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm

		include "Objects\GHZ Boss Ball.asm"		; BossBall
		include_BossBall_2

		include_SwingingPlatform_3			; Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm
		
		include "Mappings\GHZ & MZ Swinging Platforms.asm" ; Map_Swing_GHZ
		include "Mappings\SLZ Swinging Platforms.asm"	; Map_Swing_SLZ

		include "Objects\GHZ Spiked Helix Pole.asm"	; Helix
		include "Mappings\GHZ Spiked Helix Pole.asm"	; Map_Hel

		include "Objects\Platforms.asm"			; BasicPlatform
		include "Mappings\Unused Platforms.asm"		; Map_Plat_Unused
		include "Mappings\GHZ Platforms.asm"		; Map_Plat_GHZ
		include "Mappings\SYZ Platforms.asm"		; Map_Plat_SYZ
		include "Mappings\SLZ Platforms.asm"		; Map_Plat_SLZ

; ---------------------------------------------------------------------------
; Object 19 - blank
; ---------------------------------------------------------------------------

Obj19:
		rts	
		
		include "Mappings\GHZ Giant Ball.asm"		; Map_GBall

		include "Objects\GHZ Collapsing Ledge.asm"	; CollapseLedge
		include "Objects\MZ, SLZ & SBZ Collapsing Floors.asm" ; CollapseFloor
		include_CollapseLedge_2				; Objects\GHZ Collapsing Ledge.asm

; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
CFlo_Data1:	dc.b $1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b $16, $12, $E, $A, 6, 2, $14, $10, $C, 0
CFlo_Data2:	dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2
CFlo_Data3:	dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2

		include_SlopeObject_NoChk			; Objects\_SlopeObject.asm

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Ledge_SlopeData:
		incbin	"Misc Data\GHZ Collapsing Ledge Heightmap.bin"
		even

		include "Mappings\GHZ Collapsing Ledge.asm"	; Map_Ledge
		include "Mappings\MZ, SLZ & SBZ Collapsing Floors.asm" ; Map_CFlo

		include "Objects\GHZ Bridge Stump & SLZ Fireball Launcher.asm" ; Scenery
		include "Mappings\SLZ Fireball Launcher.asm"	; Map_Scen

		include "Objects\Unused Switch.asm"		; MagicSwitch
		include "Mappings\Unused Switch.asm"		; Map_Switch

		include "Objects\SBZ Door.asm"			; AutoDoor
		include "Animations\SBZ Door.asm"		; Ani_ADoor
		include "Mappings\SBZ Door.asm"			; Map_ADoor

		include "Objects\GHZ Walls.asm"			; EdgeWalls
		include_EdgeWalls_2

		include "Objects\Ball Hog.asm"			; BallHog
		include "Objects\Ball Hog Cannonball.asm"	; Cannonball

		include "Objects\Buzz Bomber Missile Vanishing.asm" ; MissileDissolve

		include "Objects\Explosions.asm"		; ExplosionItem & ExplosionBomb
		include "Animations\Ball Hog.asm"		; Ani_Hog
		include "Mappings\Ball Hog.asm"			; Map_Hog
		include "Mappings\Buzz Bomber Missile Vanishing.asm" ; Map_MisDissolve
		include "Mappings\Explosions.asm"		; Map_ExplodeItem & Map_ExplodeBomb

		include "Objects\Animals.asm"			; Animals
		include "Objects\Points.asm"			; Points
		include "Mappings\Animals.asm"			; Map_Animal1, Map_Animal2 & Map_Animal3
		include "Mappings\Points.asm"			; Map_Points

		include "Objects\Crabmeat.asm"			; Crabmeat
		include "Animations\Crabmeat.asm"		; Ani_Crab
		include "Mappings\Crabmeat.asm"			; Map_Crab

		include "Objects\Buzz Bomber.asm"		; BuzzBomber
		include "Objects\Buzz Bomber Missile.asm"	; Missile
		include "Animations\Buzz Bomber.asm"		; Ani_Buzz
		include "Animations\Buzz Bomber Missile.asm"	; Ani_Missile
		include "Mappings\Buzz Bomber.asm"		; Map_Buzz
		include "Mappings\Buzz Bomber Missile.asm"	; Map_Missile

		include "Objects\Rings.asm"			; Rings
		include "Objects\_CollectRing.asm"
		include "Objects\Ring Loss.asm"			; RingLoss
		include "Objects\Giant Ring.asm"		; GiantRing
		include "Objects\Giant Ring Flash.asm"		; RingFlash
		include "Animations\Ring.asm"			; Ani_Ring
		include "Mappings\Ring.asm"			; Map_Ring
		include "Mappings\Giant Ring.asm"		; Map_GRing
		include "Mappings\Giant Ring Flash.asm"		; Map_Flash

		include "Objects\Monitors.asm"			; Monitor
		include "Objects\Monitor Contents.asm"		; PowerUp
		include_Monitor_2				; Objects\Monitors.asm

		include "Animations\Monitors.asm"		; Ani_Monitor
		include "Mappings\Monitors.asm"			; Map_Monitor

		include "Objects\Title Screen Sonic.asm"	; TitleSonic
		include "Objects\Title Screen Press Start & TM.asm" ; PSBTM

		include "Animations\Title Screen Sonic.asm"	; Ani_TSon
		include "Animations\Title Screen Press Start.asm" ; Ani_PSB

		include "Objects\_AnimateSprite.asm"

		include "Mappings\Title Screen Press Start & TM.asm" ; Map_PSB
		include "Mappings\Title Screen Sonic.asm"	; Map_TSon

		include "Objects\Chopper.asm"			; Chopper
		include "Animations\Chopper.asm"		; Ani_Chop
		include "Mappings\Chopper.asm"			; Map_Chop

		include "Objects\Jaws.asm"			; Jaws
		include "Animations\Jaws.asm"			; Ani_Jaws
		include "Mappings\Jaws.asm"			; Map_Jaws

		include "Objects\Burrobot.asm"			; Burrobot
		include "Animations\Burrobot.asm"		; Ani_Burro
		include "Mappings\Burrobot.asm"			; Map_Burro

		include "Objects\MZ Grass Platforms.asm"	; LargeGrass
		include "Objects\MZ Burning Grass.asm"		; GrassFire
		include "Animations\MZ Burning Grass.asm"	; Ani_GFire
		include "Mappings\MZ Grass Platforms.asm"	; Map_LGrass
		include "Mappings\Fireballs.asm"		; Map_Fire

		include "Objects\MZ Green Glass Blocks.asm"	; GlassBlock
		include "Mappings\MZ Green Glass Blocks.asm"	; Map_Glass

		include "Objects\MZ Chain Stompers.asm"		; ChainStomp
		include "Objects\MZ Unused Sideways Stomper.asm" ; SideStomp
		include "Mappings\MZ Chain Stompers.asm"	; Map_CStom
		include "Mappings\MZ Unused Sideways Stomper.asm" ; Map_SStom

		include "Objects\Button.asm"			; Button
		include "Mappings\Button.asm"			; Map_But

		include "Objects\MZ & LZ Pushable Blocks.asm"	; PushBlock
		include "Mappings\MZ & LZ Pushable Blocks.asm"	; Map_Push

		include "Objects\Title Cards.asm"		; TitleCard
		include "Objects\Game Over & Time Over.asm"	; GameOverCard
		include "Objects\Sonic Has Passed Title Card.asm" ; HasPassedCard

		include "Objects\Special Stage Results.asm"	; SSResult
		include "Objects\Special Stage Results Chaos Emeralds.asm" ; SSRChaos
		include "Mappings\Title Cards.asm"		; Map_Card
		include "Mappings\Game Over & Time Over.asm"	; Map_Over
		include "Mappings\Title Cards Sonic Has Passed.asm" ; Map_Has
		include "Mappings\Special Stage Results.asm"	; Map_SSR
		include "Mappings\Special Stage Results Chaos Emeralds.asm" ; Map_SSRC

		include "Objects\Spikes.asm"			; Spikes
		include "Mappings\Spikes.asm"			; Map_Spike

		include "Objects\GHZ Purple Rock.asm"		; PurpleRock
		include "Objects\GHZ Waterfall Sound.asm"	; WaterSound
		include "Mappings\GHZ Purple Rock.asm"		; Map_PRock

		include "Objects\GHZ & SLZ Smashable Walls & SmashObject.asm" ; SmashWall
		include "Mappings\GHZ & SLZ Smashable Walls.asm" ; Map_Smash

		include "Includes\ExecuteObjects & Object Pointers.asm"

NullObject:
		;jmp	(DeleteObject).l ; It would be safer to have this instruction here, but instead it just falls through to ObjectFall

		include "Objects\_ObjectFall & SpeedToPos.asm"

		include "Objects\_DisplaySprite.asm"
		include "Objects\_DeleteObject & DeleteChild.asm"

		include "Includes\BuildSprites.asm"

		include "Objects\_CheckOffScreen.asm"

		include "Includes\ObjPosLoad.asm"
		include "Objects\_FindFreeObj & FindNextFreeObj.asm"

		include "Objects\Springs.asm"			; Springs
		include "Animations\Springs.asm"		; Ani_Spring
		include "Mappings\Springs.asm"			; Map_Spring

		include "Objects\Newtron.asm"			; Newtron
		include "Animations\Newtron.asm"		; Ani_Newt
		include "Mappings\Newtron.asm"			; Map_Newt

		include "Objects\Roller.asm"			; Roller
		include "Animations\Roller.asm"			; Ani_Roll
		include "Mappings\Roller.asm"			; Map_Roll

		include_EdgeWalls_1				; Objects\GHZ Walls.asm
		include "Mappings\GHZ Walls.asm"		; Map_Edge

		include "Objects\MZ & SLZ Fireball Launchers.asm"
		include "Objects\Fireballs.asm"			; LavaBall
		include "Animations\Fireballs.asm"		; Ani_Fire

		include "Objects\SBZ Flamethrower.asm"		; Flamethrower
		include "Animations\SBZ Flamethrower.asm"	; Ani_Flame
		include "Mappings\SBZ Flamethrower.asm"		; Map_Flame

		include "Objects\MZ Purple Brick Block.asm"	; MarbleBrick
		include "Mappings\MZ Purple Brick Block.asm"	; Map_Brick

		include "Objects\SYZ Lamp.asm"			; SpinningLight
		include "Mappings\SYZ Lamp.asm"			; Map_Light

		include "Objects\SYZ Bumper.asm"		; Bumper
		include "Animations\SYZ Bumper.asm"		; Ani_Bump
		include "Mappings\SYZ Bumper.asm"		; Map_Bump

		include "Objects\Signpost & GotThroughAct.asm"	; Signpost & GotThroughAct
		include "Animations\Signpost.asm"		; Ani_Sign
		include "Mappings\Signpost.asm"			; Map_Sign

		include "Objects\MZ Lava Geyser Maker.asm"	; GeyserMaker
		include "Objects\MZ Lava Geyser.asm"		; LavaGeyser
		include "Objects\MZ Lava Wall.asm"		; LavaWall
		include "Objects\MZ Invisible Lava Tag.asm"	; LavaTag
		include "Mappings\MZ Invisible Lava Tag.asm"	; Map_LTag
		include "Animations\MZ Lava Geyser.asm"		; Ani_Geyser
		include "Animations\MZ Lava Wall.asm"		; Ani_LWall
		include "Mappings\MZ Lava Geyser.asm"		; Map_Geyser
		include "Mappings\MZ Lava Wall.asm"		; Map_LWall

		include "Objects\Moto Bug & RememberState.asm"	; MotoBug
		include "Animations\Moto Bug.asm"		; Ani_Moto
		include "Mappings\Moto Bug.asm"			; Map_Moto

; ---------------------------------------------------------------------------
; Object 4F - blank
; ---------------------------------------------------------------------------

Obj4F:
		rts	

		include "Objects\Yadrin.asm"			;Yadrin
		include "Animations\Yadrin.asm"			; Ani_Yad
		include "Mappings\Yadrin.asm"			; Map_Yad

		include "Objects\_SolidObject.asm"

		include "Objects\MZ Smashable Green Block.asm"	; SmashBlock
		include "Mappings\MZ Smashable Green Block.asm"	; Map_Smab

		include "Objects\MZ, LZ & SBZ Moving Blocks.asm" ; MovingBlock
		include "Mappings\MZ & SBZ Moving Blocks.asm"	; Map_MBlock
		include "Mappings\LZ Moving Block.asm"		; Map_MBlockLZ

		include "Objects\Batbrain.asm"			; Batbrain
		include "Animations\Batbrain.asm"		; Ani_Bat
		include "Mappings\Batbrain.asm"			; Map_Bat

		include "Objects\SYZ & SLZ Floating Blocks, LZ Doors.asm" ; FloatingBlock
		include "Mappings\SYZ & SLZ Floating Blocks, LZ Doors.asm" ; Map_FBlock

		include "Objects\SYZ & LZ Spike Ball Chain.asm"	; SpikeBall
		include "Mappings\SYZ Spike Ball Chain.asm"	; Map_SBall
		include "Mappings\LZ Spike Ball on Chain.asm"	; Map_SBall2

		include "Objects\SYZ Large Spike Balls.asm"	; BigSpikeBall
		include "Mappings\SYZ & SBZ Large Spike Balls.asm" ; Map_BBall

		include "Objects\SLZ Elevator.asm"		; Elevator
		include "Mappings\SLZ Elevator.asm"		; Map_Elev

		include "Objects\SLZ Circling Platform.asm"	; CirclingPlatform
		include "Mappings\SLZ Circling Platform.asm"	; Map_Circ

		include "Objects\SLZ Stairs.asm"		; Staircase
		include "Mappings\SLZ Stairs.asm"		; Map_Stair

		include "Objects\SLZ Pylon.asm"			; Pylon
		include "Mappings\SLZ Pylon.asm"		; Map_Pylon

		include "Objects\LZ Water Surface.asm"		; WaterSurface
		include "Mappings\LZ Water Surface.asm"		; Map_Surf

		include "Objects\LZ Pole.asm"			; Pole
		include "Mappings\LZ Pole.asm"			; Map_Pole

		include "Objects\LZ Flapping Door.asm"		; FlapDoor
		include "Animations\LZ Flapping Door.asm"	; Ani_Flap
		include "Mappings\LZ Flapping Door.asm"		; Map_Flap

		include "Objects\Invisible Solid Blocks.asm"	; Invisibarrier
		include "Mappings\Invisible Solid Blocks.asm"	; Map_Invis

		include "Objects\SLZ Fans.asm"			; Fan
		include "Mappings\SLZ Fans.asm"			; Map_Fan

		include "Objects\SLZ Seesaw.asm"		; Seesaw
		include "Mappings\SLZ Seesaw.asm"		; Map_Seesaw
		include "Mappings\SLZ Seesaw Spike Ball.asm"	; Map_SSawBall

		include "Objects\Bomb Enemy.asm"		; Bomb
		include "Animations\Bomb Enemy.asm"		; Ani_Bomb
		include "Mappings\Bomb Enemy.asm"		; Map_Bomb

		include "Objects\Orbinaut.asm"			; Orbinaut
		include "Animations\Orbinaut.asm"		; Ani_Orb
		include "Mappings\Orbinaut.asm"			; Map_Orb

		include "Objects\LZ Harpoon.asm"		; Harpoon
		include "Animations\LZ Harpoon.asm"		; Ani_Harp
		include "Mappings\LZ Harpoon.asm"		; Map_Harp

		include "Objects\LZ Blocks.asm"			; LabyrinthBlock
		include "Mappings\LZ Blocks.asm"		; Map_LBlock

		include "Objects\LZ Gargoyle Head.asm"		; Gargoyle
		include "Mappings\LZ Gargoyle Head.asm"		; Map_Gar

		include "Objects\LZ Conveyor Belt Platforms.asm" ; LabyrinthConvey
		include "Mappings\LZ Conveyor Belt Platforms.asm" ; Map_LConv

		include "Objects\LZ Bubbles.asm"		; Bubble
		include "Animations\LZ Bubbles.asm"		; Ani_Bub
		include "Mappings\LZ Bubbles.asm"		; Map_Bub

		include "Objects\LZ Waterfall.asm"		; Waterfall
		include "Animations\LZ Waterfall.asm"		; Ani_WFall
		include "Mappings\LZ Waterfall.asm"		; Map_WFall

		include "Objects\Sonic.asm"			; SonicPlayer

		include "Objects\LZ Drowning Numbers.asm"	; DrownCount
		include "Objects\_ResumeMusic.asm"

		include "Animations\LZ Drowning Numbers.asm"	; Ani_Drown
		include "Mappings\LZ Drowning Numbers.asm"	; Map_Drown

		include "Objects\Shield & Invincibility.asm"	; ShieldItem
		include "Objects\Unused Special Stage Warp.asm"	; VanishSonic
		include "Objects\LZ Water Splash.asm"		; Splash
		include "Animations\Shield & Invincibility.asm"	; Ani_Shield
		include "Mappings\Shield & Invincibility.asm"	; Map_Shield
		include "Animations\Unused Special Stage Warp.asm" ; Ani_Vanish
		include "Mappings\Unused Special Stage Warp.asm" ; Map_Vanish
		include "Animations\LZ Water Splash.asm"	; Ani_Splash
		include "Mappings\LZ Water Splash.asm"		; Map_Splash

		include_Sonic_2					; Objects\Sonic.asm
		include "Objects\_FindNearestTile, FindFloor & FindWall.asm"

		include	"Includes\ConvertCollisionArray.asm"

		include_Sonic_3					; Objects\Sonic.asm
		include "Objects\_FindFloorObj, FindWallRightObj, FindCeilingObj & FindWallLeftObj.asm"
		include_Sonic_4					; Objects\Sonic.asm
		include_FindWallRightObj			; Objects\_FindFloorObj, FindWallRightObj, FindCeilingObj & FindWallLeftObj.asm
		include_Sonic_5					; Objects\Sonic.asm
		include_FindCeilingObj				; Objects\_FindFloorObj, FindWallRightObj, FindCeilingObj & FindWallLeftObj.asm
		include_Sonic_6					; Objects\Sonic.asm
		include_FindWallLeftObj				; Objects\_FindFloorObj, FindWallRightObj, FindCeilingObj & FindWallLeftObj.asm

		include "Objects\SBZ Rotating Disc Junction.asm" ; Junction
		include "Mappings\SBZ Rotating Disc Junction.asm" ; Map_Jun

		include "Objects\SBZ Running Disc.asm"		; RunningDisc
		include "Mappings\SBZ Running Disc.asm"		; Map_Disc

		include "Objects\SBZ Conveyor Belt.asm"		; Conveyor
		include "Objects\SBZ Trapdoor & Spinning Platforms.asm" ; SpinPlatform
		include "Animations\SBZ Trapdoor & Spinning Platforms.asm" ; Ani_Spin
		include "Mappings\SBZ Trapdoor.asm"		; Map_Trap
		include "Mappings\SBZ Spinning Platforms.asm"	; Map_Spin

		include "Objects\SBZ Saws.asm"			; Saws
		include "Mappings\SBZ Saws.asm"			; Map_Saw

		include "Objects\SBZ Stomper & Sliding Doors.asm" ; ScrapStomp
		include "Mappings\SBZ Stomper & Sliding Doors.asm" ; Map_Stomp

		include "Objects\SBZ Vanishing Platform.asm"	; VanishPlatform
		include "Animations\SBZ Vanishing Platform.asm"	; Ani_Van
		include "Mappings\SBZ Vanishing Platform.asm"	; Map_VanP

		include "Objects\SBZ Electric Orb.asm"		; Electro
		include "Animations\SBZ Electric Orb.asm"	; Ani_Elec
		include "Mappings\SBZ Electric Orb.asm"		; Map_Elec

		include "Objects\SBZ Conveyor Belt Platforms.asm" ; SpinConvey
		include "Animations\SBZ Conveyor Belt Platforms.asm" ; Ani_SpinConvey

SpinC_Data:	index *
		ptr word_164B2
		ptr word_164C6
		ptr word_164DA
		ptr word_164EE
		ptr word_16502
		ptr word_16516
word_164B2:	dc.w $10, $E80
		dc.w $E14, $370
		dc.w $EEF, $302
		dc.w $EEF, $340
		dc.w $E14, $3AE
word_164C6:	dc.w $10, $F80
		dc.w $F14, $2E0
		dc.w $FEF, $272
		dc.w $FEF, $2B0
		dc.w $F14, $31E
word_164DA:	dc.w $10, $1080
		dc.w $1014, $270
		dc.w $10EF, $202
		dc.w $10EF, $240
		dc.w $1014, $2AE
word_164EE:	dc.w $10, $F80
		dc.w $F14, $570
		dc.w $FEF, $502
		dc.w $FEF, $540
		dc.w $F14, $5AE
word_16502:	dc.w $10, $1B80
		dc.w $1B14, $670
		dc.w $1BEF, $602
		dc.w $1BEF, $640
		dc.w $1B14, $6AE
word_16516:	dc.w $10, $1C80
		dc.w $1C14, $5E0
		dc.w $1CEF, $572
		dc.w $1CEF, $5B0
		dc.w $1C14, $61E
; ===========================================================================

		include "Objects\SBZ Girder Block.asm"		; Girder
		include "Mappings\SBZ Girder Block.asm"		; Map_Gird

		include "Objects\SBZ Teleporter.asm"		; Teleport

		include "Objects\Caterkiller.asm"		; Caterkiller
		include "Animations\Caterkiller.asm"		; Ani_Cat
		include "Mappings\Caterkiller.asm"		; Map_Cat

		include "Objects\Lamppost.asm"			; Lamppost
		include "Mappings\Lamppost.asm"			; Map_Lamp

		include "Objects\Hidden Bonus Points.asm"	; HiddenBonus
		include "Mappings\Hidden Bonus Points.asm"	; Map_Bonus

		include "Objects\Credits & Sonic Team Presents.asm" ; CreditsText
		include "Mappings\Credits & Sonic Team Presents.asm" ; Map_Cred

		include "Objects\GHZ Boss, BossDefeated & BossMove.asm" ; BossGreenHill
		include_BossBall_1				; Objects\GHZ Boss Ball.asm; BossBall
		include "Animations\Bosses.asm"			; Ani_Eggman
		include "Mappings\Bosses.asm"			; Map_Eggman
		include "Mappings\Boss Extras.asm"		; Map_BossItems

		include "Objects\LZ Boss.asm"			; BossLabyrinth
		include "Objects\MZ Boss.asm"			; BossMarble
		include "Objects\MZ Boss Fire.asm"		; BossFire
		include "Objects\SLZ Boss.asm"			; BossStarLight
		include "Objects\SLZ Boss Spikeballs.asm"	; BossSpikeball
		include "Mappings\SLZ Boss Spikeballs.asm"	; Map_BSBall
		include "Objects\SYZ Boss.asm"			; BossSpringYard
		include "Objects\SYZ Blocks at Boss.asm"	; BossBlock
		include "Mappings\SYZ Blocks at Boss.asm"	; Map_BossBlock

		include "Objects\SBZ2 Blocks That Eggman Breaks.asm" ; FalseFloor
		include "Objects\SBZ2 Eggman.asm"		; ScrapEggman
		include "Animations\SBZ2 Eggman.asm"		; Ani_SEgg
		include "Mappings\SBZ2 Eggman.asm"		; Map_SEgg
		include_FalseFloor_1				; Objects\SBZ2 Blocks That Eggman Breaks.asm
		include "Mappings\SBZ2 Blocks That Eggman Breaks.asm" ; Map_FFloor

		include "Objects\FZ Boss.asm"			; BossFinal
		include "Animations\FZ Eggman.asm"		; Ani_FZEgg
		include "Mappings\FZ Eggman in Damaged Ship.asm" ; Map_FZDamaged
		include "Mappings\FZ Eggman Ship Legs.asm"	; Map_FZLegs

		include "Objects\FZ Cylinders.asm"		; EggmanCylinder
		include "Mappings\FZ Cylinders.asm"		; Map_EggCyl

		include "Objects\FZ Plasma Balls.asm"		; BossPlasma
		include "Animations\FZ Plasma Launcher.asm"	; Ani_PLaunch
		include "Mappings\FZ Plasma Launcher.asm"	; Map_PLaunch
		include "Animations\FZ Plasma Balls.asm"	; Ani_Plasma
		include "Mappings\FZ Plasma Balls.asm"		; Map_Plasma

		include "Objects\Prison Capsule.asm"		; Prison
		include "Animations\Prison Capsule.asm"		; Ani_Pri
		include "Mappings\Prison Capsule.asm"		; Map_Pri

		include "Objects\_ReactToItem, HurtSonic & KillSonic.asm"

		include_Special_3				; Includes\GM_Special.asm

; ---------------------------------------------------------------------------
; Special stage start locations
; ---------------------------------------------------------------------------
SS_StartLoc:

		incbin	"startpos\ss1.bin"
		incbin	"startpos\ss2.bin"
		incbin	"startpos\ss3.bin"
		incbin	"startpos\ss4.bin"
		incbin	"startpos\ss5.bin"
		incbin	"startpos\ss6.bin"
		even

		include_Special_4				; Includes\GM_Special.asm

; ---------------------------------------------------------------------------
; Special stage	mappings and VRAM pointers
; ---------------------------------------------------------------------------

ss_sprite:	macro *,map,tile,frame
		if strlen("\*")>0
		\*: equ *
		id_\*: equ ((*-SS_ItemIndex)/6)+1
		endc
		dc.l map+(frame*$1000000)
		dc.w tile
		endm
		
SS_ItemIndex:
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0	; 1
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal2,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal3,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
		ss_sprite Map_SSWalls,tile_Nem_SSWalls+tile_pal4,0
	SS_ItemIndex_wall_end:
SS_Item_Bumper:	ss_sprite Map_Bump,tile_Nem_Bumper_SS,0		; $25 - bumper
		ss_sprite Map_SS_R,tile_Nem_SSWBlock,0		; $26 - W
SS_Item_GOAL:	ss_sprite Map_SS_R,tile_Nem_SSGOAL,0		; $27 - GOAL
SS_Item_1Up:	ss_sprite Map_SS_R,tile_Nem_SS1UpBlock,0	; $28 - 1UP
SS_Item_Up:	ss_sprite Map_SS_Up,tile_Nem_SSUpDown,0		; $29 - Up
SS_Item_Down:	ss_sprite Map_SS_Down,tile_Nem_SSUpDown,0	; $2A - Down
SS_Item_R:	ss_sprite Map_SS_R,tile_Nem_SSRBlock+tile_pal2,0 ; $2B - R
SS_Item_RedWhi:	ss_sprite Map_SS_Glass,tile_Nem_SSRedWhite,0 ; $2C - red/white
SS_Item_Glass1:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass,0	; $2D - breakable glass gem
SS_Item_Glass2:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal4,0
SS_Item_Glass3:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal2,0
SS_Item_Glass4:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal3,0
SS_Item_R2:	ss_sprite Map_SS_R,tile_Nem_SSRBlock,0		; $31 - R
SS_Item_Bump1:	ss_sprite Map_Bump,tile_Nem_Bumper_SS,id_frame_bump_bumped1
SS_Item_Bump2:	ss_sprite Map_Bump,tile_Nem_Bumper_SS,id_frame_bump_bumped2
		ss_sprite Map_SS_R,tile_Nem_SSZone1,0		; ??34 - Zone 1
		ss_sprite Map_SS_R,tile_Nem_SSZone2,0		; ??35 - Zone 2
		ss_sprite Map_SS_R,tile_Nem_SSZone3,0		; ??36 - Zone 3
		ss_sprite Map_SS_R,tile_Nem_SSZone1,0		; ??37 - Zone 4
		ss_sprite Map_SS_R,tile_Nem_SSZone2,0		; ??38 - Zone 5
		ss_sprite Map_SS_R,tile_Nem_SSZone3,0		; ??39 - Zone 6
SS_Item_Ring:	ss_sprite Map_Ring,tile_Nem_Ring+tile_pal2,0	; $3A - ring
SS_Item_Em1:	ss_sprite Map_SS_Chaos3,tile_Nem_SSEmerald,0	; $3B - emerald
SS_Item_Em2:	ss_sprite Map_SS_Chaos3,tile_Nem_SSEmerald+tile_pal2,0 ; $3C - emerald
SS_Item_Em3:	ss_sprite Map_SS_Chaos3,tile_Nem_SSEmerald+tile_pal3,0 ; $3D - emerald
SS_Item_Em4:	ss_sprite Map_SS_Chaos3,tile_Nem_SSEmerald+tile_pal4,0 ; $3E - emerald
SS_Item_Em5:	ss_sprite Map_SS_Chaos1,tile_Nem_SSEmerald,0	; $3F - emerald
SS_Item_Em6:	ss_sprite Map_SS_Chaos2,tile_Nem_SSEmerald,0	; $40 - emerald
SS_Item_Ghost:	ss_sprite Map_SS_R,tile_Nem_SSGhost,0		; $41 - ghost block
SS_Item_Spark1:	ss_sprite Map_Ring,tile_Nem_Ring+tile_pal2,id_frame_ring_sparkle1 ; $42 - sparkle
SS_Item_Spark2:	ss_sprite Map_Ring,tile_Nem_Ring+tile_pal2,id_frame_ring_sparkle2 ; $43 - sparkle
SS_Item_Spark3:	ss_sprite Map_Ring,tile_Nem_Ring+tile_pal2,id_frame_ring_sparkle3 ; $44 - sparkle
SS_Item_Spark4:	ss_sprite Map_Ring,tile_Nem_Ring+tile_pal2,id_frame_ring_sparkle4 ; $45 - sparkle
SS_Item_EmSp1:	ss_sprite Map_SS_Glass,tile_Nem_SSEmStars+tile_pal2,0 ; $46 - emerald sparkle
SS_Item_EmSp2:	ss_sprite Map_SS_Glass,tile_Nem_SSEmStars+tile_pal2,1 ; $47 - emerald sparkle
SS_Item_EmSp3:	ss_sprite Map_SS_Glass,tile_Nem_SSEmStars+tile_pal2,2 ; $48 - emerald sparkle
SS_Item_EmSp4:	ss_sprite Map_SS_Glass,tile_Nem_SSEmStars+tile_pal2,3 ; $49 - emerald sparkle
SS_Item_Ghost2:	ss_sprite Map_SS_R,tile_Nem_SSGhost,2
SS_Item_Glass5:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass,0	; $4B
SS_Item_Glass6:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal4,0 ; $4C
SS_Item_Glass7:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal2,0 ; $4D
SS_Item_Glass8:	ss_sprite Map_SS_Glass,tile_Nem_SSGlass+tile_pal3,0 ; $4E
	SS_ItemIndex_end:

		include "Mappings\Special Stage R.asm"		; Map_SS_R
		include "Mappings\Special Stage Breakable & Red-White Blocks.asm" ; Map_SS_Glass
		include "Mappings\Special Stage Up.asm"		; Map_SS_Up
		include "Mappings\Special Stage Down.asm"	; Map_SS_Down
		include "Mappings\Special Stage Chaos Emeralds.asm" ; Map_SS_Chaos1, Map_SS_Chaos2 & Map_SS_Chaos3

		include "Objects\Special Stage Sonic.asm"	; SonicSpecial
; ---------------------------------------------------------------------------
; Object 10 - blank
; ---------------------------------------------------------------------------

Obj10:
		rts	

		include "Includes\AnimateLevelGfx.asm"

		include "Objects\HUD.asm"			; HUD
		include "Mappings\HUD Score, Time & Rings.asm"	; Map_HUD

		include "Objects\_AddPoints.asm"

		include "Includes\HUD_Update, HUD_Base & ContScrCounter.asm"

Art_Hud:	incbin	"Graphics\HUD Numbers.bin"		; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	"Graphics\Lives Counter Numbers.bin"	; 8x8 pixel numbers on lives counter
		even

		include "Objects\_DebugMode.asm"

		include_levelheaders				; Includes\LevelDataLoad, LevelLayoutLoad & LevelHeaders.asm
		include "Pattern Load Cues.asm"

		align	$200,$FF
		if Revision=0
			nemfile	Nem_SegaLogo
	Eni_SegaLogo:	incbin	"tilemaps\Sega Logo.bin"	; large Sega logo (mappings)
			even
		else
			dcb.b	$300,$FF
			nemfile	Nem_SegaLogo
	Eni_SegaLogo:	incbin	"tilemaps\Sega Logo (JP1).bin"	; large Sega logo (mappings)
			even
		endc
Eni_Title:	incbin	"tilemaps\Title Screen.bin"		; title screen foreground (mappings)
		even
		nemfile	Nem_TitleFg
		nemfile	Nem_TitleSonic
		nemfile	Nem_TitleTM
Eni_JapNames:	incbin	"tilemaps\Hidden Japanese Credits.bin"	; Japanese credits (mappings)
		even
		nemfile	Nem_JapNames

		include "Mappings\Sonic.asm"			; Map_Sonic
		include "Mappings\Sonic DPLCs.asm"		; SonicDynPLC

; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
Art_Sonic:	incbin	"Graphics\Sonic.bin"			; Sonic
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		if Revision=0
			nemfile	Nem_Smoke
			nemfile	Nem_SyzSparkle
		endc
		nemfile	Nem_Shield
		nemfile	Nem_Stars
		if Revision=0
			nemfile	Nem_LzSonic
			nemfile	Nem_UnkFire
			nemfile	Nem_Warp
			nemfile	Nem_Goggle
		endc

		include "Mappings\Special Stage Walls.asm"	; Map_SSWalls

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
		nemfile	Nem_SSWalls
Eni_SSBg1:	incbin	"tilemaps\SS Background 1.bin"		; special stage background (mappings)
		even
		nemfile	Nem_SSBgFish
Eni_SSBg2:	incbin	"tilemaps\SS Background 2.bin"		; special stage background (mappings)
		even
		nemfile	Nem_SSBgCloud
		nemfile	Nem_SSGOAL
		nemfile	Nem_SSRBlock
		nemfile	Nem_SS1UpBlock
		nemfile	Nem_SSEmStars
		nemfile	Nem_SSRedWhite
		nemfile	Nem_SSZone1
		nemfile	Nem_SSZone2
		nemfile	Nem_SSZone3
		nemfile	Nem_SSZone4
		nemfile	Nem_SSZone5
		nemfile	Nem_SSZone6
		nemfile	Nem_SSUpDown
		nemfile	Nem_SSEmerald
		nemfile	Nem_SSGhost
		nemfile	Nem_SSWBlock
		nemfile	Nem_SSGlass
		nemfile	Nem_ResultEm
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_Stalk
		nemfile	Nem_Swing
		nemfile	Nem_Bridge
		nemfile	Nem_GhzUnkBlock
		nemfile	Nem_Ball
		nemfile	Nem_Spikes
		nemfile	Nem_GhzLog
		nemfile	Nem_SpikePole
		nemfile	Nem_PplRock
		nemfile	Nem_GhzWall1
		nemfile	Nem_GhzWall2
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_Water
		nemfile	Nem_Splash
		nemfile	Nem_LzSpikeBall
		nemfile	Nem_FlapDoor
		nemfile	Nem_Bubbles
		nemfile	Nem_LzBlock3
		nemfile	Nem_LzDoor1
		nemfile	Nem_Harpoon
		nemfile	Nem_LzPole
		nemfile	Nem_LzDoor2
		nemfile	Nem_LzWheel
		nemfile	Nem_Gargoyle
		nemfile	Nem_LzBlock2
		nemfile	Nem_LzPlatfm
		nemfile	Nem_Cork
		nemfile	Nem_LzBlock1
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_MzMetal
		nemfile	Nem_MzSwitch
		nemfile	Nem_MzGlass
		nemfile	Nem_UnkGrass
		nemfile	Nem_Fireball
		nemfile	Nem_Lava
		nemfile	Nem_MzBlock
		nemfile	Nem_MzUnkBlock
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_Seesaw
		nemfile	Nem_SlzSpike
		nemfile	Nem_Fan
		nemfile	Nem_SlzWall
		nemfile	Nem_Pylon
		nemfile	Nem_SlzSwing
		nemfile	Nem_SlzBlock
		nemfile	Nem_SlzCannon
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_Bumper
		nemfile	Nem_SmallSpike
		nemfile	Nem_LzSwitch
		nemfile	Nem_BigSpike
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
		nemfile	Nem_SbzWheel1
		nemfile	Nem_SbzWheel2
		nemfile	Nem_Cutter
		nemfile	Nem_Stomper
		nemfile	Nem_SpinPform
		nemfile	Nem_TrapDoor
		nemfile	Nem_SbzFloor
		nemfile	Nem_Electric
		nemfile	Nem_SbzBlock
		nemfile	Nem_FlamePipe
		nemfile	Nem_SbzDoor1
		nemfile	Nem_SlideFloor
		nemfile	Nem_SbzDoor2
		nemfile	Nem_Girder
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
		nemfile	Nem_BallHog
		nemfile	Nem_Crabmeat
		nemfile	Nem_Buzz
		nemfile	Nem_UnkExplode
		nemfile	Nem_Burrobot
		nemfile	Nem_Chopper
		nemfile	Nem_Jaws
		nemfile	Nem_Roller
		nemfile	Nem_Motobug
		nemfile	Nem_Newtron
		nemfile	Nem_Yadrin
		nemfile	Nem_Batbrain
		nemfile	Nem_Splats
		nemfile	Nem_Bomb
		nemfile	Nem_Orbinaut
		nemfile	Nem_Cater
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		nemfile	Nem_TitleCard
		nemfile	Nem_Hud,"HUD"				; HUD (rings, time
		nemfile	Nem_Lives
		nemfile	Nem_Ring
		nemfile	Nem_Monitors
		nemfile	Nem_Explode
		nemfile	Nem_Points
		nemfile	Nem_GameOver
		nemfile	Nem_HSpring
		nemfile	Nem_VSpring
		nemfile	Nem_SignPost
		nemfile	Nem_Lamp
		nemfile	Nem_BigFlash
		nemfile	Nem_Bonus
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
		nemfile	Nem_ContSonic
		nemfile	Nem_MiniSonic
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
		nemfile	Nem_Rabbit
		nemfile	Nem_Chicken
		nemfile	Nem_BlackBird
		nemfile	Nem_Seal
		nemfile	Nem_Pig
		nemfile	Nem_Flicky
		nemfile	Nem_Squirrel
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_GHZ:	incbin	"map16\GHZ.bin"
		even
		nemfile	Nem_GHZ_1st
		nemfile	Nem_GHZ_2nd
Blk256_GHZ:	incbin	"256x256 Mappings\GHZ.kos"
		even
Blk16_LZ:	incbin	"map16\LZ.bin"
		even
		nemfile	Nem_LZ
Blk256_LZ:	incbin	"256x256 Mappings\LZ.kos"
		even
Blk16_MZ:	incbin	"map16\MZ.bin"
		even
		nemfile	Nem_MZ
Blk256_MZ:	if Revision=0
			incbin	"256x256 Mappings\MZ.kos"
		else
			incbin	"256x256 Mappings\MZ (JP1).kos"
		endc
		even
Blk16_SLZ:	incbin	"map16\SLZ.bin"
		even
		nemfile	Nem_SLZ
Blk256_SLZ:	incbin	"256x256 Mappings\SLZ.kos"
		even
Blk16_SYZ:	incbin	"map16\SYZ.bin"
		even
		nemfile	Nem_SYZ
Blk256_SYZ:	incbin	"256x256 Mappings\SYZ.kos"
		even
Blk16_SBZ:	incbin	"map16\SBZ.bin"
		even
		nemfile	Nem_SBZ
Blk256_SBZ:	if Revision=0
			incbin	"256x256 Mappings\SBZ.kos"
		else
			incbin	"256x256 Mappings\SBZ (JP1).kos"
		endc
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
		nemfile	Nem_Eggman
		nemfile	Nem_Weapons
		nemfile	Nem_Prison
		nemfile	Nem_Sbz2Eggman
		nemfile	Nem_FzBoss
		nemfile	Nem_FzEggman
		nemfile	Nem_Exhaust
		nemfile	Nem_EndEm
		nemfile	Nem_EndSonic
		nemfile	Nem_TryAgain
		if Revision=0
			nemfile	Nem_EndEggman
		endc
Kos_EndFlowers:	incbin	"Graphics - Compressed\Ending Flowers.kos" ; ending sequence animated flowers
		even
		nemfile	Nem_EndFlower
		nemfile	Nem_CreditText
		nemfile	Nem_EndStH

		if Revision=0
			dcb.b $104,$FF				; why?
		else
			dcb.b $40,$FF
		endc
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	"collide\Angle Map.bin"
		even
CollArray1:	incbin	"collide\Collision Array (Normal).bin"
		even
CollArray2:	incbin	"collide\Collision Array (Rotated).bin"
		even
Col_GHZ:	incbin	"collide\GHZ.bin"			; GHZ index
		even
Col_LZ:		incbin	"collide\LZ.bin"			; LZ index
		even
Col_MZ:		incbin	"collide\MZ.bin"			; MZ index
		even
Col_SLZ:	incbin	"collide\SLZ.bin"			; SLZ index
		even
Col_SYZ:	incbin	"collide\SYZ.bin"			; SYZ index
		even
Col_SBZ:	incbin	"collide\SBZ.bin"			; SBZ index
		even
; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		incbin	"sslayout\1.bin"
		even
SS_2:		incbin	"sslayout\2.bin"
		even
SS_3:		incbin	"sslayout\3.bin"
		even
SS_4:		incbin	"sslayout\4.bin"
		even
		if Revision=0
SS_5:		incbin	"sslayout\5.bin"
		even
SS_6:		incbin	"sslayout\6.bin"
		else
	SS_5:		incbin	"sslayout\5 (JP1).bin"
			even
	SS_6:		incbin	"sslayout\6 (JP1).bin"
		endc
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	incbin	"Graphics\GHZ Waterfall.bin"
		even
Art_GhzFlower1:	incbin	"Graphics\GHZ Flower Large.bin"
		even
Art_GhzFlower2:	incbin	"Graphics\GHZ Flower Small.bin"
		even
Art_MzLava1:	incbin	"Graphics\MZ Lava Surface.bin"
		even
Art_MzLava2:	incbin	"Graphics\MZ Lava.bin"
		even
Art_MzTorch:	incbin	"Graphics\MZ Background Torch.bin"
		even
Art_SbzSmoke:	incbin	"Graphics\SBZ Background Smoke.bin"
		even

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	index *
		; GHZ
		ptr Level_GHZ1
		ptr Level_GHZbg
		ptr byte_68D70
		
		ptr Level_GHZ2
		ptr Level_GHZbg
		ptr byte_68E3C
		
		ptr Level_GHZ3
		ptr Level_GHZbg
		ptr byte_68F84
		
		ptr byte_68F88
		ptr byte_68F88
		ptr byte_68F88
		
		; LZ
		ptr Level_LZ1
		ptr Level_LZbg
		ptr byte_69190
		
		ptr Level_LZ2
		ptr Level_LZbg
		ptr byte_6922E
		
		ptr Level_LZ3
		ptr Level_LZbg
		ptr byte_6934C
		
		ptr Level_SBZ3
		ptr Level_LZbg
		ptr byte_6940A
		
		; MZ
		ptr Level_MZ1
		ptr Level_MZ1bg
		ptr Level_MZ1
		
		ptr Level_MZ2
		ptr Level_MZ2bg
		ptr byte_6965C
		
		ptr Level_MZ3
		ptr Level_MZ3bg
		ptr byte_697E6
		
		ptr byte_697EA
		ptr byte_697EA
		ptr byte_697EA
		
		; SLZ
		ptr Level_SLZ1
		ptr Level_SLZbg
		ptr byte_69B84
		
		ptr Level_SLZ2
		ptr Level_SLZbg
		ptr byte_69B84
		
		ptr Level_SLZ3
		ptr Level_SLZbg
		ptr byte_69B84
		
		ptr byte_69B84
		ptr byte_69B84
		ptr byte_69B84
		
		; SYZ
		ptr Level_SYZ1
		ptr Level_SYZbg
		ptr byte_69C7E
		
		ptr Level_SYZ2
		ptr Level_SYZbg
		ptr byte_69D86
		
		ptr Level_SYZ3
		ptr Level_SYZbg
		ptr byte_69EE4
		
		ptr byte_69EE8
		ptr byte_69EE8
		ptr byte_69EE8
		
		; SBZ
		ptr Level_SBZ1
		ptr Level_SBZ1bg
		ptr Level_SBZ1bg
		
		ptr Level_SBZ2
		ptr Level_SBZ2bg
		ptr Level_SBZ2bg
		
		ptr Level_SBZ2
		ptr Level_SBZ2bg
		ptr byte_6A2F8
		
		ptr byte_6A2FC
		ptr byte_6A2FC
		ptr byte_6A2FC
		zonewarning Level_Index,24
		
		; Ending
		ptr Level_End
		ptr Level_GHZbg
		ptr byte_6A320
		
		ptr Level_End
		ptr Level_GHZbg
		ptr byte_6A320
		
		ptr byte_6A320
		ptr byte_6A320
		ptr byte_6A320
		
		ptr byte_6A320
		ptr byte_6A320
		ptr byte_6A320

Level_GHZ1:	incbin	"levels\ghz1.bin"
		even
byte_68D70:	dc.b 0,	0, 0, 0
Level_GHZ2:	incbin	"levels\ghz2.bin"
		even
byte_68E3C:	dc.b 0,	0, 0, 0
Level_GHZ3:	incbin	"levels\ghz3.bin"
		even
Level_GHZbg:	incbin	"levels\ghzbg.bin"
		even
byte_68F84:	dc.b 0,	0, 0, 0
byte_68F88:	dc.b 0,	0, 0, 0

Level_LZ1:	incbin	"levels\lz1.bin"
		even
Level_LZbg:	incbin	"levels\lzbg.bin"
		even
byte_69190:	dc.b 0,	0, 0, 0
Level_LZ2:	incbin	"levels\lz2.bin"
		even
byte_6922E:	dc.b 0,	0, 0, 0
Level_LZ3:	incbin	"levels\lz3.bin"
		even
byte_6934C:	dc.b 0,	0, 0, 0
Level_SBZ3:	incbin	"levels\sbz3.bin"
		even
byte_6940A:	dc.b 0,	0, 0, 0

Level_MZ1:	incbin	"levels\mz1.bin"
		even
Level_MZ1bg:	incbin	"levels\mz1bg.bin"
		even
Level_MZ2:	incbin	"levels\mz2.bin"
		even
Level_MZ2bg:	incbin	"levels\mz2bg.bin"
		even
byte_6965C:	dc.b 0,	0, 0, 0
Level_MZ3:	incbin	"levels\mz3.bin"
		even
Level_MZ3bg:	incbin	"levels\mz3bg.bin"
		even
byte_697E6:	dc.b 0,	0, 0, 0
byte_697EA:	dc.b 0,	0, 0, 0

Level_SLZ1:	incbin	"levels\slz1.bin"
		even
Level_SLZbg:	incbin	"levels\slzbg.bin"
		even
Level_SLZ2:	incbin	"levels\slz2.bin"
		even
Level_SLZ3:	incbin	"levels\slz3.bin"
		even
byte_69B84:	dc.b 0,	0, 0, 0

Level_SYZ1:	incbin	"levels\syz1.bin"
		even
Level_SYZbg:	if Revision=0
			incbin	"levels\syzbg.bin"
		else
			incbin	"levels\syzbg (JP1).bin"
		endc
		even
byte_69C7E:	dc.b 0,	0, 0, 0
Level_SYZ2:	incbin	"levels\syz2.bin"
		even
byte_69D86:	dc.b 0,	0, 0, 0
Level_SYZ3:	incbin	"levels\syz3.bin"
		even
byte_69EE4:	dc.b 0,	0, 0, 0
byte_69EE8:	dc.b 0,	0, 0, 0

Level_SBZ1:	incbin	"levels\sbz1.bin"
		even
Level_SBZ1bg:	incbin	"levels\sbz1bg.bin"
		even
Level_SBZ2:	incbin	"levels\sbz2.bin"
		even
Level_SBZ2bg:	incbin	"levels\sbz2bg.bin"
		even
byte_6A2F8:	dc.b 0,	0, 0, 0
byte_6A2FC:	dc.b 0,	0, 0, 0
Level_End:	incbin	"levels\ending.bin"
		even
byte_6A320:	dc.b 0,	0, 0, 0


Art_BigRing:	incbin	"Graphics\Giant Ring.bin"
		even

		align	$100,$FF

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:	index *
		; GHZ
		ptr ObjPos_GHZ1
		ptr ObjPos_Null
		ptr ObjPos_GHZ2
		ptr ObjPos_Null
		ptr ObjPos_GHZ3
		ptr ObjPos_Null
		ptr ObjPos_GHZ1
		ptr ObjPos_Null
		; LZ
		ptr ObjPos_LZ1
		ptr ObjPos_Null
		ptr ObjPos_LZ2
		ptr ObjPos_Null
		ptr ObjPos_LZ3
		ptr ObjPos_Null
		ptr ObjPos_SBZ3
		ptr ObjPos_Null
		; MZ
		ptr ObjPos_MZ1
		ptr ObjPos_Null
		ptr ObjPos_MZ2
		ptr ObjPos_Null
		ptr ObjPos_MZ3
		ptr ObjPos_Null
		ptr ObjPos_MZ1
		ptr ObjPos_Null
		; SLZ
		ptr ObjPos_SLZ1
		ptr ObjPos_Null
		ptr ObjPos_SLZ2
		ptr ObjPos_Null
		ptr ObjPos_SLZ3
		ptr ObjPos_Null
		ptr ObjPos_SLZ1
		ptr ObjPos_Null
		; SYZ
		ptr ObjPos_SYZ1
		ptr ObjPos_Null
		ptr ObjPos_SYZ2
		ptr ObjPos_Null
		ptr ObjPos_SYZ3
		ptr ObjPos_Null
		ptr ObjPos_SYZ1
		ptr ObjPos_Null
		; SBZ
		ptr ObjPos_SBZ1
		ptr ObjPos_Null
		ptr ObjPos_SBZ2
		ptr ObjPos_Null
		ptr ObjPos_FZ
		ptr ObjPos_Null
		ptr ObjPos_SBZ1
		ptr ObjPos_Null
		zonewarning ObjPos_Index,$10
		; Ending
		ptr ObjPos_End
		ptr ObjPos_Null
		ptr ObjPos_End
		ptr ObjPos_Null
		ptr ObjPos_End
		ptr ObjPos_Null
		ptr ObjPos_End
		ptr ObjPos_Null
		; --- Put extra object data here. ---
ObjPosLZPlatform_Index:
		ptr ObjPos_LZ1pf1
		ptr ObjPos_LZ1pf2
		ptr ObjPos_LZ2pf1
		ptr ObjPos_LZ2pf2
		ptr ObjPos_LZ3pf1
		ptr ObjPos_LZ3pf2
		ptr ObjPos_LZ1pf1
		ptr ObjPos_LZ1pf2
ObjPosSBZPlatform_Index:
		ptr ObjPos_SBZ1pf1
		ptr ObjPos_SBZ1pf2
		ptr ObjPos_SBZ1pf3
		ptr ObjPos_SBZ1pf4
		ptr ObjPos_SBZ1pf5
		ptr ObjPos_SBZ1pf6
		ptr ObjPos_SBZ1pf1
		ptr ObjPos_SBZ1pf2
		endobj
		
		include "Object Subtypes.asm"
		include	"Object Placement\GHZ1.asm"
		include	"Object Placement\GHZ2.asm"
		include	"Object Placement\GHZ3.asm"
		include	"Object Placement\LZ1.asm"
		include	"Object Placement\LZ2.asm"
		include	"Object Placement\LZ3.asm"
		include	"Object Placement\SBZ3.asm"
		include	"Object Placement\LZ Platforms.asm"
		include	"Object Placement\MZ1.asm"
		include	"Object Placement\MZ2.asm"
		include	"Object Placement\MZ3.asm"
		include	"Object Placement\SLZ1.asm"
		include	"Object Placement\SLZ2.asm"
		include	"Object Placement\SLZ3.asm"
		include	"Object Placement\SYZ1.asm"
		include	"Object Placement\SYZ2.asm"
		include	"Object Placement\SYZ3.asm"
		include	"Object Placement\SBZ1.asm"
		include	"Object Placement\SBZ2.asm"
		include	"Object Placement\FZ.asm"
		include	"Object Placement\SBZ Platforms.asm"
		include	"Object Placement\Ending.asm"
ObjPos_Null:	endobj

		if Revision=0
			dcb.b $62A,$FF
		else
			dcb.b $63C,$FF
		endc
		;dcb.b ($10000-(*%$10000))-(EndOfRom-SoundDriver),$FF

; ===========================================================================
; ---------------------------------------------------------------------------
; Include sound driver data
; ---------------------------------------------------------------------------

		include "sound/Sound Data.asm"

EndOfRom:
		END

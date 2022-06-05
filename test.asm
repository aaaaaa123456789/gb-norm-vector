DEF rJOYP EQU $ff00
DEF rLCDC EQU $ff40
DEF rSCY  EQU $ff42
DEF rSCX  EQU $ff43
DEF rLY   EQU $ff44
DEF rBGP  EQU $ff47
DEF rKEY1 EQU $ff4d
DEF rVBK  EQU $ff4f
DEF rBCPS EQU $ff68
DEF rBCPD EQU $ff69
DEF rIE   EQU $ffff

DEF rMR2w EQU $0002
DEF rMR3w EQU $0003
DEF rMR2r EQU $a002

	charmap " ", 0
	charmap "0", 2
	charmap "1", 4
	charmap "4", 6
	charmap "7", 8
	charmap "8", 10
	charmap "F", 12

DEF vLabelPosition EQU $9d24

SECTION "Home", ROM0[0]
VectorNormalizationRST:
	jp NormalizeVector

	ds 5

GenerateOutputsForValue:
	bit 7, d
	push bc
	push af
	push de
	rst VectorNormalizationRST
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	pop de
	ld a, e
	add a, $20
	ld e, a
	adc d
	sub e
	ld d, a
	pop bc
	xor c
	add a, a
	ld a, b
	pop bc
	jr c, GenerateOutputsForValue
	push af
	ld a, d
	xor $80
	ld d, a
	pop af
	ret

	ds 4

WaitVBlank:
	ldh a, [rLY]
	cp $90
	jr nz, WaitVBlank
	ret

	ds 1

Init:
	cp $11
	ld a, 0
	ldh [rLCDC], a
	jr nz, .not_color
	inc a
	ldh [rVBK], a
	ld a, $80
	ldh [rBCPS], a
	xor a
	ld hl, $9c00
	:
	ld [hli], a
	bit 5, h
	jr z, :-
	ldh [rVBK], a
	dec a
	ldh [rBCPD], a
	ldh [rBCPD], a
	xor a
	ld l, 6
	:
	ldh [rBCPD], a
	dec l
	jr nz, :-
	ldh a, [rKEY1]
	add a, a
	jr c, :+
	ld a, 1
	ldh [rKEY1], a
	ld a, $30
	ldh [rJOYP], a
	stop
	:
	xor a
.not_color
	ld hl, $9c00
	:
	ld [hli], a
	bit 5, h
	jr z, :-
	ld hl, $fe9f
	:
	ld [hld], a
	bit 1, h
	jr nz, :-
	ldh [rSCX], a
	ldh [rIE], a
	ld a, 4
	ldh [rSCY], a
	ld a, $fc
	ldh [rBGP], a
	ld hl, $9000
	ld de, Font
	ld c, (Font.end - Font) / 8
.character_loop
	ld b, 8
	:
	ld a, [de]
	inc de
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, :-
	ld b, 8
	ld a, e
	sub b
	ld e, a
	jr nc, :+
	dec d
	:
	ld a, [de]
	cpl
	inc de
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, :-
	dec c
	jr nz, .character_loop
	ld a, $88
	ldh [rLCDC], a
	ld de, 0
	ld b, d
	ret

ReadJoypad:
	ld c, LOW(rJOYP)
	ld a, $10
	ldh [c], a
	push hl
	pop hl
	push hl
	pop hl
	ldh a, [c]
	ld c, a
	or $f0
	inc a
	ret

	ds 1

Font:
	db $00, $00, $00, $00, $00, $00, $00, $00 ;blank
	db $7C, $C6, $CE, $DE, $F6, $E6, $7C, $00 ;0
	db $30, $70, $30, $30, $30, $30, $FC, $00 ;1
	db $1C, $3C, $6C, $CC, $FE, $0C, $1E, $00 ;4
	db $FC, $CC, $0C, $18, $30, $30, $30, $00 ;7
	db $78, $CC, $CC, $78, $CC, $CC, $78, $00 ;8
	db $FE, $62, $68, $78, $68, $60, $F0, $00 ;F
.end

	assert @ == $100
EntryPoint:
	rst Init
	rst VectorNormalizationRST ; for quick debugging (result is discarded)
	jr Main
	ds $154 - @, 0

Main:
	ld hl, vLabelPosition
	push de
	ld a, d
	add a, a
	add a, a
	add a, LOW(StartValueStrings.first)
	ld e, a
	adc HIGH(StartValueStrings.first)
	sub e
	ld d, a
	ld c, 4
	rst WaitVBlank
	:
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, :-
	pop de
	xor a
	ld [hli], a
	push de
	ld a, e
	add a, a
	add a, a
	add a, LOW(StartValueStrings.second)
	ld e, a
	adc HIGH(StartValueStrings.second)
	sub e
	ld d, a
	ld c, 4
	:
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, :-
	pop de
	xor a
	ld [hli], a
	push bc
	ld a, b
	add a, a
	add a, LOW(StartValueStrings.size)
	ld c, a
	adc HIGH(StartValueStrings.size)
	sub c
	ld b, a
	ld a, [bc]
	inc bc
	ld [hli], a
	ld a, [bc]
	ld [hl], a
	pop bc

	call ReadJoypad
	jr z, Main
	srl c
	jr c, :+
	inc e
	ld a, e
	cp (StartValues.size - StartValues.second) / 2
	sbc a
	and e
	ld e, a
	:
	srl c
	jr c, :+
	inc d
	ld a, d
	cp (StartValues.second - StartValues.first) / 2
	sbc a
	and d
	ld d, a
	:
	srl c
	jr c, :+
	inc b
	ld a, b
	cp StartValues.end - StartValues.size
	sbc a
	and b
	ld b, a
	:
	srl c
	jr nc, .start
	:
	call ReadJoypad
	jr z, Main
	rst WaitVBlank
	jr :-

.start
	ld hl, vLabelPosition
	ld c, 12
	rst WaitVBlank
	:
	inc [hl]
	inc l
	dec c
	jr nz, :-
	push de
	push bc
	ld a, b
	add a, LOW(StartValues.size)
	ld l, a
	adc HIGH(StartValues.size)
	sub l
	ld h, a
	ld a, [hl]
	push af
	ld a, d
	add a, a
	add a, LOW(StartValues.first)
	ld l, a
	adc HIGH(StartValues.first)
	sub l
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, e
	add a, a
	add a, LOW(StartValues.second)
	ld l, a
	adc HIGH(StartValues.second)
	sub l
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop af
	call GenerateSavefile
	pop bc
	pop de
	jp Main

StartValues:
.first
	dw $0000, $000f, $0010, $4000, $400f, $4010
.second
	dw $0000, $000f, $0010, $8000, $8010, $8011
.size
	db $00, $01, $40, $41, $7f, $80, $81, $ff
.end

StartValueStrings:
.first
	db "0000", "000F", "0010", "4000", "400F", "4010"
.second
	db "0000", "000F", "0010", "8000", "8010", "8011"
.size
	db "00", "01", "40", "41", "7F", "80", "81", "FF"

GenerateSavefile:
	; de increases by $20 every iteration; bc increases by $20 (and de resets) when de rolls over after $400 iterations; a stays fixed
	; since each SRAM bank is $2000 bytes long, each bank can store $800 results, so it stores the results for two values of bc
	push af
	ld hl, rMR3w
	xor a
.loop
	ld [hl], l ; map SRAM for read/write
	ld [rMR2w], a
	ld hl, $a000
	rept 2
		pop af
		rst GenerateOutputsForValue
		push af
		ld a, c
		add a, $20
		ld c, a
		adc b
		sub c
		ld b, a
	endr
	ld hl, rMR3w
	ld [hl], h ; map registers
	ld a, [rMR2r]
	inc a
	jr nz, .loop
	pop af
	ret

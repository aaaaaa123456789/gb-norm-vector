SECTION "Home", ROM0[$100]
EntryPoint:
	cp $11
	jr Init
	ds $150 - @, 0

Init:
	ld b, b
	nop
	call NormalizeVector
	jr Init

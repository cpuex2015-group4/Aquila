.data
.word 0x00000000

.text
_leml_entry:
	li %r2,pohe
	nop
	jr %r31
	jr %r31
		jr %r31
		jr %r31
		jr %r31
		jr %r31
	li %r1,$5
	out %r1
	hlt
pohe:
	li %r1,$17
	out %r1
	hlt

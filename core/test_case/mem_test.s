.data
ten:
	.word 0x0000000A
.text
_leml_entry:
	ld %r1,%r0,ten
	out %r1
	hlt

.data
one:
	.word 0x00000001
.text
_leml_entry:
	ld %r1,%r0,one
	hlt

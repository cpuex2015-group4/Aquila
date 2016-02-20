.data
ten:
	.word 0x0000000A
.text
_leml_entry:
	st %r1,%r2,$3
	hlt

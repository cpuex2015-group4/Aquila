.data
_one
	.word 0x00000001
_two
	.word 0x00000002
_three
	.word 0x00000003

.text
_leml_entry:
	ld %r1,_one
	ld %r2,_two
	ld %r3,_three
	hlt

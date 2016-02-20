.data
	.word 0x00000000

.text
_leml_entry:
	li %r1,$10
	srl %r1,%r1,$1
	srl %r1,%r1,$1
	srl %r1,%r1,$1
	srl %r1,%r1,$1
	srl %r1,%r1,$1
	out %r1
	hlt


.data
	.word 0x00000000

.text
_leml_entry:
	li %r1,$31
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	out %r1
	srl %r1,%r1,$1
	hlt


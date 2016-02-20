.data
.word 0x00000000

.text
_func:
	nop
	nop
	nop
	nop
	nop
	srl %r1,%r4,$24
	srl %r2,%r4,$16
	srl %r3,%r4,$8
	out %r1
	out %r2
	out %r3
	out %r4
	nop
	li %r3,$100
	jr %r4

_leml_entry:
	jal _func
	out %r3
	hlt


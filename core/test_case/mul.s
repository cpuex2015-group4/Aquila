.data
.word 0x00000000

.text
_mul:
	beq %r9,%r0,_end
	subi %r9,%r9,$1
	subi %r7,%r7,$2
	st %r8,%r7,$1
	st %r4,%r7,$2
	jal _mul
	ld %r8,%r7,$1
	ld %r4,%r7,$2
	add %r3,%r3,%r8
	jr %r4
_end:
	li %r3,$0
	jr %r4

_leml_entry:
	li %r8,$7
	li %r9,$4
	jal _mul
	out %r3
	hlt

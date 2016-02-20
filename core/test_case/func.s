.data
.word 0x00000000

.text
_add:
	beq %r9,%r0,_leaf
	addi %r8,%r8,$1
	subi %r9,%r9,$1
	subi %r7,%r7,$1
	st %r4,%r7,$0
	jal _add
	ld %r4,%r7,$0
	addi %r7,%r7,$1
	jr %r4
_leaf:
	jr %r4


_leml_entry:
	li %r8,$10
	li %r9,$15
	jal _add
	out %r4
	hlt


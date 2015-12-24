.data
	.word 0x00000000

.text
_leml_entry:
	addi %r1,%r0,$0
	addi %r2,%r0,$1
loop:
	out %r1
	add %r3,%r0,%r1
	add %r1,%r0,%r2
	add %r2,%r1,%r3
	j loop

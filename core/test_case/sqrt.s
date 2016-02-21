.data
one:
	.word 0x3f800000

.text
_leml_entry:
	in %r4
	add.s %f1,%f0,%f0
	ld.s %f2,%r0,one
loop:
	beq %r0,%r4,loop_end
	add.s %f3,%f0,%f1
	add.s %f1,%f0,%f2
	add.s %f2,%f1,%f3
	subi %r4,%r4,$1
	j loop
loop_end:
	out %f3
	hlt

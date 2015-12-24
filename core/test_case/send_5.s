.data
.word 0x00000000

.text
_leml_entry:
	addi %r1,%r0,$5
	out %r1
	hlt
	

.data
.word 0x00000000

.text
_pow:
	beq %r9,%r0,_end
	subi %r

_leml_entry:
	in %r1
	out %r1
	j _leml_entry
	hlt
	

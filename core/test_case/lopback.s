.data
.word 0x00000000

.text
_leml_entry:
	in %r1
	out %r1
	j _leml_entry
	hlt
	

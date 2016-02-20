.data
.word 0x00000000

.text
_func:
	nop
	nop
	nop
	nop
	nop
	jr %r4

_leml_entry:
	jal _func
	hlt


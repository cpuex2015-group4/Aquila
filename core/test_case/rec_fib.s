.data
one:
	.word 0x3f80000000

.text
_recfib:
	li %r9,$1
	ble %r8,%r9,leaf
	

_leml_entry:

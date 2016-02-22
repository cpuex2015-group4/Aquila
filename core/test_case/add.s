.data
.text
	.extern _leml_entry
myadd.3:
	add     %r3, %r9, %r10
	jr      %r4
_leml_entry: # main entry point
	# main program start
	li      %r7, $31
	sll     %r7, %r7, $15
	addi    %r7, %r7, $32767
	li      %r5, min_caml_heap_pointer
	li      %r9, $2
	li      %r10, $3
	subi    %r7, %r7, $1
	st      %r4, %r7, $0
	jal     myadd.3
	ld      %r4, %r7, $0
	addi    %r7, %r7, $1
	# main program end
	hlt

min_caml_heap_pointer:

	.file	"aze.bc"
	.text
	.globl	drive
	.align	16, 0x90
	.type	drive,@function
drive:                                  # @drive
.Ltmp4:
	.cfi_startproc
# BB#0:
	pushq	%r15
.Ltmp5:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp6:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp7:
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
.Ltmp8:
	.cfi_def_cfa_offset 48
.Ltmp9:
	.cfi_offset %rbx, -32
.Ltmp10:
	.cfi_offset %r14, -24
.Ltmp11:
	.cfi_offset %r15, -16
	movq	%rsi, %rbx
	movq	536(%rbx), %r14
	leaq	536(%rbx), %r15
	movq	%r15, %rdi
	callq	get_track_angle
	movss	%xmm0, 12(%rsp)         # 4-byte Spill
	movq	%rbx, %rdi
	callq	get_car_yaw
	movss	12(%rsp), %xmm1         # 4-byte Reload
	subss	%xmm0, %xmm1
	movaps	%xmm1, %xmm0
	callq	norm_pi_pi
	movq	%r15, %rdi
	callq	get_pos_to_middle
	movq	%r14, %rdi
	callq	get_track_seg_width
	movl	$1065353216, 1524(%rbx) # imm = 0x3F800000
	addq	$16, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	ret
.Ltmp12:
	.size	drive, .Ltmp12-drive
.Ltmp13:
	.cfi_endproc
.Leh_func_end0:


	.section	".note.GNU-stack","",@progbits

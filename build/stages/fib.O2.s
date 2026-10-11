	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0"
	.file	"fib.c"
	.text
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	addi	sp, sp, -48
	.cfi_def_cfa_offset 48
	sd	ra, 40(sp)                      # 8-byte Folded Spill
	sd	s0, 32(sp)                      # 8-byte Folded Spill
	sd	s1, 24(sp)                      # 8-byte Folded Spill
	sd	s2, 16(sp)                      # 8-byte Folded Spill
	sd	s3, 8(sp)                       # 8-byte Folded Spill
	.cfi_offset ra, -8
	.cfi_offset s0, -16
	.cfi_offset s1, -24
	.cfi_offset s2, -32
	.cfi_offset s3, -40
.Lpcrel_hi0:
	auipc	a0, %pcrel_hi(.L.str)
	addi	a0, a0, %pcrel_lo(.Lpcrel_hi0)
	addi	a1, sp, 4
	call	scanf
.Lpcrel_hi1:
	auipc	a0, %pcrel_hi(.L.str.1)
	addi	s1, a0, %pcrel_lo(.Lpcrel_hi1)
	mv	a0, s1
	li	a1, 0
	call	printf
	li	a1, 1
	li	s0, 1
	mv	a0, s1
	call	printf
	lw	a0, 4(sp)
	bge	s0, a0, .LBB0_3
# %bb.1:
	li	a0, 0
.Lpcrel_hi2:
	auipc	a1, %pcrel_hi(.L.str.1)
	addi	s2, a1, %pcrel_lo(.Lpcrel_hi2)
	li	s1, 1
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	addw	s3, a0, s1
	mv	a0, s2
	mv	a1, s3
	call	printf
	lw	a1, 4(sp)
	addiw	s0, s0, 1
	mv	a0, s1
	mv	s1, s3
	blt	s0, a1, .LBB0_2
.LBB0_3:
	li	a0, 0
	ld	ra, 40(sp)                      # 8-byte Folded Reload
	ld	s0, 32(sp)                      # 8-byte Folded Reload
	ld	s1, 24(sp)                      # 8-byte Folded Reload
	ld	s2, 16(sp)                      # 8-byte Folded Reload
	ld	s3, 8(sp)                       # 8-byte Folded Reload
	.cfi_restore ra
	.cfi_restore s0
	.cfi_restore s1
	.cfi_restore s2
	.cfi_restore s3
	addi	sp, sp, 48
	.cfi_def_cfa_offset 0
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"%d"
	.size	.L.str, 3

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"%d\n"
	.size	.L.str.1, 4

	.ident	"Alpine clang version 20.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig

# Hand-written translation of examples/features.sy. No compiler output copied.
.attribute stack_align, 16
.section .bss
.balign 4
.globl calls
calls: .zero 4
.section .rodata
.balign 4
.Lhalf: .float 0.5
.Ltwo: .float 2.0
.text
.globl touch
.type touch,@function
touch:
    la t0, calls
    lw t1, 0(t0)
    addiw t1, t1, 1
    sw t1, 0(t0)
    ret
.size touch,.-touch
.globl reduce
.type reduce,@function
reduce:
    li t0, 0
    li t1, 0
.Lreduce_cond:
    bge t0, a1, .Lreduce_end
    slli t2, t0, 2
    add t2, a0, t2
    lw t3, 0(t2)
    beqz t3, .Lreduce_end
    bltz t3, .Lreduce_next
    addw t1, t1, t3
.Lreduce_next:
    addiw t0, t0, 1
    j .Lreduce_cond
.Lreduce_end:
    mv a0, t1
    ret
.size reduce,.-reduce
.globl blend
.type blend,@function
blend:
    la t0, .Lhalf
    flw ft0, 0(t0)
    la t0, .Ltwo
    flw ft1, 0(t0)
    fadd.s ft0, fa0, ft0
    fmul.s ft0, ft0, ft1
    fsub.s ft0, ft0, fa1
    fdiv.s ft0, ft0, ft1
    fcvt.w.s a0, ft0, rtz
    ret
.size blend,.-blend
.globl emit
.type emit,@function
emit:
    addi sp, sp, -16
    sd ra, 8(sp)
    call putint
    li a0, 10
    call putch
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
.size emit,.-emit
.globl main
.type main,@function
main:
    # local a[5] at sp+0; saved regs at sp+40..56; frame 64 bytes
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    call getint
    mv s0, a0
    call getint
    mv s1, a0
    sw s0, 0(sp)
    li t0, -2
    sw t0, 4(sp)
    sw s1, 8(sp)
    sw zero, 12(sp)
    li t0, 9
    sw t0, 16(sp)
    addw a0, s0, s1
    call emit
    subw a0, s0, s1
    call emit
    mulw a0, s0, s1
    call emit
    beqz s1, .Lzero_divisor
    divw a0, s0, s1
    call emit
    remw a0, s0, s1
    call emit
    j .Lclassify
.Lzero_divisor:
    li a0, 0
    call emit
    li a0, 0
    call emit
.Lclassify:
    slt t0, zero, s0
    slt t1, s0, zero
    sub a0, t0, t1
    call emit
    # Short-circuit &&: division is unreachable when d==0.
    beqz s1, .Land_false
    divw t0, s0, s1
    li t1, 1
    bge t1, t0, .Land_false
    li a0, 1
    j .Land_emit
.Land_false:
    li a0, 0
.Land_emit:
    call emit
    # Short-circuit ||: touch is skipped when d==0.
    beqz s1, .Lor_true
    mv a0, s0
    call touch
    snez a0, a0
    j .Lor_emit
.Lor_true:
    li a0, 1
.Lor_emit:
    call emit
    la t0, calls
    lw a0, 0(t0)
    call emit
    li a0, 0
    bge s1, s0, .Lnot_emit
    bltz s0, .Lnot_emit
    li a0, 1
.Lnot_emit:
    call emit
    mv a0, sp
    li a1, 5
    call reduce
    call emit
    fcvt.s.w fa0, s0
    fcvt.s.w fa1, s1
    call blend
    call emit
    negw a0, s0
    call emit
    # Inner x = d+1; the outer x in s0 stays live.
    addiw a0, s1, 1
    call emit
    mv a0, s0
    call emit
    li a0, 0
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret
.size main,.-main
.section .note.GNU-stack,"",@progbits

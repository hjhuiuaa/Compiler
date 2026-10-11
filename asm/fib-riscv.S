# Hand-written RV64GC / LP64D translation of ../fib.sy.
# s0=a, s1=b, s2=i, s3=n. All survive calls to the SysY runtime.
.attribute stack_align, 16
.text
.globl main
.type main, @function
main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    li s0, 0
    li s1, 1
    li s2, 1
    call getint
    mv s3, a0
    mv a0, s0
    call putint
    li a0, 10
    call putch
    mv a0, s1
    call putint
    li a0, 10
    call putch
.Lfib_cond:
    bge s2, s3, .Lfib_exit
    mv t0, s1
    addw s1, s0, s1
    mv s0, t0
    mv a0, s1
    call putint
    li a0, 10
    call putch
    addiw s2, s2, 1
    j .Lfib_cond
.Lfib_exit:
    li a0, 0
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits

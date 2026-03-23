.data
    val:  .word 0x12345678
    temp: .space 4
.text
main:
    lw t1, val

    la t0, temp
    sw t1, 0(t0)

    lbu t2, 0(t0)
    lbu t3, 1(t0)
    lbu t4, 2(t0)
    lbu t5, 3(t0)

    slli t2, t2, 24
    slli t3, t3, 16
    slli t4, t4, 8
    
    or t6, t2, t3
    or t6, t6, t4
    or t6, t6, t5

    mv a0, t6
    li a7, 34
    ecall
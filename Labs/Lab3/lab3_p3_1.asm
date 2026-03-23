.data
    buffer: .space 1024

.text
.global main
main:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    la s0, buffer
    li s1, 1 # iteration of a

outer_loop:
    li s2, 1 # iteration of b

inner_loop:
    # at a0, a1 * a2
    mv a0, s0
    mv a1, s1
    mv a2, s2

    jal ra, generate_expr
    mv s0, a0
    addi s2, s2, 1

    li t0, 10
    blt s2, t0, inner_loop

    li t1, '\n'
    sb t1, -1(s0)
    addi s1, s1, 1
    blt s1, t0, outer_loop

    li t1, '\0'
    sb t1, 0(s0)

    la a0, buffer
    li a7, 4
    ecall

    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    li a7, 10
    ecall

generate_expr: # at a0, a1 * a2
    addi sp, sp, -12
    sw ra, 8(sp)
    sw a1, 4(sp)
    sw a2, 0(sp)

    jal ra, append_num
    li t0, '*'
    sb t0, 0(a0)
    addi a0, a0, 1

    lw a1, 0(sp)
    jal ra, append_num
    li t0, '='
    sb t0, 0(a0)
    addi a0, a0, 1

    lw t1, 4(sp)
    lw t2, 0(sp)
    mul a1, t1, t2
    jal ra, append_num

    li t0, '\t'
    sb t0, 0(a0)
    addi a0, a0, 1

    lw ra, 8(sp)
    lw a1, 4(sp)
    lw a2, 0(sp)
    addi sp, sp, 12

    jr ra

append_num:
    li t0, 10
    blt a1, t0, single

    div t1, a1, t0
    rem t2, a1, t0

    addi t1, t1, '0'
    sb t1, 0(a0)
    addi a0, a0, 1

    addi t2, t2, '0'
    sb t2, 0(a0)
    addi a0, a0, 1
    jr ra

single:
    addi t1, a1, '0'
    sb t1, 0(a0)
    addi a0, a0, 1
    jr ra
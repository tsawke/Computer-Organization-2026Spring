.data
    m1: .half 8 # multiplicand
    m2: .half -9 # multiplier

.text
main:
    lh t0, m1
    lh t1, m2
    xor t4, t0, t1
    bge t0, zero, t1Abs
    sub t0, zero, t0

t1Abs:
    bge t1, zero, init
    sub t1, zero, t1

init:
    li t2, 0 # res
    li t3, 16 # counter

loop:
    andi t5, t1, 1
    beq t5, zero, SkipAdd
    add t2, t2, t0

SkipAdd:
    slli t0, t0, 1
    srli t1, t1, 1
    addi t3, t3, -1
    bnez t3, loop

    bge t4, zero, output
    sub t2, zero, t2

output:
    mv a0, t2
    li a7, 1
    ecall
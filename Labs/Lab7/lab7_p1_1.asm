.data
    num: .word 0

.text
.globl main
main:
    li a7, 6
    ecall

    la t0, num
    fsw fa0, 0(t0)

    lw t1, 0(t0)

    # sign
    srli a0, t1, 31
    li a1, 1
    jal ra, print_binary

    # 30 - 23
    srli a0, t1, 23
    andi a0, a0, 0xFF #1111 1111
    li a1, 8
    jal ra, print_binary

    # 22 - 0
    li t2, 0x7FFFFF #111 1111 1111 1111 1111 1111
    and a0, t1, t2
    li a1, 23
    jal ra, print_binary

    li a7, 10
    ecall


# a0: value, a1: length
print_binary:
    mv t6, a0
    # mask = 1 << (bits-1)
    addi t3, a1, -1
    li t4, 1
    sll t4, t4, t3

loop:
    and t5, t6, t4
    beqz t5, print_zero

    
    li a0, '1'
    li a7, 11
    ecall

    j print_next

print_zero:
    li a0, '0'
    li a7, 11
    ecall

print_next:
    srli t4, t4, 1
    bnez t4, loop

    li a0, '\n'
    li a7, 11
    ecall

    ret
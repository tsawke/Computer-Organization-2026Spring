.data
    str: .space 260

.text
.global main
main:
    la a0, str
    li a1, 257
    li a7, 8
    ecall

    li a0, 0

loop:

    la t3, str
    add t0, a0, t3

    lb t1, 0(t0)
    li t2, '\0'
    beq t1, t2, end

    li t2, '\n'
    beq t1, t2, end

    li t2, '\r'
    beq t1, t2, end

    addi a0, a0, 1
    j loop

end:
    li a7, 1
    ecall
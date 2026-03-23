.data

.text
.global main
main:
    li a7, 5
    ecall

    jal ra, fib
    mv t0, a0


    li a7, 1 #print
    ecall

    li a7, 10 #terminate
    ecall

fib:
    addi sp, sp, -16
    sw a0, 0(sp)
    sw ra, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    li t0, 1
    ble a0, t0, edge_case

    addi a0, a0, -1
    jal ra, fib
    mv s1, a0

    lw a0, 0(sp)
    addi a0, a0, -2
    jal ra, fib
    mv s2, a0

    add a0, s1, s2

    j fib_end

edge_case:
    li a0, 1

fib_end:
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw ra, 4(sp)
    addi sp, sp, 16
    ret
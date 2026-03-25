.data

.text
.global main
main:
    li a7, 5
    ecall

    mv s1, a0 # s1 : n
    li s2, 1 # s2 : i
    li s3, 0 # s3 : res

loop:
    bgt s2, s1, end

    mv a0, s2
    jal ra, CalSquare

    add s3, s3, a0
    addi s2, s2, 1
    j loop

CalSquare:
    mul a0, a0, a0
    ret

end:
    mv a0, s3
    li a7, 1
    ecall
.data
    str: .asciz "Invalid input"
.text
.global main
main:
    li a7, 5
    ecall

    blez a0, invalid
    
    mv s0, a0          # s0: n
    li s1, -2147483648 # s1 : max
    li s2, 2147483647  # s2 : min

    li s3, 1           # s3 : i

loop:
    bgt s3, s0, end

    li a7, 5
    ecall

    bgt a0, s1, SwitchMax
    j SkipSwitchMax

SwitchMax:
    mv s1, a0
SkipSwitchMax:

    blt a0, s2, SwitchMin
    j SkipSwitchMin

SwitchMin:
    mv s2, a0
SkipSwitchMin:

    addi s3, s3, 1
    j loop

end:
    mv a0, s1
    li a7, 1
    ecall

    li a0, '\n'
    li a7, 11
    ecall

    mv a0, s2
    li a7, 1
    ecall

    li a7, 10
    ecall

invalid:
    la a0, str
    li a7, 4
    ecall

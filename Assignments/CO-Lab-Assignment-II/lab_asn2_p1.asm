.data
    str: .asciz "Invalid input"

.text
.global main
main:
    li a7, 5
    ecall

    blez a0, invalid

    mv s0, a0          # s0: n
    li s1, 1           # s1: i

    fcvt.s.w fs0, x0   # fs0: sum_abs
    fcvt.s.w fs1, x0   # fs1: sum_sq

loop:
    bgt s1, s0, end

    li a7, 6
    ecall
    fmv.s fa1, fa0     # fa1: x

    li a7, 6
    ecall
    fmv.s fa2, fa0     # fa2: y

    fmul.s fa3, fa1, fa1
    fmul.s fa3, fa3, fa1
    fadd.s fa3, fa3, fa1   # fa3: x^3 + x

    fsub.s fa4, fa2, fa3   # fa4: e = y - (x^3 + x)

    fabs.s fa5, fa4
    fadd.s fs0, fs0, fa5   # sum_abs += |e|

    fmul.s fa5, fa4, fa4
    fadd.s fs1, fs1, fa5   # sum_sq += e^2

    addi s1, s1, 1
    j loop

end:
    fcvt.s.w fa6, s0       # fa6: float(n)

    fdiv.s fa0, fs0, fa6
    li a7, 2
    ecall

    li a0, '\n'
    li a7, 11
    ecall

    fdiv.s fa0, fs1, fa6
    li a7, 2
    ecall

    li a7, 10
    ecall

invalid:
    la a0, str
    li a7, 4
    ecall
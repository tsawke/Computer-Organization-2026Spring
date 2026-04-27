.data
    one:   .float 1.0
    three: .float 3.0
    eps:   .float 0.000001

.text
.global main
main:
    li a7, 6
    ecall
    fmv.s fs0, fa0         # fs0: a

    li a7, 6
    ecall
    fmv.s fs1, fa0         # fs1: x_cur

    la t0, one
    flw fs2, 0(t0)         # fs2: 1.0

    la t0, three
    flw fs3, 0(t0)         # fs3: 3.0

    la t0, eps
    flw fs4, 0(t0)         # fs4: 1e-6

loop:
    fmul.s fa1, fs1, fs1   # fa1: x^2
    fmul.s fa2, fa1, fs1   # fa2: x^3
    fadd.s fa2, fa2, fs1   # fa2: x^3 + x
    fsub.s fa2, fa2, fs0   # fa2: f(x) = x^3 + x - a

    fmul.s fa3, fa1, fs3   # fa3: 3x^2
    fadd.s fa3, fa3, fs2   # fa3: f'(x) = 3x^2 + 1

    fdiv.s fa4, fa2, fa3   # fa4: f(x) / f'(x)
    fsub.s fs5, fs1, fa4   # fs5: x_nxt = x_cur - f/f'

    fsub.s fa5, fs5, fs1   # fa5: x_nxt - x_cur
    fabs.s fa5, fa5        # fa5: |x_nxt - x_cur|

    flt.s t1, fa5, fs4
    bnez t1, end

    fmv.s fs1, fs5         # x_cur = x_nxt
    j loop

end:
    fmv.s fa0, fs5
    li a7, 2
    ecall

    li a7, 10
    ecall
.data
    zeroStr:     .asciz "Zero"
    denormalStr: .asciz "Denormal"
    normalStr:   .asciz "Normal"

    signStr: .space 2       # 1  bit  + '\0'
    expStr:  .space 12      # 11 bits + '\0'
    fracStr: .space 53      # 52 bits + '\0'

.align 3
    num: .space 8           # store input double

.text
.global main
main:
    li a7, 7
    ecall

    la t0, num
    fsd fa0, 0(t0)

    lw s0, 0(t0)            # s0 : low  32 bits
    lw s1, 4(t0)            # s1 : high 32 bits

    srli s2, s1, 20
    andi s2, s2, 0x7ff      # s2 : exp field

    li t1, 0x000fffff
    and s3, s1, t1          # s3 : high 20 bits of frac

    # sign bit
    la t0, signStr
    srli t1, s1, 31
    addi t1, t1, '0'
    sb t1, 0(t0)
    sb x0, 1(t0)

    # exp field (11 bits)
    la t0, expStr
    li t1, 10

ExpLoop:
    blt t1, x0, ExpEnd

    srl t2, s2, t1
    andi t2, t2, 1
    addi t2, t2, '0'
    sb t2, 0(t0)

    addi t0, t0, 1
    addi t1, t1, -1
    j ExpLoop

ExpEnd:
    sb x0, 0(t0)

    # frac field (52 bits)
    # 20 + 32
    la t0, fracStr
    li t1, 19

FracHighLoop:
    blt t1, x0, FracLowInit

    srl t2, s3, t1
    andi t2, t2, 1
    addi t2, t2, '0'
    sb t2, 0(t0)

    addi t0, t0, 1
    addi t1, t1, -1
    j FracHighLoop

FracLowInit:
    li t1, 31

FracLowLoop:
    blt t1, x0, FracEnd

    srl t2, s0, t1
    andi t2, t2, 1
    addi t2, t2, '0'
    sb t2, 0(t0)

    addi t0, t0, 1
    addi t1, t1, -1
    j FracLowLoop

FracEnd:
    sb x0, 0(t0)

    # output sign
    la a0, signStr
    li a7, 4
    ecall

    li a0, '\n'
    li a7, 11
    ecall

    # output exp
    la a0, expStr
    li a7, 4
    ecall

    li a0, '\n'
    li a7, 11
    ecall

    # output frac
    la a0, fracStr
    li a7, 4
    ecall

    li a0, '\n'
    li a7, 11
    ecall

    # exp == 0 and frac == 0  => Zero
    # exp == 0 and frac != 0  => Denormal
    # otherwise               => Normal
    beqz s2, CheckFrac

    la a0, normalStr
    j PrintType

CheckFrac:
    bnez s3, IsDenormal
    bnez s0, IsDenormal

    la a0, zeroStr
    j PrintType

IsDenormal:
    la a0, denormalStr

PrintType:
    li a7, 4
    ecall

    li a7, 10
    ecall
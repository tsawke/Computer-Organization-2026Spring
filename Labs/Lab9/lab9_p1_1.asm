.data

.text
.global main
main:
    lw   x1, 0(x31)
    andi x1, x1, 0x0F
    sw   x1, 8(x31)
    j    main

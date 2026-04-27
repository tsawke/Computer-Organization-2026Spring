.data

.text
.global main

main:
    li.w    $a7, 5 # read int
    syscall $a7    # result: $a0

    bl      fib    # result: $a0

    li.w    $a7, 1 # print int
    syscall $a7

    li.w    $a7, 10
    syscall $a7

fib:
    addi.w  $sp, $sp, -16
    st.w    $a0, $sp, 0
    st.w    $ra, $sp, 4
    st.w    $s1, $sp, 8
    st.w    $s2, $sp, 12

    li.w    $t0, 1
    ble     $a0, $t0, edge_case

    addi.w  $a0, $a0, -1
    bl      fib
    move    $s1, $a0

    ld.w    $a0, $sp, 0
    addi.w  $a0, $a0, -2
    bl      fib
    move    $s2, $a0

    add.w   $a0, $s1, $s2
    b       fib_end

edge_case:
    li.w    $a0, 1

fib_end:
    ld.w    $s2, $sp, 12
    ld.w    $s1, $sp, 8
    ld.w    $ra, $sp, 4
    addi.w  $sp, $sp, 16
    jr      $ra
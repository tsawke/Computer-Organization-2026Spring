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
    li.w    $t0, 1
    ble     $a0, $t0, edge_case

    li.w    $t1, 1
    li.w    $t2, 1
    li.w    $t3, 2  # i = 2

loop:
    add.w   $t4, $t1, $t2
    move    $t1, $t2 
    move    $t2, $t4

    beq     $t3, $a0, end
    addi.w  $t3, $t3, 1
    b       loop

end:
    move    $a0, $t2
    jr      $ra

edge_case:
    li.w    $a0, 1
    jr      $ra
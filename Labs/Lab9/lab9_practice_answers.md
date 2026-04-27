# Lab9 Practice Answers

## Practice 1

Practice1(1): choose **D**.

```asm
.text
start:
    lw   x1, 0(x31)
    andi x1, x1, 0x0F
    sw   x1, 8(x31)
    j    start
```

Instruction hex:

```text
000fa083
00f0f093
001fa423
ff5ff06f
```

Practice1(2): choose **G**: 1, 4, 5.

The special-purpose circuit only needs the design source changed, a new bitstream generated, and the device programmed again. The existing switch/LED pins and board/chip selection do not need to change for the same IO width.

## Practice 2

Use the lines in `lab9_practice2_srai_dataset.txt` as the batch test dataset for testcase 0, whose target instruction is:

```asm
srai x1, x1, 1
```

For I-type instructions, the second operand in the dataset is `0`.

# CO - Theoretical Assignment-I

## Q1

```assembly
addi x5, x7, -5
add  x5, x5, x6
```

## Q2

```c
B[g] = A[f] + A[f + 1], f = A[f];
```

## Q3

R-type

```assembly
add x1, x1, x1
```

## Q4

I-type

```assembly
lw x3, 4(x27)
```

 0000 0000 0100 1101 1010 0001 1000 0011

## Q5

`jal`: All even addresses in [0x1FF00000, 0x200FFFFE].

`beq`: All even addresses in [0x1FFFF000, 0x20000FFE].

## Q6

- 20

- ```c
  while(x6 != 0)
      --x6, x5 += 2;
  ```

- 4N + 1

- ```c
  while(x6 >= 0)
      --x6, x5 += 2;
  ```

## Q7

There are following errors in the AI-generated answer:

1. `sub x30, x29, x28` computes `j - i`, but the C requires `i - j`. Thus it should be `sub x30, x28, x29`.

2. `slli x30, x30, 3` represents multiplying the index by 8. 

   Since in our RV32 system, each element is 4 bytes, then the index should be multiplied by 4.

   Therefore it should be `slli x30, x30, 2`.

3. `ld` and `sd` are incorrect here.  For in RV32, `lw` and `sw` should be used for integer arrays.

4. `ld x31, x30(x10)` contains syntax error in addressing. It's required to first compute the effective address, then load from offset 0.

5. `sd x31, 8(x11)` stores element to offset 8, which represents `B[2]`, not `B[8]`, since each integer is 4 bytes. `B[8]` is at offset `8 * 4 = 32`.

Correct answer:

```assembly
sub  x30, x28, x29
slli x30, x30, 2
add  x30, x10, x30
lw   x31, 0(x30)
sw   x31, 32(x11)
```

## Q8

There are following errors in the AI-generated answer:

1. `addi x6, x0, 0` sets `i` to 0, instead of setting `result` to 0.  Therefore `result = 0;` is incorrect.

2. The loop condition is wrong.  For `x29 = 100` and the loop continues when `x6 < x29`, the correct condition is `i < 100`, instead of `i <= 100`.

3. `addi x10, x10, 4` advances the address by 4 bytes, which represents moving to the next integer element. 

   In the C code, for `MemArray` is an integer pointer, this should be written as `MemArray = MemArray + 1`, instead of `MemArray = MemArray + 4`.

Correct answer:

```c
i = 0;
while(i < 100){
    result = result + MemArray[0];
    MemArray = MemArray + 1;
    i = i + 1;
}
```

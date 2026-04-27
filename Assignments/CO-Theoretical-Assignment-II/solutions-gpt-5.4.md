# CO - Theoretical Assignment-II

## Question 1 (Textbook 1.5)

### 1.5(a) Highest performance in instructions per second

The performance in instructions per second is

\[
\text{IPS}=\frac{\text{Clock rate}}{\text{CPI}}.
\]

So:

\[
\text{IPS}_{P1}=\frac{3\times 10^9}{1.5}=2.0\times 10^9
\]

\[
\text{IPS}_{P2}=\frac{2.5\times 10^9}{1.0}=2.5\times 10^9
\]

\[
\text{IPS}_{P3}=\frac{4.0\times 10^9}{2.2}\approx 1.818\times 10^9
\]

Hence,

\[
\boxed{P2 \text{ has the highest performance}.}
\]

---

### 1.5(b) Number of cycles and number of instructions in 10 seconds

We use

\[
\text{Cycles}=\text{Clock rate}\times \text{Execution time}
\]

and

\[
\text{Instruction count}=\frac{\text{Cycles}}{\text{CPI}}.
\]

#### For \(P1\)

\[
\text{Cycles}_{P1}=3\times 10^9 \times 10 = 30\times 10^9
\]

\[
\text{Instructions}_{P1}=\frac{30\times 10^9}{1.5}=20\times 10^9
\]

So,

\[
\boxed{P1:\ 30\times 10^9 \text{ cycles},\ 20\times 10^9 \text{ instructions}}
\]

#### For \(P2\)

\[
\text{Cycles}_{P2}=2.5\times 10^9 \times 10 = 25\times 10^9
\]

\[
\text{Instructions}_{P2}=\frac{25\times 10^9}{1.0}=25\times 10^9
\]

So,

\[
\boxed{P2:\ 25\times 10^9 \text{ cycles},\ 25\times 10^9 \text{ instructions}}
\]

#### For \(P3\)

\[
\text{Cycles}_{P3}=4.0\times 10^9 \times 10 = 40\times 10^9
\]

\[
\text{Instructions}_{P3}=\frac{40\times 10^9}{2.2}\approx 18.18\times 10^9
\]

So,

\[
\boxed{P3:\ 40\times 10^9 \text{ cycles},\ 18.18\times 10^9 \text{ instructions}}
\]

---

### 1.5(c) New clock rate after a 30% time reduction and a 20% CPI increase

Execution time is

\[
T=\frac{I\cdot \text{CPI}}{f}.
\]

We want a 30% reduction in execution time, so

\[
T_{\text{new}}=0.7\,T_{\text{old}}.
\]

The CPI increases by 20%, so

\[
\text{CPI}_{\text{new}}=1.2\,\text{CPI}_{\text{old}}.
\]

Thus,

\[
\frac{I\cdot 1.2\,\text{CPI}_{\text{old}}}{f_{\text{new}}}
=
0.7\cdot
\frac{I\cdot \text{CPI}_{\text{old}}}{f_{\text{old}}}.
\]

Canceling \(I\) and \(\text{CPI}_{\text{old}}\),

\[
\frac{1.2}{f_{\text{new}}}=\frac{0.7}{f_{\text{old}}}
\]

so

\[
f_{\text{new}}=\frac{1.2}{0.7}f_{\text{old}}=\frac{12}{7}f_{\text{old}}\approx 1.7143\,f_{\text{old}}.
\]

Therefore, the required clock rate is

\[
\boxed{f_{\text{new}}=\frac{12}{7}f_{\text{old}}\approx 1.7143\,f_{\text{old}}.}
\]

If applied to each processor:

\[
P1:\ 3\times \frac{12}{7}\approx \boxed{5.14\ \text{GHz}}
\]

\[
P2:\ 2.5\times \frac{12}{7}\approx \boxed{4.29\ \text{GHz}}
\]

\[
P3:\ 4.0\times \frac{12}{7}\approx \boxed{6.86\ \text{GHz}}
\]

## Question 2 (Textbook 3.11)

**AI-answer check.** No AI-generated answer for Q2 was shown in the prompt/images, so I do not claim any specific critique points here. Below is the correct worked solution.

We are adding two **unsigned 8-bit integers** using **saturating arithmetic**:

\[
151 + 214 = 365.
\]

For an unsigned 8-bit integer, the representable range is

\[
0 \le x \le 255.
\]

Since

\[
365 > 255,
\]

the result saturates to the maximum unsigned 8-bit value:

\[
\boxed{255}.
\]

### Final answer

\[
\boxed{151 + 214 = 255 \text{ (with unsigned 8-bit saturating arithmetic)}}
\]

## Question 3 (Textbook 3.12)

**AI-answer check.** No AI-generated answer for Q3 was shown in the prompt/images, so I do not claim any specific critique points here. Below is the correct worked solution.

We use the multiplication hardware of Figure 3.3, scaled to 6-bit operands:

- Multiplicand \(=62_8=110010_2\)
- Multiplier \(=12_8=001010_2\)

Since the operands are 6-bit, we use:

- a 12-bit Multiplicand register,
- a 6-bit Multiplier register,
- a 12-bit Product register.

The 6-bit multiplicand is initially placed in the **right half** of the 12-bit Multiplicand register.

So the initial register contents are:

\[
\text{Multiplier}=001010
\]

\[
\text{Multiplicand}=000000\ 110010
\]

\[
\text{Product}=000000\ 000000
\]

### Step-by-step table

| Iteration | Step                                              | Multiplier |    Multiplicand |         Product |
| --------- | ------------------------------------------------- | ---------: | --------------: | --------------: |
| 0         | Initial values                                    |   `001010` | `000000 110010` | `000000 000000` |
| 1         | 1: \(Q_0=0\) \(\Rightarrow\) No operation         |   `001010` | `000000 110010` | `000000 000000` |
| 1         | 2: Shift left Multiplicand                        |   `001010` | `000001 100100` | `000000 000000` |
| 1         | 3: Shift right Multiplier                         |   `000101` | `000001 100100` | `000000 000000` |
| 2         | 1a: \(Q_0=1\) \(\Rightarrow\) Prod = Prod + Mcand |   `000101` | `000001 100100` | `000001 100100` |
| 2         | 2: Shift left Multiplicand                        |   `000101` | `000011 001000` | `000001 100100` |
| 2         | 3: Shift right Multiplier                         |   `000010` | `000011 001000` | `000001 100100` |
| 3         | 1: \(Q_0=0\) \(\Rightarrow\) No operation         |   `000010` | `000011 001000` | `000001 100100` |
| 3         | 2: Shift left Multiplicand                        |   `000010` | `000110 010000` | `000001 100100` |
| 3         | 3: Shift right Multiplier                         |   `000001` | `000110 010000` | `000001 100100` |
| 4         | 1a: \(Q_0=1\) \(\Rightarrow\) Prod = Prod + Mcand |   `000001` | `000110 010000` | `000111 110100` |
| 4         | 2: Shift left Multiplicand                        |   `000001` | `001100 100000` | `000111 110100` |
| 4         | 3: Shift right Multiplier                         |   `000000` | `001100 100000` | `000111 110100` |
| 5         | 1: \(Q_0=0\) \(\Rightarrow\) No operation         |   `000000` | `001100 100000` | `000111 110100` |
| 5         | 2: Shift left Multiplicand                        |   `000000` | `011001 000000` | `000111 110100` |
| 5         | 3: Shift right Multiplier                         |   `000000` | `011001 000000` | `000111 110100` |
| 6         | 1: \(Q_0=0\) \(\Rightarrow\) No operation         |   `000000` | `011001 000000` | `000111 110100` |
| 6         | 2: Shift left Multiplicand                        |   `000000` | `110010 000000` | `000111 110100` |
| 6         | 3: Shift right Multiplier                         |   `000000` | `110010 000000` | `000111 110100` |

### Final product

The final Product register is

\[
000111110100_2.
\]

In decimal,

\[
000111110100_2 = 500_{10}.
\]

In octal,

\[
500_{10}=764_8.
\]

Therefore,

\[
\boxed{62_8 \times 12_8 = 764_8.}
\]

## Question 4 (Textbook 3.18)

**AI-answer check.** No AI-generated answer for Q4 was shown in the prompt/images, so I do not claim any specific critique points here. Below is the correct worked solution.

We use the division hardware of Figure 3.8, scaled to 6-bit operands:

- Dividend \(=74_8=111100_2=60_{10}\)
- Divisor \(=21_8=010001_2=17_{10}\)

Since the inputs are 6-bit, we use:

- a 6-bit Quotient register,
- a 12-bit Divisor register,
- a 12-bit Remainder register.

The divisor is placed in the **left half** of the 12-bit Divisor register:

\[
\text{Divisor register initial} = 010001\ 000000
\]

The dividend is placed in the **right half** of the 12-bit Remainder register:

\[
\text{Remainder register initial} = 000000\ 111100
\]

\[
\text{Quotient initial} = 000000
\]

As in Figure 3.10, the subtraction result in Step 1 is shown directly in the 12-bit Remainder register, even when it is negative (that is, in 12-bit two's complement form).

### Step-by-step table

| Iteration | Step                                                  | Quotient |         Divisor |       Remainder |
| --------- | ----------------------------------------------------- | -------: | --------------: | --------------: |
| 0         | Initial values                                        | `000000` | `010001 000000` | `000000 111100` |
| 1         | 1: Rem = Rem \(-\) Div                                | `000000` | `010001 000000` | `101111 111100` |
| 1         | 2b: Rem \(<0\) \(\Rightarrow\) +Div, SLL Q, \(Q_0=0\) | `000000` | `010001 000000` | `000000 111100` |
| 1         | 3: Shift Div right                                    | `000000` | `001000 100000` | `000000 111100` |
| 2         | 1: Rem = Rem \(-\) Div                                | `000000` | `001000 100000` | `111000 011100` |
| 2         | 2b: Rem \(<0\) \(\Rightarrow\) +Div, SLL Q, \(Q_0=0\) | `000000` | `001000 100000` | `000000 111100` |
| 2         | 3: Shift Div right                                    | `000000` | `000100 010000` | `000000 111100` |
| 3         | 1: Rem = Rem \(-\) Div                                | `000000` | `000100 010000` | `111100 101100` |
| 3         | 2b: Rem \(<0\) \(\Rightarrow\) +Div, SLL Q, \(Q_0=0\) | `000000` | `000100 010000` | `000000 111100` |
| 3         | 3: Shift Div right                                    | `000000` | `000010 001000` | `000000 111100` |
| 4         | 1: Rem = Rem \(-\) Div                                | `000000` | `000010 001000` | `111110 110100` |
| 4         | 2b: Rem \(<0\) \(\Rightarrow\) +Div, SLL Q, \(Q_0=0\) | `000000` | `000010 001000` | `000000 111100` |
| 4         | 3: Shift Div right                                    | `000000` | `000001 000100` | `000000 111100` |
| 5         | 1: Rem = Rem \(-\) Div                                | `000000` | `000001 000100` | `111111 111000` |
| 5         | 2b: Rem \(<0\) \(\Rightarrow\) +Div, SLL Q, \(Q_0=0\) | `000000` | `000001 000100` | `000000 111100` |
| 5         | 3: Shift Div right                                    | `000000` | `000000 100010` | `000000 111100` |
| 6         | 1: Rem = Rem \(-\) Div                                | `000000` | `000000 100010` | `000000 011010` |
| 6         | 2a: Rem \(\ge 0\) \(\Rightarrow\) SLL Q, \(Q_0=1\)    | `000001` | `000000 100010` | `000000 011010` |
| 6         | 3: Shift Div right                                    | `000001` | `000000 010001` | `000000 011010` |
| 7         | 1: Rem = Rem \(-\) Div                                | `000001` | `000000 010001` | `000000 001001` |
| 7         | 2a: Rem \(\ge 0\) \(\Rightarrow\) SLL Q, \(Q_0=1\)    | `000011` | `000000 010001` | `000000 001001` |
| 7         | 3: Shift Div right                                    | `000011` | `000000 001000` | `000000 001001` |

### Final result

Final Quotient register:

\[
000011_2 = 3_{10} = 3_8
\]

Final Remainder register:

\[
000000001001_2 = 9_{10} = 11_8
\]

Therefore,

\[
\boxed{74_8 \div 21_8 = 3_8 \text{ remainder } 11_8.}
\]

## Question 5 (Textbook 3.20)

**AI-answer check.** No AI-generated answer for Q5 was shown in the prompt/images, so I do not claim any specific critique points here. Below is the correct worked solution.

The bit pattern is

\[
0x0C000000.
\]

In binary,

\[
0x0C000000 = 00001100\,00000000\,00000000\,00000000_2.
\]

### As an unsigned 32-bit integer

\[
0x0C000000 = 12 \times 16^6 = 12 \times 16{,}777{,}216 = 201{,}326{,}592.
\]

So, as an unsigned integer,

\[
\boxed{201{,}326{,}592}.
\]

### As a 32-bit two's complement integer

The most significant bit is \(0\), so the value is nonnegative. Therefore, the two's complement interpretation is the same as the unsigned interpretation:

\[
\boxed{201{,}326{,}592}.
\]

### Final answer

\[
\boxed{\text{two's complement integer: } 201{,}326{,}592}
\]

\[
\boxed{\text{unsigned integer: } 201{,}326{,}592}
\]

## Question 6 (Textbook 3.23)

We are asked to write the IEEE 754 single-precision representation of \(63.25\).

### AI-answer critique

The provided AI answer is:

\[
63.25 = 111111.01_2 = 1.1111101_2 \times 2^6
\]

with

- sign \(=0\)
- exponent \(=6+127=133=10000101_2\)
- fraction \(=11111101000000000000000\)

and final result

\[
0\ 10000101\ 11111101000000000000000
\]

#### What is correct in the AI answer

- The binary conversion
  \[
  63.25 = 111111.01_2
  \]
  is correct.
- The sign bit \(=0\) is also correct, since the number is positive.

#### Errors in the AI answer

1. **Wrong normalization exponent.**

   The correct normalization is

   \[
   111111.01_2 = 1.1111101_2 \times 2^5,
   \]

   not \(2^6\).

   The binary point moves **5** places to the left, not 6.

2. **Wrong exponent field.**

   Since the true exponent is \(5\), the biased exponent is

   \[
   5+127=132,
   \]

   so the exponent field should be

   \[
   132 = 10000100_2,
   \]

   not \(10000101_2\).

3. **Wrong fraction field.**

   After correct normalization,

   \[
   1.1111101_2 \times 2^5,
   \]

   the fraction field is the part after the leading implicit \(1\), namely

   \[
   1111101
   \]

   padded with zeros to 23 bits:

   \[
   11111010000000000000000.
   \]

   The AI answer wrote

   \[
   11111101000000000000000,
   \]

   which corresponds to the wrong normalization.

---

### Correct solution

\[
63.25_{10}=111111.01_2
\]

Normalize:

\[
111111.01_2 = 1.1111101_2 \times 2^5
\]

So:

- sign bit:
  \[
  \boxed{0}
  \]

- exponent:
  \[
  5+127=132=10000100_2
  \]

- fraction:
  \[
  11111010000000000000000
  \]

Therefore the IEEE 754 single-precision bit pattern is

\[
\boxed{0\ 10000100\ 11111010000000000000000}
\]

or, as 32 bits,

\[
\boxed{01000010011111010000000000000000}
\]

and in hexadecimal,

\[
\boxed{0x427D0000}.
\]


## Q.1

Performance = Instructions/second = Clock Rate / CPI

P1: 3.0 × 10⁹ / 1.5 = 2.0   × 10⁹  instructions/sec
P2: 2.5 × 10⁹ / 1.0 = 2.5   × 10⁹  instructions/sec
P3: 4.0 × 10⁹ / 2.2 ≈ 1.818 × 10⁹  instructions/sec

★ P2 has the highest performance at 2.5 × 10⁹ instructions/sec.

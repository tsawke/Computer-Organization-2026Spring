# CO - Theoretical Assignment-II

## Q1

### 1.5(a):

$$
\text{IPS} = \frac{\text{Clock Rate}}{\text{CPI}}
$$

$$
\text{IPS}_{P1} = \frac{3.0 \times 10^9}{1.5} = 2.0 \times 10^9 \text{ instructions/sec}
$$

$$
\text{IPS}_{P2} = \frac{2.5 \times 10^9}{1.0} = 2.5 \times 10^9 \text{ instructions/sec}
$$

$$
\text{IPS}_{P3} = \frac{4.0 \times 10^9}{2.2} \approx 1.818 \times 10^9 \text{ instructions/sec}
$$

$$
\boxed{\text{P2 has the highest performance at } 2.5 \times 10^9 \text{ instructions/sec.}}
$$

### 1.5(b):

$$
\text{Cycles} = \text{Clock Rate} \times \text{Time}, \quad \text{Instructions} = \frac{\text{Cycles}}{\text{CPI}}
$$

**P1:**
$$
\text{Cycles}_{P1} = 3.0 \times 10^9 \times 10 = 30 \times 10^9
$$

$$
\text{Instructions}_{P1} = \frac{30 \times 10^9}{1.5} = 20 \times 10^9
$$

**P2:**

$$
\text{Cycles}_{P2} = 2.5 \times 10^9 \times 10 = 25 \times 10^9
$$

$$
\text{Instructions}_{P2} = \frac{25 \times 10^9}{1.0} = 25 \times 10^9
$$

**P3:**

$$
\text{Cycles}_{P3} = 4.0 \times 10^9 \times 10 = 40 \times 10^9
$$

$$
\text{Instructions}_{P3} = \frac{40 \times 10^9}{2.2} \approx 18.18 \times 10^9
$$

### 1.5(c):

$$
T_{\text{new}} = 0.7 \times 10 = 7 \text{ s}, \quad \text{CPI}_{\text{new}} = 1.2 \times \text{CPI}_{\text{old}}
$$

$$
\text{Clock Rate}_{\text{new}} = \frac{\text{Instructions} \times \text{CPI}_{\text{new}}}{T_{\text{new}}}
$$

**P1:**

$$
\text{CPI}_{\text{new}} = 1.2 \times 1.5 = 1.8
$$

$$
\text{Clock}_{P1} = \frac{20 \times 10^9 \times 1.8}{7} = \frac{36 \times 10^9}{7} \approx \boxed{5.14 \text{ GHz}}
$$

**P2:**

$$
\text{CPI}_{\text{new}} = 1.2 \times 1.0 = 1.2
$$

$$
\text{Clock}_{P2} = \frac{25 \times 10^9 \times 1.2}{7} = \frac{30 \times 10^9}{7} \approx \boxed{4.29 \text{ GHz}}
$$

**P3:**

$$
\text{CPI}_{\text{new}} = 1.2 \times 2.2 = 2.64
$$

$$
\text{Clock}_{P3} = \frac{18.18 \times 10^9 \times 2.64}{7} \approx \frac{48 \times 10^9}{7} \approx \boxed{6.86 \text{ GHz}}
$$

## Q2

$$
151 + 214 = 365
$$

$$
\text{Max unsigned 8-bit value} = 2^8 - 1 = 255
$$

$$
365 > 255 \implies \text{overflow}
$$

In saturating arithmetic, overflow clamps to the maximum representable value:

$$
\boxed{\text{Result} = 255}
$$

## Q3

$$
\text{Multiplicand} = 62_8 = 110010_2 \quad (50_{10})
$$

$$
\text{Multiplier} = 12_8 = 001010_2 \quad (10_{10})
$$

$$
\text{Expected product} = 50 \times 10 = 500 = 764_8
$$

Hardware registers (6-bit version of Figure 3.3):

- Multiplicand register: 12 bits (6-bit value in right half, shifts left)
- Multiplier register: 6 bits (shifts right)
- Product register: 12 bits (initialized to 0)

| Iter |             Step             | Multiplier | Multiplicand  |    Product    |
| :--: | :--------------------------: | :--------: | :-----------: | :-----------: |
|  0   |        Initial values        |   001010   | 000000 110010 | 000000 000000 |
|  1   |     1: 0 => No operation     |   001010   | 000000 110010 | 000000 000000 |
|      |  2: Shift left Multiplicand  |   001010   | 000001 100100 | 000000 000000 |
|      |  3: Shift right Multiplier   |   000101   | 000001 100100 | 000000 000000 |
|  2   | 1a: 1 => Prod = Prod + Mcand |   000101   | 000001 100100 | 000001 100100 |
|      |  2: Shift left Multiplicand  |   000101   | 000011 001000 | 000001 100100 |
|      |  3: Shift right Multiplier   |   000010   | 000011 001000 | 000001 100100 |
|  3   |     1: 0 => No operation     |   000010   | 000011 001000 | 000001 100100 |
|      |  2: Shift left Multiplicand  |   000010   | 000110 010000 | 000001 100100 |
|      |  3: Shift right Multiplier   |   000001   | 000110 010000 | 000001 100100 |
|  4   | 1a: 1 => Prod = Prod + Mcand |   000001   | 000110 010000 | 000111 110100 |
|      |  2: Shift left Multiplicand  |   000001   | 001100 100000 | 000111 110100 |
|      |  3: Shift right Multiplier   |   000000   | 001100 100000 | 000111 110100 |
|  5   |     1: 0 => No operation     |   000000   | 001100 100000 | 000111 110100 |
|      |  2: Shift left Multiplicand  |   000000   | 011001 000000 | 000111 110100 |
|      |  3: Shift right Multiplier   |   000000   | 011001 000000 | 000111 110100 |
|  6   |     1: 0 => No operation     |   000000   | 011001 000000 | 000111 110100 |
|      |  2: Shift left Multiplicand  |   000000   | 110010 000000 | 000111 110100 |
|      |  3: Shift right Multiplier   |   000000   | 110010 000000 | 000111 110100 |

$$
\text{Product} = 000111110100_2 = 0764_8 = 500_{10}
$$

**Verification:**

$$
000111110100_2 = 2^8 + 2^7 + 2^6 + 2^5 + 2^4 + 2^2 = 256 + 128 + 64 + 32 + 16 + 4 = 500 \; \checkmark
$$

---

## Q4

$$
\text{Dividend} = 74_8 = 111100_2 \quad (60_{10})
$$

$$
\text{Divisor} = 21_8 = 010001_2 \quad (17_{10})
$$

$$
\text{Expected: } 60 \div 17 = 3 \text{ remainder } 9 \quad \Rightarrow \quad Q = 3_8,\; R = 11_8
$$

Hardware registers (6-bit version of Figure 3.8):

- Divisor register: 12 bits (6-bit divisor in left half, shifts right)
- Quotient register: 6 bits (shifts left)
- Remainder register: 12 bits (initialized with dividend)
- Number of iterations: $n + 1 = 7$

| Iter |                Step                | Quotient |    Divisor    |   Remainder   |
| :--: | :--------------------------------: | :------: | :-----------: | :-----------: |
|  0   |           Initial values           |  000000  | 010001 000000 | 000000 111100 |
|  1   |         1: Rem = Rem - Div         |  000000  | 010001 000000 |  (negative)   |
|      |  2b: Rem < 0 => +Div, SLL Q, Q0=0  |  000000  | 010001 000000 | 000000 111100 |
|      |         3: Shift Div right         |  000000  | 001000 100000 | 000000 111100 |
|  2   |         1: Rem = Rem - Div         |  000000  | 001000 100000 |  (negative)   |
|      |  2b: Rem < 0 => +Div, SLL Q, Q0=0  |  000000  | 001000 100000 | 000000 111100 |
|      |         3: Shift Div right         |  000000  | 000100 010000 | 000000 111100 |
|  3   |         1: Rem = Rem - Div         |  000000  | 000100 010000 |  (negative)   |
|      |  2b: Rem < 0 => +Div, SLL Q, Q0=0  |  000000  | 000100 010000 | 000000 111100 |
|      |         3: Shift Div right         |  000000  | 000010 001000 | 000000 111100 |
|  4   |         1: Rem = Rem - Div         |  000000  | 000010 001000 |  (negative)   |
|      |  2b: Rem < 0 => +Div, SLL Q, Q0=0  |  000000  | 000010 001000 | 000000 111100 |
|      |         3: Shift Div right         |  000000  | 000001 000100 | 000000 111100 |
|  5   |   1: Rem = Rem - Div (60-68 < 0)   |  000000  | 000001 000100 |  (negative)   |
|      |  2b: Rem < 0 => +Div, SLL Q, Q0=0  |  000000  | 000001 000100 | 000000 111100 |
|      |         3: Shift Div right         |  000000  | 000000 100010 | 000000 111100 |
|  6   | 1: Rem = Rem - Div (60-34=26 >= 0) |  000000  | 000000 100010 | 000000 011010 |
|      |    2a: Rem >= 0 => SLL Q, Q0=1     |  000001  | 000000 100010 | 000000 011010 |
|      |         3: Shift Div right         |  000001  | 000000 010001 | 000000 011010 |
|  7   | 1: Rem = Rem - Div (26-17=9 >= 0)  |  000001  | 000000 010001 | 000000 001001 |
|      |    2a: Rem >= 0 => SLL Q, Q0=1     |  000011  | 000000 010001 | 000000 001001 |
|      |         3: Shift Div right         |  000011  | 000000 001000 | 000000 001001 |

$$
\text{Quotient} = 000011_2 = 3_{10} = 3_8
$$

$$
\text{Remainder} = 000000\;001001_2 = 9_{10} = 11_8
$$

**Verification:**

$$
17 \times 3 + 9 = 51 + 9 = 60 = 74_8 \; \checkmark
$$

---

## Q5

$$
\texttt{0x0C000000} = 0000\;1100\;0000\;0000\;0000\;0000\;0000\;0000_2
$$

**2's complement:**
$$
\text{MSB (sign bit)} = 0 \implies \text{positive}
$$

$$
\text{Value} = 2^{27} + 2^{26} = 134{,}217{,}728 + 67{,}108{,}864 = \boxed{201{,}326{,}592}
$$

**Unsigned:**

Since the MSB is 0, the unsigned value is identical:

$$
\boxed{201{,}326{,}592}
$$

---

## Q6

### Error Analysis:

**Error 1: Wrong exponent in normalization.**
$$
63.25_{10} = 111111.01_2 \quad \text{(correct)}
$$

To normalize, the binary point moves **5** positions to the left (from after bit position 6 to after bit position 1):

$$
111111.01_2 = 1.1111101_2 \times 2^{\mathbf{5}} \quad \text{(correct)}
$$

$$
\text{AI wrote: } 1.1111101_2 \times 2^{\mathbf{6}} \quad \leftarrow \textbf{WRONG}
$$

**Error 2 (consequence of Error 1): Wrong biased exponent.**

$$
\text{Correct: } e = 5 + 127 = 132 = 10000100_2
$$

$$
\text{AI says: } e = 6 + 127 = 133 = 10000101_2 \quad \leftarrow \textbf{WRONG}
$$

**Error 3: Wrong fraction field.**

The mantissa is $1.1111101_2$. The fraction field stores only the bits after the implicit leading 1:

$$
\text{Correct fraction} = \underbrace{1111101}_{7 \text{ bits}} \underbrace{0000000000000000}_{16 \text{ zeros}} = 11111010000000000000000
$$

$$
\text{AI fraction} = \underbrace{11111101}_{8 \text{ bits}} \underbrace{000000000000000}_{15 \text{ zeros}} = 11111101000000000000000 \quad \leftarrow \textbf{WRONG}
$$

Note: even given the AI's own stated mantissa $1.1111101_2$, the fraction should begin with $1111101$ (7 bits), not $11111101$ (8 bits).

The fraction is **inconsistent with the AI's own normalization**.

### Correct Answer:

$$
63.25_{10} = 111111.01_2 = 1.1111101_2 \times 2^5
$$

$$
\text{sign} = 0
$$

$$
\text{exponent} = 5 + 127 = 132 = 10000100_2
$$

$$
\text{fraction} = 11111010000000000000000 \quad \text{(23 bits)}
$$

$$
\boxed{0 \;\; 10000100 \;\; 11111010000000000000000}
$$

**Verification:**

$$
(-1)^0 \times 1.1111101_2 \times 2^5 = 111111.01_2 = 32+16+8+4+2+1+0.25 = 63.25 \; \checkmark
$$

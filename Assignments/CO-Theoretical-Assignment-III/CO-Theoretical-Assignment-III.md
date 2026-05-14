# CO - Theoretical Assignment-III

**IMPORTANT NOTE:** In all problems below, variables and array elements are of type integer, and the ISA used is RV32.

**Common pipeline assumptions used below:**

- Five pipeline stages: IF, ID, EX, MEM, WB.
- Pipeline-register overhead is ignored unless explicitly stated.
- A register written in the WB stage can be read by another instruction in the ID stage in the same cycle.
- For Q11 and Q12, the pipeline has full forwarding support, as stated in the question.

---

## Q1

### 4.16.1:

The stage latencies are:

| Stage | IF | ID | EX | MEM | WB |
| :--: | :--: | :--: | :--: | :--: | :--: |
| Latency | 250 ps | 350 ps | 150 ps | 300 ps | 200 ps |

For a **pipelined** processor, the clock cycle time is determined by the slowest stage:

$$
T_{\text{pipelined}} = \max(250,350,150,300,200) = \boxed{350\text{ ps}}
$$

For a **non-pipelined** processor, one instruction must complete all stages in one cycle:

$$
T_{\text{non-pipelined}} = 250 + 350 + 150 + 300 + 200 = 1250\text{ ps}
$$

$$
\boxed{T_{\text{non-pipelined}} = 1250\text{ ps}}
$$

---

## Q2

### 4.16.2:

A `ld` instruction uses all five stages: IF, ID, EX, MEM, and WB.

For the **pipelined** processor:

$$
\text{Latency}_{\text{pipelined}} = 5 \times T_{\text{pipelined}}
$$

$$
\text{Latency}_{\text{pipelined}} = 5 \times 350 = \boxed{1750\text{ ps}}
$$

For the **non-pipelined** processor, the load completes in one full non-pipelined cycle:

$$
\text{Latency}_{\text{non-pipelined}} = 1250\text{ ps}
$$

$$
\boxed{\text{Latency}_{\text{non-pipelined}} = 1250\text{ ps}}
$$

Notice that pipelining improves throughput, but the latency of a single load instruction is not necessarily smaller.

---

## Q3

### 4.16.3:

To reduce the pipelined clock cycle time, we should split the stage with the largest latency.

The largest stage latency is:

$$
ID = 350\text{ ps}
$$

If the ID stage is split into two equal stages:

$$
ID_1 = ID_2 = \frac{350}{2} = 175\text{ ps}
$$

The new stage latencies become:

| Stage | IF | ID1 | ID2 | EX | MEM | WB |
| :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| Latency | 250 ps | 175 ps | 175 ps | 150 ps | 300 ps | 200 ps |

The new clock cycle time is determined by the new slowest stage:

$$
T_{\text{new}} = \max(250,175,175,150,300,200) = \boxed{300\text{ ps}}
$$

$$
\boxed{\text{Split the ID stage, and the new clock cycle time is }300\text{ ps}.}
$$

---

## Q4

### 4.16.4:

The data memory is used only by instructions that access memory data:

- `Load` instructions use data memory.
- `Store` instructions use data memory.

Given instruction mix:

| Instruction Type | ALU/Logic | Jump/Branch | Load | Store |
| :--: | :--: | :--: | :--: | :--: |
| Percentage | 45% | 20% | 20% | 15% |

Therefore, utilization of the data memory is:

$$
\text{Data memory utilization} = 20\% + 15\% = \boxed{35\%}
$$

---

## Q5

### 4.16.5:

The write-register port of the `Registers` unit is used by instructions that write a value back to a register.

- `ALU/Logic` instructions write to a register.
- `Load` instructions write to a register.
- `Store` instructions do not write to a register.
- `Jump/Branch` instructions are assumed not to write to a register in this simplified mix.

Thus:

$$
\text{Register write-port utilization} = 45\% + 20\% = \boxed{65\%}
$$

---

## Q6

### 4.20:

Given code:

```asm
addi    x11, x12, 5
add     x13, x11, x12
addi    x14, x11, 15
add     x15, x13, x12
```

The pipeline does not handle data hazards, so NOPs must be inserted so that a consumer instruction does not read a register before the producer has written it back.

`addi x11, x12, 5` produces `x11`.

Both of the following instructions use `x11`:

```asm
add     x13, x11, x12
addi    x14, x11, 15
```

The immediately following `add` needs two NOPs after the `addi`.

Also, `add x13, x11, x12` produces `x13`, and the final instruction uses `x13`:

```asm
add     x15, x13, x12
```

There is already one independent instruction between them, so one more NOP is needed.

Correct code:

```asm
addi    x11, x12, 5
nop
nop
add     x13, x11, x12
addi    x14, x11, 15
nop
add     x15, x13, x12
```

$$
\boxed{\text{Total NOPs inserted} = 3}
$$

---

## Q7

### 4.22.1:

Code fragment:

```asm
sd      x29, 12(x16)
ld      x29, 8(x16)
sub     x17, x15, x14
beqz    x17, label
add     x15, x11, x14
sub     x15, x30, x14
```

With only one memory shared by instruction fetches and data accesses, a structural hazard occurs whenever a load or store is in the MEM stage while another instruction needs the IF stage.

The `sd` instruction accesses data memory in cycle 4, and the `ld` instruction accesses data memory in cycle 5. Therefore, instruction fetch must stall in cycles 4 and 5.

| Instruction | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| :-- | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| `sd x29, 12(x16)` | IF | ID | EX | MEM(D) | WB* |  |  |  |  |  |  |  |
| `ld x29, 8(x16)` |  | IF | ID | EX | MEM(D) | WB |  |  |  |  |  |  |
| `sub x17, x15, x14` |  |  | IF | ID | EX | MEM | WB |  |  |  |  |  |
| **IF structural stall** |  |  |  | **Stall** | **Stall** |  |  |  |  |  |  |  |
| `beqz x17, label` |  |  |  |  |  | IF | ID | EX | MEM* | WB* |  |  |
| `add x15, x11, x14` |  |  |  |  |  |  | IF | ID | EX | MEM* | WB |  |
| `sub x15, x30, x14` |  |  |  |  |  |  |  | IF | ID | EX | MEM* | WB |

`MEM(D)` means the data memory is actually accessed. The starred stages are pipeline slots that do not perform useful work for that instruction.

$$
\boxed{\text{The structural hazard creates two IF stalls, in cycles 4 and 5.}}
$$

---

## Q8

### 4.22.2:

In general, reordering code cannot remove this structural hazard.

The reason is that the hazard is caused by a hardware resource conflict:

$$
\text{Instruction fetch needs memory at the same time that a load/store needs data memory.}
$$

Every `ld` or `sd` instruction must access data memory in its MEM stage. Since the processor has only one memory, that memory cannot also be used for instruction fetch in the same cycle.

So, in a long-running program, each load or store will still tend to cause one lost fetch cycle regardless of where it is placed.

$$
\boxed{\text{No, reordering cannot generally reduce these structural stalls.}}
$$

A compiler might hide a stall only in a special case, such as when the program was already stalled for another reason, but reordering alone does not solve the memory conflict.

---

## Q9

### 4.22.3:

Yes, this structural hazard must be handled in hardware, unless the design avoids it by using separate instruction and data memories/caches.

For data hazards, NOPs can help because they delay the consumer instruction until the producer has written the needed value.

However, for this structural hazard, inserting a NOP does not solve the problem because a NOP is still an instruction and must still be fetched from memory.

So inserting NOPs only adds more instruction fetches; it does not remove the conflict between:

$$
\text{IF memory access} \quad \text{and} \quad \text{MEM-stage data access}
$$

Therefore, the processor must handle this by hardware stalling/arbitration or by changing the memory organization.

$$
\boxed{\text{NOPs cannot eliminate this structural hazard; it must be handled by hardware/design.}}
$$

---

## Q10

### 4.22.4:

Using the instruction mix from Exercise 4.8:

| Instruction Type | R-type/I-type non-ld | `ld` | `sd` | `beq` |
| :--: | :--: | :--: | :--: | :--: |
| Percentage | 52% | 25% | 11% | 12% |

The structural hazard occurs for instructions that access data memory:

$$
\text{Memory-access instructions} = ld + sd
$$

$$
= 25\% + 11\% = 36\%
$$

Each load or store creates approximately one structural stall because its MEM-stage data access conflicts with instruction fetch.

Therefore:

$$
\text{Stalls per instruction} \approx 0.36
$$

For every 100 instructions:

$$
\text{Stalls} \approx 36
$$

The approximate CPI becomes:

$$
\text{CPI} \approx 1 + 0.36 = \boxed{1.36}
$$

$$
\boxed{\text{Approximately 36 stalls per 100 instructions, or }0.36\text{ stalls/instruction.}}
$$

---

## Q11

### 4.25.1:

Loop:

```asm
LOOP:   ld      x10, 0(x13)
        ld      x11, 8(x13)
        add     x12, x10, x11
        subi    x13, x13, 16
        bnez    x12, LOOP
```

The pipeline has full forwarding, so most data hazards can be handled by forwarding.

However, there is a load-use hazard between:

```asm
ld      x11, 8(x13)
add     x12, x10, x11
```

The value loaded into `x11` is not available early enough for the immediately following `add`, so one stall cycle is needed in each iteration.

Perfect branch prediction is used, so there are no stalls due to control hazards. The next iteration can be fetched immediately after the predicted branch.

Pipeline execution diagram for the first two iterations:

| Instruction | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
| :-- | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| `ld x10, 0(x13)` [1] | IF | ID | EX | MEM | WB |  |  |  |  |  |  |  |  |  |  |  |
| `ld x11, 8(x13)` [1] |  | IF | ID | EX | MEM | WB |  |  |  |  |  |  |  |  |  |  |
| `add x12, x10, x11` [1] |  |  | IF | ID | ID(stall) | EX | MEM | WB |  |  |  |  |  |  |  |  |
| `subi x13, x13, 16` [1] |  |  |  | IF | IF(stall) | ID | EX | MEM | WB |  |  |  |  |  |  |  |
| `bnez x12, LOOP` [1] |  |  |  |  |  | IF | ID | EX | MEM | WB |  |  |  |  |  |  |
| `ld x10, 0(x13)` [2] |  |  |  |  |  |  | IF | ID | EX | MEM | WB |  |  |  |  |  |
| `ld x11, 8(x13)` [2] |  |  |  |  |  |  |  | IF | ID | EX | MEM | WB |  |  |  |  |
| `add x12, x10, x11` [2] |  |  |  |  |  |  |  |  | IF | ID | ID(stall) | EX | MEM | WB |  |  |
| `subi x13, x13, 16` [2] |  |  |  |  |  |  |  |  |  | IF | IF(stall) | ID | EX | MEM | WB |  |
| `bnez x12, LOOP` [2] |  |  |  |  |  |  |  |  |  |  |  | IF | ID | EX | MEM | WB |

The repeated `ID(stall)` and `IF(stall)` entries show the one-cycle load-use stall in each iteration.

$$
\boxed{\text{There is one load-use stall per loop iteration.}}
$$

---

## Q12

### 4.25.2:

We mark pipeline stages that do not perform useful work.

For this loop:

- `ld` uses IF, ID, EX, MEM, and WB usefully.
- `add` and `subi` use IF, ID, EX, and WB usefully, but their MEM stage does not access data memory.
- `bnez` uses IF, ID, and EX usefully, but its MEM and WB stages do not perform useful work.
- Stall/held stages and bubbles do not perform useful work.

Using the steady-state portion of the diagram from Q11, begin with the cycle in which `subi` from the second iteration is in IF and end with the cycle in which `bnez` from the second iteration is in IF.

That corresponds to cycles 10 through 12:

| Cycle | IF | ID | EX | MEM | WB | Are all 5 stages useful? |
| :--: | :-- | :-- | :-- | :-- | :-- | :--: |
| 10 | `subi` [2] IF | `add` [2] ID | `ld x11` [2] EX | `ld x10` [2] MEM | `bnez` [1] WB* | No |
| 11 | `subi` [2] IF(stall)* | `add` [2] ID(stall)* | Bubble* | `ld x11` [2] MEM | `ld x10` [2] WB | No |
| 12 | `bnez` [2] IF | `subi` [2] ID | `add` [2] EX | Bubble* | `ld x11` [2] WB | No |

`*` marks a stage that does not perform useful work.

There are 3 cycles in this steady-state interval, and none of them have all five stages doing useful work.

$$
\text{Cycles with all 5 stages useful} = 0
$$

$$
\text{Fraction} = \frac{0}{3} = \boxed{0\%}
$$

$$
\boxed{\text{While the pipeline is full in this interval, all five stages are never useful at the same time.}}
$$

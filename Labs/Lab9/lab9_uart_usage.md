# Lab9 UART Batch/PowerShell Usage

Run these commands from `Labs/Lab9`.

## 1. List COM Ports

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\lab9_list_ports.ps1
```

Use the COM port that belongs to the EGO1 UART/JTAG device.

## 2. Program Bitstream

If `vivado` is in `PATH`, run:

```bat
program_tailored_cpu.bat
```

Otherwise, program `TailoredCPU_onlyX1writtable.bit` once in Vivado Hardware Manager.

## 3. Practice 1

```bat
lab9_practice1_uart.bat COM3
```

Replace `COM3` with your EGO1 port. After the script finishes, toggle the switches. The LEDs should show only the low 4 bits.

## 4. Practice 2

```bat
lab9_practice2_uart.bat COM3
```

This loads `case0_test(onlyX1writtable_casebase_4000).txt`, writes each dataset item from `lab9_practice2_srai_dataset.txt`, runs the CPU, reads back the result from data memory, and prints PASS/FAIL.

## Direct PowerShell Examples

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\lab9_uart_test.ps1 -Port COM3 -Mode Ping
powershell -NoProfile -ExecutionPolicy Bypass -File .\lab9_uart_test.ps1 -Port COM3 -Mode Practice1
powershell -NoProfile -ExecutionPolicy Bypass -File .\lab9_uart_test.ps1 -Port COM3 -Mode Practice2
```

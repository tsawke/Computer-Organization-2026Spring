# EGo1 Artix-7 Board CLI Self-Test

这是一套只走命令行的 EGo1 开发板自检工程。`ego1_cli.bat` 调 Vivado batch，Vivado 再执行 `scripts/ego1_vivado.tcl` 完成建工程、综合、实现、生成 bit、JTAG 下载、硬件探测和可选 SPI Flash 镜像生成。

管脚约束按 E-elements EGo1 v2.2 用户手册整理：FPGA 为 `XC7A35T-1CSG324C`，系统时钟为 `P17/100MHz`，板载外设包括按钮、开关、LED、8 位数码管、VGA、音频 PWM、USB-UART/JTAG、PS/2、SRAM、XADC 模拟输入、DAC、蓝牙和 32 位扩展 IO。

## 快速使用

在 Windows 命令行或 PowerShell 里进入本目录后运行：

```bat
ego1_cli.bat build
ego1_cli.bat program
```

也可以一条命令完成构建和下载：

```bat
ego1_cli.bat all
```

其他命令：

```bat
ego1_cli.bat probe   :: 只用 Vivado CLI 探测 JTAG 设备和可用 SysMon 信息
ego1_cli.bat mcs     :: 生成 N25Q32 SPI Flash 用的 .mcs 镜像
ego1_cli.bat flash   :: 通过 JTAG 写入 SPI Flash，持久化配置，确认需要时再用
ego1_cli.bat clean   :: 删除 build 和 output
```

如果 `vivado` 不在 PATH，可以把 Vivado 的 `bin` 目录加入 PATH，或者临时设置 `VIVADO_BIN` 指向本机的 `vivado.bat`：

```bat
set VIVADO_BIN=<your-vivado-bat-path>
ego1_cli.bat all
```

## 上板检查项

| 功能 | 检查方法 |
| --- | --- |
| Vivado/JTAG | `ego1_cli.bat probe` 能找到 `xc7a35t`；`program` 后板上 DONE/配置灯应点亮。 |
| 100MHz 时钟 | LED 走马灯、VGA 图像、音频/DAC 波形持续变化。 |
| LED/开关/DIP | `SW7:SW6=00` 时，16 个 LED 直接显示 `{DIP, SW}`。 |
| 按键 | `SW7:SW6=10` 时，LED 显示 `RST`、`PB0..PB4`、UART/BT/PS2/SRAM 状态。`PB0` 是软复位，`PB1` 重新跑 SRAM 测试。 |
| 数码管 | `SW5:SW4` 选择显示页：`00` 显示开关/按键，`01` 显示 SRAM 状态和失败地址，`10` 显示 UART/BT/PS2 最近字节，`11` 显示 XADC 原始值。 |
| SRAM | 下载后自动写读前 4096 个 16-bit 地址；串口输出 `SRAM PASS` 或 `SRAM FAIL`，状态也显示在 LED/数码管。 |
| USB-UART | 串口工具打开 EGo1 USB-UART，`115200 8N1`，应看到 `EGO1 SELFTEST READY`、`ALIVE` 和 SRAM 结果；发任意字节应回显。 |
| 蓝牙 UART | 蓝牙模块默认按 `9600 8N1` 回显收到的字节，最近字节显示在数码管页 `SW5:SW4=10`。 |
| PS/2 | 接键盘或鼠标，最近扫描码显示在数码管页 `SW5:SW4=10`。 |
| VGA | 接 VGA 显示器，应看到 640x480 彩条/棋盘测试图。 |
| 音频 | `DIP0=1` 使能 PWM 音频，`SW3:SW0` 改变音高；接音频口检查。 |
| DAC | J2 DAC 输出连续锯齿波，建议用示波器或万用表检查。 |
| XADC/W1 | `SW5:SW4=11` 显示 XADC 通道 1 和片温原始值，旋转 W1 时低 12 位模拟输入值应变化。 |
| 扩展 IO | 默认高阻；仅在确认扩展口没有外接冲突电路后置 `SW7:SW6=11` 且 `DIP7=1`，J5 输出慢变化测试图案。 |

## 文件说明

- `src/ego1_board_selftest_top.v`：自检顶层和小模块，包含 UART、PS/2、SRAM 自检、VGA、音频、DAC、XADC、数码管扫描。
- `constraints/ego1_v2_2_board.xdc`：EGo1 v2.2 全板约束。
- `scripts/ego1_vivado.tcl`：Vivado batch 脚本，支持 `build/program/all/probe/mcs/flash/clean`。
- `ego1_cli.bat`：Windows 批处理入口。
- `output/ego1_board_selftest.bit`：构建后生成的 bitstream。

`build/` 和 `output/` 是 Vivado 生成目录，移动工程目录后建议先运行 `ego1_cli.bat clean`，再重新 `build` 或 `all`。

参考资料：E-elements EGo1 v2.2 用户手册：`https://e-elements.readthedocs.io/zh/ego1_v2.2/EGo1.html`。

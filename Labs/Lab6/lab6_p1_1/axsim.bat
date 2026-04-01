@echo off

set PATH=%PATH%;E:\Xilinx\2025.1\Vivado\data\..\lib\win64.o;E:\Xilinx\2025.1\Vivado\data\..\lib\win64.o\Default;E:\Xilinx\2025.1\Vivado\data\..\tps\mingw\6.2.0\win64.o\nt\x86_64-w64-mingw32\lib

.\xsim.dir\adderTb_sim\axsim.exe %*

if %errorlevel% neq 0 (
  echo FATAL ERROR: Simulation exited unexpectantly
)

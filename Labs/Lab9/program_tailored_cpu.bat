@echo off
setlocal
pushd "%~dp0"
vivado -mode batch -source program_tailored_cpu.tcl
popd

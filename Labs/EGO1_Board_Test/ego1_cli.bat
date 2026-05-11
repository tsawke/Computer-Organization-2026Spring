@echo off
setlocal

pushd "%~dp0"

set "VIVADO_CMD="
if not "%VIVADO_BIN%"=="" (
    set "VIVADO_CMD=%VIVADO_BIN%"
) else (
    for /f "delims=" %%V in ('where vivado.bat 2^>nul') do (
        set "VIVADO_CMD=%%V"
        goto :vivado_found
    )
    for /f "delims=" %%V in ('where vivado 2^>nul') do (
        set "VIVADO_CMD=%%V"
        goto :vivado_found
    )
)

:vivado_found
if "%VIVADO_CMD%"=="" (
    echo ERROR: vivado was not found in PATH. Set VIVADO_BIN to the full path of vivado.bat.
    popd
    exit /b 1
)

if "%~1"=="" (
    set "EGO1_CMD=build"
) else (
    set "EGO1_CMD=%~1"
)

call "%VIVADO_CMD%" -mode batch -nojournal -nolog -notrace -source scripts\ego1_vivado.tcl -tclargs %EGO1_CMD%
set "RET=%ERRORLEVEL%"

popd
exit /b %RET%

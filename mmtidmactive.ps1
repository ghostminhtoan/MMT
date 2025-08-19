<#
.SYNOPSIS
    Script tong hop tat Windows Defender, cai dat IDM crack va bat lai Windows Defender
.DESCRIPTION
    Thuc hien tuan tu cac thao tac:
    1. Tat Windows Defender
    2. Tai va cai dat IDM crack
    3. Bat lai Windows Defender
    4. Tu dong thoat khi hoan thanh
#>

# 1. Tat Windows Defender
Write-Host "Dang tat Windows Defender..."
$offScript = "$env:TEMP\windefend_off.vbs"
try {
    Invoke-RestMethod "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20off.vbs" -OutFile $offScript
    $process = Start-Process "wscript.exe" $offScript -PassThru -Wait
    Remove-Item $offScript -Force
    Write-Host "Da tat Windows Defender thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "Loi khi tat Windows Defender: $_" -ForegroundColor Red
    exit 1
}

# 2. Tai va cai dat IDM crack
Write-Host "Dang tai va cai dat IDM crack..."
$idmInstaller = "$env:TEMP\idm_crack.exe"
try {
    Invoke-RestMethod "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/IDM_6.4x_Crack.exe" -OutFile $idmInstaller
    $process = Start-Process -FilePath $idmInstaller -PassThru
    $process.WaitForExit()
    Remove-Item $idmInstaller -Force
    Write-Host "Da cai dat IDM crack thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "Loi khi cai dat IDM crack: $_" -ForegroundColor Red
}

# 3. Bat lai Windows Defender
Write-Host "Dang bat lai Windows Defender..."
$onScript = "$env:TEMP\windefend_on.vbs"
try {
    Invoke-RestMethod "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20on.vbs" -OutFile $onScript
    $process = Start-Process "wscript.exe" $onScript -PassThru -Wait
    Remove-Item $onScript -Force
    Write-Host "Da bat lai Windows Defender thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "Loi khi bat Windows Defender: $_" -ForegroundColor Red
}

Write-Host "Hoan tat tat ca cac thao tac" -ForegroundColor Cyan

# Tu dong thoat sau 1 giay
Write-Host "Script se tu dong dong trong 1 giay..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
exit

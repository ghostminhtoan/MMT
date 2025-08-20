<#
.SYNOPSIS
    MMT IDM - Menu cai dat va kich hoat IDM
.DESCRIPTION
    Menu gom 2 chuc nang:
    1. Kich hoat IDM/Windows/Office
    2. Tai va cai dat IDM
#>

# Kiem tra quyen Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Yeu cau quyen Administrator. Dang khoi dong lai voi quyen Admin..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "              MMT IDM" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "1. Kich hoat IDM/Windows/Office" -ForegroundColor Yellow
    Write-Host "2. Tai va cai dat IDM" -ForegroundColor Yellow
    Write-Host "3. Thoat" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
}

function Activate-IDM-Windows-Office {
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
    Write-Host "Dang tat Windows Defender..." -ForegroundColor Yellow
    $offScript = "$env:TEMP\windefend_off.vbs"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20off.vbs" -OutFile $offScript
        Start-Process "wscript.exe" $offScript -Wait
        Remove-Item $offScript -Force -ErrorAction SilentlyContinue
        Write-Host "Da tat Windows Defender thanh cong" -ForegroundColor Green
    }
    catch {
        Write-Host "Loi khi tat Windows Defender: $_" -ForegroundColor Red
    }

    # 2. Tai va chay IDM crack
    Write-Host "Dang tai va chay IDM crack..." -ForegroundColor Yellow
    $idmCrack = "$env:TEMP\IDM_Crack.exe"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/IDM_6.4x_Crack.exe" -OutFile $idmCrack
        
        Write-Host "Dang chay IDM crack..." -ForegroundColor Cyan
        Write-Host "Hay su dung cong cu va TAT NO DI khi hoan thanh" -ForegroundColor Cyan
        Write-Host "Script se tu dong don dep sau khi ban tat cong cu" -ForegroundColor Cyan
        
        # Chay IDM crack va cho nguoi dung tat
        $process = Start-Process -FilePath $idmCrack -PassThru
        $process.WaitForExit()
        
        Write-Host "Da hoan thanh su dung IDM crack" -ForegroundColor Green
    }
    catch {
        Write-Host "Loi khi tai hoac chay IDM crack: $_" -ForegroundColor Red
    }

    # 3. Don dep file crack
    Write-Host "Dang xoa file IDM crack..." -ForegroundColor Yellow
    try {
        if (Test-Path $idmCrack) {
            Remove-Item $idmCrack -Force -ErrorAction SilentlyContinue
            Write-Host "Da xoa file IDM crack" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Loi khi xoa file IDM crack: $_" -ForegroundColor Red
    }

    # 4. Bat lai Windows Defender
    Write-Host "Dang bat lai Windows Defender..." -ForegroundColor Yellow
    $onScript = "$env:TEMP\windefend_on.vbs"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20on.vbs" -OutFile $onScript
        Start-Process "wscript.exe" $onScript -Wait
        Remove-Item $onScript -Force -ErrorAction SilentlyContinue
        Write-Host "Da bat lai Windows Defender thanh cong" -ForegroundColor Green
    }
    catch {
        Write-Host "Loi khi bat Windows Defender: $_" -ForegroundColor Red
    }

    Write-Host "Hoan tat tat ca cac thao tac" -ForegroundColor Cyan

    # Tu dong thoat sau 2 giay
    Write-Host "Script se tu dong dong trong 2 giay..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

function Install-IDM {
    Write-Host "Dang tai IDM tu tinyurl.com/idmhcmvn..." -ForegroundColor Green
    
    
    # Tải và cài đặt IDM
    $idmInstaller = "$env:TEMP\idm_setup.exe"
    try {
        Write-Host "Dang tai IDM..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://tinyurl.com/idmhcmvn" -OutFile $idmInstaller
        
        Write-Host "Dang cai dat IDM voi cac tham so: /s /a /u /o /quiet /skipdlgst" -ForegroundColor Yellow
        $process = Start-Process -FilePath $idmInstaller -ArgumentList "/s", "/a", "/u", "/o", "/quiet", "/skipdlgst" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Cai dat IDM thanh cong!" -ForegroundColor Green
        } else {
            Write-Host "Cai dat IDM that bai. Ma loi: $($process.ExitCode)" -ForegroundColor Red
        }
        
        # Dọn dẹp
        Remove-Item $idmInstaller -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Loi khi tai hoac cai dat IDM: $_" -ForegroundColor Red
    }
    
}

# Main program loop
do {
    Show-Menu
    $selection = Read-Host "Chon chuc nang (1-3)"
    
    switch ($selection) {
        "1" {
            Write-Host "Ban da chon: Kich hoat IDM/Windows/Office" -ForegroundColor Green
            Activate-IDM-Windows-Office
        }
        "2" {
            Write-Host "Ban da chon: Tai va cai dat IDM" -ForegroundColor Green
            Install-IDM
        }
        "3" {
            Write-Host "Thoat chuong trinh..." -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "Lua chon khong hop le! Vui long chon lai." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    
    if ($selection -ne "3") {
        Write-Host "`nNhan phim bat ky de tiep tuc..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($selection -ne "3")

<#
.SYNOPSIS
    Menu de tai va cai dat WinRAR
.DESCRIPTION
    Script nay cung cap menu voi 2 tuy chon:
    1. Tai va cai dat WinRAR voi che do im lang (/S)
    2. Tai, chay va tu xoa file winrar_keygen.exe
#>

function Set-ConsoleSettings {
    # Thiet lap font chu Consolas co 24
    $regPath = "HKCU:\Console"
    Set-ItemProperty -Path $regPath -Name "FaceName" -Value "Consolas" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $regPath -Name "FontSize" -Value 0x180000 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $regPath -Name "FontWeight" -Value 400 -ErrorAction SilentlyContinue
    
    # Thiet lap mau chu xanh la
    $host.UI.RawUI.ForegroundColor = "Green"
}

function Show-Menu {
    Clear-Host
    Write-Host "========================================"
    Write-Host "           MENU CAI DAT WINRAR          "
    Write-Host "========================================"
    Write-Host "1. Tai va cai dat WinRAR (che do im lang)"
    Write-Host "2. Tai va chay WinRAR Keygen"
    Write-Host "Q. Thoat"
    Write-Host "========================================"
}

function Install-WinRAR {
    # URL file WinRAR can tai
    $url = "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe"
    
    # Tao thu muc tam neu chua co
    $tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "WinRAR_Install")
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }

    # Duong dan file dich
    $destination = [System.IO.Path]::Combine($tempDir, "winrar-setup.exe")

    # Tai file
    try {
        Write-Host "Dang tai WinRAR..." -ForegroundColor Green
        Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
        
        # Kiem tra file da tai xong
        if (Test-Path $destination) {
            Write-Host "Dang cai dat WinRAR (che do im lang)..." -ForegroundColor Green
            $process = Start-Process -FilePath $destination -ArgumentList "/S" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Cai dat WinRAR thanh cong!" -ForegroundColor Green
            } else {
                Write-Host "Cai dat WinRAR that bai voi ma loi: $($process.ExitCode)" -ForegroundColor Red
            }
            
            # Xoa file sau khi cai dat
            Write-Host "Dang don dep..." -ForegroundColor Green
            Remove-Item -Path $destination -Force
            
            # Xoa thu muc tam neu rong
            if ((Get-ChildItem $tempDir -Force).Count -eq 0) {
                Remove-Item -Path $tempDir -Force
            }
        } else {
            Write-Host "Khong the tai file tu URL." -ForegroundColor Red
        }
    } catch {
        Write-Host "Loi khi tai hoac cai dat WinRAR: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

function Run-Keygen {
    # URL file keygen can tai
    $url = "https://github.com/ghostminhtoan/MMT/raw/refs/heads/main/winrar_keygen.exe"

    # Tao thu muc tam neu chua co
    $tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "MMT_Temp")
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }

    # Duong dan file dich
    $destination = [System.IO.Path]::Combine($tempDir, "winrar_keygen.exe")

    # Tai file
    try {
        Write-Host "Dang tai file..." -ForegroundColor Green
        Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
        
        # Kiem tra file da tai xong
        if (Test-Path $destination) {
            Write-Host "Dang chay chuong trinh..." -ForegroundColor Green
            $process = Start-Process -FilePath $destination -PassThru
            
            # Cho cho den khi chuong trinh dong
            Write-Host "Dang cho ban su dung xong..." -ForegroundColor Green
            $process.WaitForExit()
            
            # Xoa file sau khi dong chuong trinh
            Write-Host "Dang don dep..." -ForegroundColor Green
            Remove-Item -Path $destination -Force
            Write-Host "Da xoa file tam." -ForegroundColor Green
            
            # Xoa thu muc tam neu rong
            if ((Get-ChildItem $tempDir -Force).Count -eq 0) {
                Remove-Item -Path $tempDir -Force
            }
        } else {
            Write-Host "Khong the tai file tu URL." -ForegroundColor Red
        }
    } catch {
        Write-Host "Loi khi tai hoac chay file: $_" -ForegroundColor Red
    }

    Write-Host "Nhan phim bat ky de tiep tuc..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Thiet lap console
Set-ConsoleSettings

# Hien thi menu va xu ly lua chon
do {
    Show-Menu
    $choice = Read-Host "Vui long chon mot tuy chon"
    switch ($choice) {
        '1' {
            Install-WinRAR
        }
        '2' {
            Run-Keygen
        }
        'Q' {
            Write-Host "Dang thoat..." -ForegroundColor Green
            return
        }
        'q' {
            Write-Host "Dang thoat..." -ForegroundColor Green
            return
        }
        default {
            Write-Host "Lua chon khong hop le. Vui long chon lai." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true)

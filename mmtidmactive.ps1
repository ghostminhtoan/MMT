# Cau hinh console
$Host.UI.RawUI.WindowTitle = "IDM Manager"
$Host.UI.RawUI.ForegroundColor = "Green"
$Host.UI.RawUI.BackgroundColor = "Black"

# Thiet lap font va size (chi hoat dong tren Windows Terminal)
try {
    if ($Host.Name -eq "ConsoleHost") {
        $console = $Host.UI.RawUI
        $console.FontName = "Consolas"
        $console.FontSize = 28
    }
} catch {
    Write-Host "Khong the thay doi font chu. Tiep tuc voi font mac dinh..." -ForegroundColor Yellow
}

# Ham hien thi menu
function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "           IDM MANAGER MENU" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Tai va cai dat IDM" -ForegroundColor Green
    Write-Host "2. Kich hoat IDM" -ForegroundColor Green
    Write-Host "3. Thoat" -ForegroundColor Green
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
}

# Ham tai va cai dat IDM
function Install-IDM {
    Write-Host "Dang tai IDM..." -ForegroundColor Yellow
    
    # Tao thu muc tam neu chua ton tai
    $tempDir = "C:\Temp"
    if (!(Test-Path $tempDir)) {
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    }
    
    $downloadUrl = "https://tinyurl.com/idmhcmvn"
    $installerPath = "$tempDir\idm_setup.exe"
    
    try {
        # Tai file
        Write-Host "Dang tai tu: $downloadUrl" -ForegroundColor Gray
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UserAgent "Mozilla/5.0"
        $progressPreference = 'Continue'
        
        if (Test-Path $installerPath) {
            Write-Host "Da tai xong. Dang cai dat IDM..." -ForegroundColor Yellow
            
            # Cai dat voi cac tham so
            $process = Start-Process -FilePath $installerPath -ArgumentList "/s", "/a", "/u", "/o", "/skipdlgst" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Cai dat IDM thanh cong!" -ForegroundColor Green
            } else {
                Write-Host "Co loi xay ra trong qua trinh cai dat. Ma loi: $($process.ExitCode)" -ForegroundColor Red
            }
            
            # Xoa file cai dat
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "Khong the tai file cai dat" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "Loi khi tai hoac cai dat IDM: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Nhan phim bat ky de tiep tuc..." -ForegroundColor Gray
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# Ham kich hoat IDM
function Activate-IDM {
    Write-Host "Dang kich hoat IDM..." -ForegroundColor Yellow
    
    try {
        # Chay lenh kich hoat tu URL
        $activationScript = Invoke-RestMethod -Uri "https://tinyurl.com/mmtidmactive" -ErrorAction Stop
        Invoke-Expression $activationScript
        Write-Host "Kich hoat IDM thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "Loi khi kich hoat IDM: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui long kiem tra ket noi internet va thu lai" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Nhan phim bat ky de tiep tuc..." -ForegroundColor Gray
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# Main program
do {
    Show-Menu
    $choice = Read-Host "Chon mot tuy chon (1-3)"
    
    switch ($choice) {
        "1" {
            Install-IDM
        }
        "2" {
            Activate-IDM
        }
        "3" {
            Write-Host "Thoat chuong trinh..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Lua chon khong hop le. Vui long chon lai." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "3")

# Cấu hình console
$Host.UI.RawUI.WindowTitle = "IDM Manager"
$Host.UI.RawUI.ForegroundColor = "Green"
$Host.UI.RawUI.BackgroundColor = "Black"

# Thiết lập font và size (chỉ hoạt động trên Windows Terminal)
try {
    if ($Host.Name -eq "ConsoleHost") {
        $console = $Host.UI.RawUI
        $console.FontName = "Consolas"
        $console.FontSize = 28
    }
} catch {
    Write-Host "Không thể thay đổi font chữ. Tiếp tục với font mặc định..." -ForegroundColor Yellow
}

# Hàm hiển thị menu
function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "           IDM MANAGER MENU" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Tải và cài đặt IDM" -ForegroundColor Green
    Write-Host "2. Kích hoạt IDM" -ForegroundColor Green
    Write-Host "3. Thoát" -ForegroundColor Green
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
}

# Hàm tải và cài đặt IDM
function Install-IDM {
    Write-Host "Đang tải IDM..." -ForegroundColor Yellow
    
    # Tạo thư mục tạm nếu chưa tồn tại
    $tempDir = "C:\Temp"
    if (!(Test-Path $tempDir)) {
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    }
    
    $downloadUrl = "https://tinyurl.com/idmhcmvn"
    $installerPath = "$tempDir\idm_setup.exe"
    
    try {
        # Tải file
        Write-Host "Đang tải từ: $downloadUrl" -ForegroundColor Gray
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UserAgent "Mozilla/5.0"
        $progressPreference = 'Continue'
        
        if (Test-Path $installerPath) {
            Write-Host "Đã tải xong. Đang cài đặt IDM..." -ForegroundColor Yellow
            
            # Cài đặt với các tham số
            $process = Start-Process -FilePath $installerPath -ArgumentList "/s", "/a", "/u", "/o", "/skipdlgst" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Cài đặt IDM thành công!" -ForegroundColor Green
            } else {
                Write-Host "Có lỗi xảy ra trong quá trình cài đặt. Mã lỗi: $($process.ExitCode)" -ForegroundColor Red
            }
            
            # Xóa file cài đặt
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "Không thể tải file cài đặt" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "Lỗi khi tải hoặc cài đặt IDM: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Nhấn phím bất kỳ để tiếp tục..." -ForegroundColor Gray
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# Hàm kích hoạt IDM
function Activate-IDM {
    Write-Host "Đang kích hoạt IDM..." -ForegroundColor Yellow
    
    try {
        # Chạy lệnh kích hoạt từ URL
        $activationScript = Invoke-RestMethod -Uri "https://tinyurl.com/mmtidmactive" -ErrorAction Stop
        Invoke-Expression $activationScript
        Write-Host "Kích hoạt IDM thành công!" -ForegroundColor Green
    } catch {
        Write-Host "Lỗi khi kích hoạt IDM: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui lòng kiểm tra kết nối internet và thử lại" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Nhấn phím bất kỳ để tiếp tục..." -ForegroundColor Gray
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# Main program
do {
    Show-Menu
    $choice = Read-Host "Chọn một tùy chọn (1-3)"
    
    switch ($choice) {
        "1" {
            Install-IDM
        }
        "2" {
            Activate-IDM
        }
        "3" {
            Write-Host "Thoát chương trình..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Lựa chọn không hợp lệ. Vui lòng chọn lại." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "3")

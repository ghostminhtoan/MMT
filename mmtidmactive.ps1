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

# Hàm hiển thị tiêu đề
function Show-Header {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "           IDM MANAGER" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
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
                return $true
            } else {
                Write-Host "Có lỗi xảy ra trong quá trình cài đặt. Mã lỗi: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
            
            # Xóa file cài đặt
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "Không thể tải file cài đặt" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "Lỗi khi tải hoặc cài đặt IDM: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Hàm kích hoạt IDM
function Activate-IDM {
    Write-Host "Đang kích hoạt IDM..." -ForegroundColor Yellow
    
    try {
        # Chạy lệnh kích hoạt từ URL
        $activationScript = Invoke-RestMethod -Uri "https://tinyurl.com/mmtidmactive" -ErrorAction Stop
        Invoke-Expression $activationScript
        Write-Host "Kích hoạt IDM thành công!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Lỗi khi kích hoạt IDM: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui lòng kiểm tra kết nối internet và thử lại" -ForegroundColor Yellow
        return $false
    }
}

# Hàm hiển thị câu hỏi Yes/No
function Get-YesNoChoice {
    param(
        [string]$Prompt,
        [string]$YesText = "Yes",
        [string]$NoText = "No"
    )
    
    $choice = $null
    while ($choice -notin @('Y', 'N')) {
        Write-Host "$Prompt (Y/N) [Y: $YesText, N: $NoText]: " -ForegroundColor Cyan -NoNewline
        $choice = (Read-Host).ToUpper()
        
        if ($choice -notin @('Y', 'N')) {
            Write-Host "Lựa chọn không hợp lệ. Vui lòng chọn Y hoặc N." -ForegroundColor Red
        }
    }
    
    return $choice
}

# Main program
Show-Header

# Hỏi có muốn tải và cài đặt IDM không
$installChoice = Get-YesNoChoice -Prompt "Bạn có muốn tải và cài đặt IDM?" -YesText "Cài đặt IDM" -NoText "Bỏ qua"

if ($installChoice -eq 'Y') {
    $installResult = Install-IDM
    
    if ($installResult) {
        # Hỏi có muốn kích hoạt IDM không
        $activateChoice = Get-YesNoChoice -Prompt "Bạn có muốn kích hoạt IDM?" -YesText "Kích hoạt" -NoText "Không kích hoạt"
        
        if ($activateChoice -eq 'Y') {
            $activateResult = Activate-IDM
        } else {
            Write-Host "Đã bỏ qua kích hoạt IDM." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Quá trình cài đặt thất bại. Không thể tiếp tục kích hoạt." -ForegroundColor Red
    }
} else {
    Write-Host "Đã hủy cài đặt IDM." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Quá trình hoàn tất. Nhấn phím bất kỳ để thoát..." -ForegroundColor Gray
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null

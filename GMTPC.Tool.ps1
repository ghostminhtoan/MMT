# 1. Tắt thanh tiến trình
$ProgressPreference = 'SilentlyContinue'

# Đường dẫn
$TempFolder = "$env:LOCALAPPDATA\GMTPC\GMTPC Tools"
$ExePath = Join-Path $TempFolder "GMTPC.Tool.exe"
$Url = "https://github.com/ghostminhtoan/GMTPC.Tool/raw/refs/heads/main/GMTPC.Tool.exe"

try {
    # 2. Tạo thư mục
    Write-Host "Dang chuan bi moi truong..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null

    # 3. Tải file
    Write-Host "Dang tai file..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $ExePath -UseBasicParsing -ErrorAction Stop
    
    if (-not (Test-Path $ExePath)) {
        throw "Tai file that bai: $ExePath khong ton tai"
    }

    # 4. Chạy tool
    Write-Host "Dang chay Tool..." -ForegroundColor Cyan
    Start-Process -FilePath $ExePath -Wait

    # 5. Dọn dẹp (chỉ xóa file exe, giữ lại thư mục)
    Write-Host "Dang don dep..." -ForegroundColor Cyan
    Remove-Item -Path $ExePath -Force -ErrorAction SilentlyContinue
    
    Write-Host "Hoan tat!" -ForegroundColor Green
}
catch {
    Write-Host "Loi: $($_.Exception.Message)" -ForegroundColor Red
    pause
    exit 1
}

exit

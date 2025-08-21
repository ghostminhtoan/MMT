# Kiểm tra và chạy với quyền Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# URL file cần tải
$url = "https://github.com/ghostminhtoan/MMT/raw/refs/heads/main/MMT_Tool_test.exe"
$fileName = [System.IO.Path]::GetFileName($url)
$downloadPath = Join-Path $env:TEMP $fileName

# Tải file
try {
    Write-Host "Đang tải file..."
    Invoke-WebRequest -Uri $url -OutFile $downloadPath -UseBasicParsing
}
catch {
    Write-Host "Lỗi khi tải file: $($_.Exception.Message)"
    exit
}

# Kiểm tra file đã tải thành công
if (Test-Path $downloadPath) {
    Write-Host "Đang chạy file..."
    
    # Chạy file
    try {
        Start-Process -FilePath $downloadPath -Wait
    }
    catch {
        Write-Host "Lỗi khi chạy file: $($_.Exception.Message)"
    }
    
    # Đợi 30 giây và xóa file (không hiển thị thông báo)
    Start-Sleep -Seconds 30
    
    try {
        if (Test-Path $downloadPath) {
            Remove-Item -Path $downloadPath -Force
        }
    }
    catch {
        # Không hiển thị thông báo lỗi nếu có
    }
}
else {
    Write-Host "Không thể tải file từ URL đã cho"
}

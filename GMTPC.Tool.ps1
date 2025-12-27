# Đường dẫn thư mục
$TempFolder = "$env:LOCALAPPDATA\GMTPC\GMTPC Tools"
$ExePath = Join-Path $TempFolder "GMTPC.Tool.exe"
$Url = https://github.com/ghostminhtoan/private/releases/download/MMT/GMTPC.Tool.exe"

# 1. Tạo thư mục MMTPC
if (!(Test-Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder | Out-Null
}



# 3. Tải file về
Invoke-WebRequest -Uri $Url -OutFile $ExePath

# 4. Chạy file và chờ nó đóng
Start-Process -FilePath $ExePath -Wait


# 6. Xoá thư mục MMTPC
Remove-Item -Path $TempFolder -Recurse -Force

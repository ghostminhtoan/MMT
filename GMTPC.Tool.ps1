# 1. TẮT THANH TIẾN TRÌNH: Đây là "chìa khóa" giúp Invoke-WebRequest tải nhanh gấp nhiều lần
$ProgressPreference = 'SilentlyContinue'

# Đường dẫn thư mục
$TempFolder = "$env:LOCALAPPDATA\GMTPC\GMTPC Tools"
$ExePath = Join-Path $TempFolder "GMTPC.Tool.exe"
$Url = "https://github.com/ghostminhtoan/GMTPC.Tool/raw/refs/heads/main/GMTPC.Tool.exe"

# 2. Tạo thư mục: Dùng -Force nó sẽ tự động tạo nếu chưa có, không cần dùng Test-Path nữa
Write-Host "Dang chuan bi moi truong..."
New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null

# 3. Tải file về (Đã nhanh hơn rất nhiều nhờ tắt ProgressPreference)
Write-Host "Dang tai file..."
# Cách 1: Dùng Invoke-WebRequest (đã được tối ưu)
Invoke-WebRequest -Uri $Url -OutFile $ExePath -UseBasicParsing

# Cách 2: (Thay thế cho Cách 1) Sử dụng .NET WebClient - Cách này thậm chí còn nhanh và ổn định hơn trên các máy đời cũ
# (New-Object System.Net.WebClient).DownloadFile($Url, $ExePath)

# 4. Chạy file và đợi nó đóng
Write-Host "Dang chay Tool..."
Start-Process -FilePath $ExePath -Wait

# 5. Xóa thư mục dọn dẹp
Write-Host "Dang don dep..."
Remove-Item -Path $TempFolder -Recurse -Force

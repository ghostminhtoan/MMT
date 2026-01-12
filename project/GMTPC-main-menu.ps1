# Tải và chạy file
$filePath = "$env:USERPROFILE\AppData\Local\Temp\GMTPC.Main.Menu.exe"
Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/GMTPC.Main.Menu.exe" -OutFile $filePath -ErrorAction SilentlyContinue

# Chạy file với tham số -p1111
Start-Process -FilePath $filePath -ArgumentList "-p1111" -Wait

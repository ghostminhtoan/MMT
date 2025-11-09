# Tải và chạy file
$filePath = "$env:USERPROFILE\AppData\Local\Temp\Qwen.to.API.exe"
Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/QwenToAPI.exe" -OutFile $filePath -ErrorAction SilentlyContinue

if (Test-Path $filePath) {
    Start-Process -FilePath $filePath -Wait
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
}

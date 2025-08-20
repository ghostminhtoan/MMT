# Script tự động xóa cache không hỏi xác nhận
Write-Host "Đang tự động xóa cache PowerShell..." -ForegroundColor Yellow

# Xóa WebClientCache
$webClientCache = Join-Path $env:TEMP "WebClientCache"
if (Test-Path $webClientCache) {
    Remove-Item -Path $webClientCache -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Đã xóa WebClientCache" -ForegroundColor Green
}

# Xóa cache IE liên quan
$ieCache = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\INetCache"
if (Test-Path $ieCache) {
    Get-ChildItem -Path $ieCache -Filter "*iwr*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -Path $ieCache -Filter "*irm*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
}

# Xóa lịch sử PowerShell
Clear-History -ErrorAction SilentlyContinue

Write-Host "Hoàn thành dọn dẹp cache!" -ForegroundColor Green

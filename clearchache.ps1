# Script tu dong xoa cache khong hoi xac nhan
Write-Host "Dang tu dong xoa cache PowerShell..." -ForegroundColor Yellow

# Xoa WebClientCache
$webClientCache = Join-Path $env:TEMP "WebClientCache"
if (Test-Path $webClientCache) {
    Remove-Item -Path $webClientCache -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Da xoa WebClientCache" -ForegroundColor Green
}

# Xoa cache IE lien quan
$ieCache = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\INetCache"
if (Test-Path $ieCache) {
    Get-ChildItem -Path $ieCache -Filter "*iwr*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -Path $ieCache -Filter "*irm*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
}

# Xoa lich su PowerShell
Clear-History -ErrorAction SilentlyContinue

Write-Host "Hoan thanh don dep cache!" -ForegroundColor Green

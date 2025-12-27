# Duong dan thu muc
$TempFolder = "$env:LOCALAPPDATA\GMTPC\GMTPC Tools"
$ExePath = Join-Path $TempFolder "GMTPC.Tool.exe"
$Url = "https://github.com/ghostminhtoan/private/releases/download/MMT/GMTPC.Tool.exe"  # <-- Dat URL trong dau nhay kep

# 1. Tao thu muc GMTPC Tool
if (!(Test-Path $TempFolder)) {
    Write-Host "Tao thu muc: $TempFolder"
    New-Item -ItemType Directory -Path $TempFolder -Force | Out-Null
}

# 3. Tai file ve
Invoke-WebRequest -Uri $Url -OutFile $ExePath -UseBasicParsing

# 4. Chay file va doi no dong
Start-Process -FilePath $ExePath -Wait

# 6. Xoa thu muc GMTPC Tool
Remove-Item -Path $TempFolder -Recurse -Force

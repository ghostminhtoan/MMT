# Set console properties
$Host.UI.RawUI.ForegroundColor = "Green"
$shell = $Host.UI.RawUI
$shell.WindowTitle = "MMT PE Tool"

# Try to set font (may not work in all environments)
try {
    $shell.Font = New-Object System.Management.Automation.Host.Font("Consolas", 28, [System.Windows.FontWeight]::Normal, $false)
} catch {
    Write-Host "Khong the thay doi font, su dung font mac dinh" -ForegroundColor Yellow
}

function Show-Menu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "           MMTPE TOOL" -ForegroundColor Yellow
    Write-Host "=============================================="
    Write-Host "1. Cai Windows PE vao o X (Tu dong mo link download)"
    Write-Host "2. Xoa o X va lay lai dung luong"
    Write-Host "3. Thoat"
    Write-Host "=============================================="
}

function Install-WinPE {
    Write-Host "`nDang cai Windows PE vao o X..." -ForegroundColor Yellow
    Write-Host "Chay lenh: irm tinyurl.com/mmtpe002 | iex" -ForegroundColor Cyan
    
    
        # Mo trinh duyet de download Neat Download Manager
    Write-Host "`nDang mo trinh duyet de tai Neat Download Manager..." -ForegroundColor Yellow
    $urlApp = "https://github.com/ghostminhtoan/private/releases/download/MMT/Neat.Download.Manager.exe"
    
    try {
        Write-Host "Mo trinh duyet tai Neat Download Manager..." -ForegroundColor Cyan
        Start-Process $urlApp
        Write-Host "Dang tai" -ForegroundColor Red -BackgroundColor White
    }
    catch {
        Write-Host "Loi mo trinh duyet App: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui long truy cap thu cong: $urlApp" -ForegroundColor Cyan
    }
    
    # Mo trinh duyet de download MMT App
    Write-Host "`nDang mo trinh duyet de tai MMT App..." -ForegroundColor Yellow
    $urlApp = "https://drive.google.com/drive/folders/1tUBZCVbzxmmsJIbAIuUVk2aJ_LXVRLui?usp=drive_link"
    
    try {
        Write-Host "Mo trinh duyet tai MMT App..." -ForegroundColor Cyan
        Start-Process $urlApp
        Write-Host "HAY TAI UNG DUNG CAN THIET" -ForegroundColor Red -BackgroundColor White
    }
    catch {
        Write-Host "Loi mo trinh duyet App: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui long truy cap thu cong: $urlApp" -ForegroundColor Cyan
    }
    
    
    # Mo trinh duyet de download ISO Windows PE
    Write-Host "`nDang mo trinh duyet de tai ISO HARD DISK BOOT WINDOWS PE..." -ForegroundColor Yellow
    $urlISO = "https://drive.google.com/drive/folders/1vPpZmcAmLPY8lGnkgOZ6I2bOrQKrJt30?usp=drive_link"
    
    
        try {
        Write-Host "Mo trinh duyet tai ISO HARD DISK BOOT WINDOWS PE..." -ForegroundColor Cyan
        Start-Process $urlISO
        Write-Host "HAY TAI FILE ISO HARD DISK BOOT WINDOWS PE" -ForegroundColor Red -BackgroundColor White
    }
    catch {
        Write-Host "Loi mo trinh duyet ISO: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui long truy cap thu cong: $urlISO" -ForegroundColor Cyan
    }
    
    Write-Host "`nCac trinh duyet da duoc mo. Vui long tai file can thiet." -ForegroundColor Green
    Write-Host "Sau khi tai xong, nhan phim bat ky de tiep tuc cai dat Windows PE..." -ForegroundColor Yellow
    Pause
    
    # Chay lenh cai dat Windows PE
    Write-Host "`nDang chay lenh cai dat Windows PE..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "https://tinyurl.com/mmtpe002" -Method Get | Invoke-Expression
        Write-Host "Cai dat thanh cong!" -ForegroundColor Green
    }
    catch {
        Write-Host "Loi trong qua trinh cai dat: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Remove-DriveX {
    Write-Host "`nDang xoa o X va lay lai dung luong..." -ForegroundColor Yellow
    Write-Host "Chay lenh: irm tinyurl.com/mmtpe003 | iex" -ForegroundColor Cyan
    
    try {
        Invoke-RestMethod -Uri "https://tinyurl.com/mmtpe003" -Method Get | Invoke-Expression
        Write-Host "Xoa o X thanh cong!" -ForegroundColor Green
    }
    catch {
        Write-Host "Loi trong qua trinh xoa: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Pause {
    Write-Host "`nNhan phim bat ky de tiep tuc..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Main program
do {
    Show-Menu
    $choice = Read-Host "`nChon option (1-3)"
    
    switch ($choice) {
        "1" { Install-WinPE }
        "2" { Remove-DriveX }
        "3" { 
            Write-Host "Thoat chuong trinh..." -ForegroundColor Yellow
            break 
        }
        default {
            Write-Host "Lua chon khong hop le! Vui long chon tu 1-3." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "3")

# Reset console color
$Host.UI.RawUI.ForegroundColor = "Gray"

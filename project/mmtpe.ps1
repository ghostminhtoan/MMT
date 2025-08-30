# Set console properties
$Host.UI.RawUI.ForegroundColor = "Green"
$shell = $Host.UI.RawUI
$shell.WindowTitle = "MMT PE Tool"

# Try to set font (may not work in all environments)
try {
    $shell.Font = New-Object System.Management.Automation.Host.Font("Consolas", 28, [System.Windows.FontWeight]::Normal, $false)
} catch {
    Write-Host "Không thể thay đổi font, sử dụng font mặc định" -ForegroundColor Yellow
}

function Show-Menu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "           MMTPE TOOL" -ForegroundColor Yellow
    Write-Host "=============================================="
    Write-Host "1. Cài Windows PE vào ổ X (Tự động mở link download)"
    Write-Host "2. Xóa ổ X và lấy lại dung lượng"
    Write-Host "3. Thoát"
    Write-Host "=============================================="
}

function Install-WinPE {
    Write-Host "`nĐang cài Windows PE vào ổ X..." -ForegroundColor Yellow
    Write-Host "Chạy lệnh: irm tinyurl.com/mmtpe002 | iex" -ForegroundColor Cyan
    
    # Mở trình duyệt để download ISO Windows PE
    Write-Host "`nĐang mở trình duyệt để tải ISO HARD DISK BOOT WINDOWS PE..." -ForegroundColor Yellow
    $urlISO = "https://drive.google.com/drive/folders/1vPpZmcAmLPY8lGnkgOZ6I2bOrQKrJt30?usp=drive_link"
    
    
    # Mở trình duyệt để download MMT App
    Write-Host "`nĐang mở trình duyệt để tải MMT App..." -ForegroundColor Yellow
    $urlApp = "https://drive.google.com/drive/folders/1tUBZCVbzxmmsJIbAIuUVk2aJ_LXVRLui?usp=drive_link"
    
    try {
        Write-Host "Mở trình duyệt tải MMT App..." -ForegroundColor Cyan
        Start-Process $urlApp
        Write-Host "HÃY TẢI ỨNG DỤNG CẦN THIẾT" -ForegroundColor Red -BackgroundColor White
    }
    catch {
        Write-Host "Lỗi mở trình duyệt App: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui lòng truy cập thủ công: $urlApp" -ForegroundColor Cyan
    }

        try {
        Write-Host "Mở trình duyệt tải ISO HARD DISK BOOT WINDOWS PE..." -ForegroundColor Cyan
        Start-Process $urlISO
        Write-Host "HÃY TẢI FILE ISO HARD DISK BOOT WINDOWS PE" -ForegroundColor Red -BackgroundColor White
    }
    catch {
        Write-Host "Lỗi mở trình duyệt ISO: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Vui lòng truy cập thủ công: $urlISO" -ForegroundColor Cyan
    }
    
    Write-Host "`nCác trình duyệt đã được mở. Vui lòng tải file cần thiết." -ForegroundColor Green
    Write-Host "Sau khi tải xong, nhấn phím bất kỳ để tiếp tục cài đặt Windows PE..." -ForegroundColor Yellow
    Pause
    
    # Chạy lệnh cài đặt Windows PE
    Write-Host "`nĐang chạy lệnh cài đặt Windows PE..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "https://tinyurl.com/mmtpe002" -Method Get | Invoke-Expression
        Write-Host "Cài đặt thành công!" -ForegroundColor Green
    }
    catch {
        Write-Host "Lỗi trong quá trình cài đặt: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Remove-DriveX {
    Write-Host "`nĐang xóa ổ X và lấy lại dung lượng..." -ForegroundColor Yellow
    Write-Host "Chạy lệnh: irm tinyurl.com/mmtpe003 | iex" -ForegroundColor Cyan
    
    try {
        Invoke-RestMethod -Uri "https://tinyurl.com/mmtpe003" -Method Get | Invoke-Expression
        Write-Host "Xóa ổ X thành công!" -ForegroundColor Green
    }
    catch {
        Write-Host "Lỗi trong quá trình xóa: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Pause {
    Write-Host "`nNhấn phím bất kỳ để tiếp tục..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Main program
do {
    Show-Menu
    $choice = Read-Host "`nChọn option (1-3)"
    
    switch ($choice) {
        "1" { Install-WinPE }
        "2" { Remove-DriveX }
        "3" { 
            Write-Host "Thoát chương trình..." -ForegroundColor Yellow
            break 
        }
        default {
            Write-Host "Lựa chọn không hợp lệ! Vui lòng chọn từ 1-3." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "3")

# Reset console color
$Host.UI.RawUI.ForegroundColor = "Gray"

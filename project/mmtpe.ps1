# Set console properties
$Host.UI.RawUI.ForegroundColor = "Green"
$Host.UI.RawUI.Font = New-Object System.Management.Automation.Host.Font("Consolas", 28, [System.Windows.FontWeight]::Normal, $false)
$Host.UI.RawUI.WindowTitle = "MMT PE Tool"

function Show-Menu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "           MMT PE TOOL MENU"
    Write-Host "=============================================="
    Write-Host "1. Cài Windows PE vào ổ X"
    Write-Host "2. Xóa ổ X và lấy lại dung lượng"
    Write-Host "3. Download iso Windows PE"
    Write-Host "4. Thoát"
    Write-Host "=============================================="
}

function Install-WinPE {
    Write-Host "`nĐang cài Windows PE vào ổ X..." -ForegroundColor Yellow
    Write-Host "Chạy lệnh: irm tinyurl.com/mmtpe002 | iex" -ForegroundColor Cyan
    
    try {
        Invoke-RestMethod -Uri "tinyurl.com/mmtpe002" -Method Get | Invoke-Expression
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
        Invoke-RestMethod -Uri "tinyurl.com/mmtpe003" -Method Get | Invoke-Expression
        Write-Host "Xóa ổ X thành công!" -ForegroundColor Green
    }
    catch {
        Write-Host "Lỗi trong quá trình xóa: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Download-WinPEISO {
    Write-Host "`nĐang tải Windows PE ISO..." -ForegroundColor Yellow
    $url = "https://github.com/ghostminhtoan/MMT/releases/download/WinPE/Hark.Disk.Boot.MMTPE.v1.0.iso"
    $output = "C:\winpe.iso"
    
    try {
        # Create C:\ if not exists
        if (!(Test-Path "C:\")) {
            New-Item -Path "C:\" -ItemType Directory -Force
        }
        
        Write-Host "Đang tải file từ: $url" -ForegroundColor Cyan
        Write-Host "Lưu tại: $output" -ForegroundColor Cyan
        
        # Download file
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        
        if (Test-Path $output) {
            Write-Host "Tải thành công! File đã được lưu tại: $output" -ForegroundColor Green
            Write-Host "Đã rename thành winpe.iso" -ForegroundColor Green
        }
        else {
            Write-Host "Tải thất bại!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Lỗi trong quá trình tải: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pause
}

function Pause {
    Write-Host "`nNhấn phím bất kỳ để tiếp tục..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main program
do {
    Show-Menu
    $choice = Read-Host "`nChọn option (1-4)"
    
    switch ($choice) {
        "1" { Install-WinPE }
        "2" { Remove-DriveX }
        "3" { Download-WinPEISO }
        "4" { 
            Write-Host "Thoát chương trình..." -ForegroundColor Yellow
            break 
        }
        default {
            Write-Host "Lựa chọn không hợp lệ! Vui lòng chọn từ 1-4." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "4")

# Reset console color
$Host.UI.RawUI.ForegroundColor = "Gray"

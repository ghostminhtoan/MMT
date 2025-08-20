# PowerShell Script - Menu Tải Chrome và Edge
# Tác giả: Browser Download Menu

function Show-Menu {
    Clear-Host
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "    MENU TẢI TRÌNH DUYỆT        " -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Tải Google Chrome" -ForegroundColor Green
    Write-Host "2. Tải Microsoft Edge" -ForegroundColor Green
    Write-Host "3. Tải cả hai trình duyệt" -ForegroundColor Green
    Write-Host "4. Thoát" -ForegroundColor Red
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$BrowserName
    )
    
    try {
        Write-Host "Đang tải $BrowserName..." -ForegroundColor Yellow
        Write-Host "URL: $Url" -ForegroundColor Gray
        Write-Host "Đường dẫn lưu: $OutputPath" -ForegroundColor Gray
        Write-Host ""
        
        # Tạo thư mục Downloads nếu chưa tồn tại
        $DownloadDir = Split-Path $OutputPath -Parent
        if (!(Test-Path $DownloadDir)) {
            New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
        }
        
        # Tải file với progress bar
        $webClient = New-Object System.Net.WebClient
        
        # Đăng ký event để hiển thị tiến trình
        Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
            $Global:ProgressPercent = $Event.SourceEventArgs.ProgressPercentage
            Write-Progress -Activity "Đang tải $BrowserName" -Status "$Global:ProgressPercent% hoàn thành" -PercentComplete $Global:ProgressPercent
        } | Out-Null
        
        # Bắt đầu tải
        $webClient.DownloadFile($Url, $OutputPath)
        
        # Dọn dẹp events
        Get-EventSubscriber | Unregister-Event
        Write-Progress -Activity "Đang tải $BrowserName" -Completed
        
        Write-Host "✅ Tải $BrowserName thành công!" -ForegroundColor Green
        Write-Host "📁 File đã được lưu tại: $OutputPath" -ForegroundColor Green
        
        # Hỏi có muốn chạy file cài đặt không
        $install = Read-Host "Bạn có muốn chạy file cài đặt ngay bây giờ? (y/n)"
        if ($install -eq 'y' -or $install -eq 'Y') {
            Start-Process -FilePath $OutputPath
        }
        
    } catch {
        Write-Host "❌ Lỗi khi tải $BrowserName`: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Nhấn Enter để tiếp tục..." -ForegroundColor Cyan
    Read-Host
}

function Download-Chrome {
    $chromeUrl = "https://github.com/ghostminhtoan/MMT/raw/refs/heads/main/ChromeSetup.exe"
    $chromeOutput = "$env:USERPROFILE\Downloads\ChromeSetup.exe"
    Download-File -Url $chromeUrl -OutputPath $chromeOutput -BrowserName "Google Chrome"
}

function Download-Edge {
    $edgeUrl = "https://c2rsetup.officeapps.live.com/c2r/downloadEdge.aspx?platform=Default&source=EdgeStablePage&Channel=Stable&language=vi&brand=M100"
    $edgeOutput = "$env:USERPROFILE\Downloads\MicrosoftEdgeSetup.exe"
    Download-File -Url $edgeUrl -OutputPath $edgeOutput -BrowserName "Microsoft Edge"
}

function Download-Both {
    Write-Host "Bắt đầu tải cả hai trình duyệt..." -ForegroundColor Yellow
    Write-Host ""
    
    Download-Chrome
    Download-Edge
    
    Write-Host "🎉 Hoàn thành tải cả hai trình duyệt!" -ForegroundColor Green
}

# Main program loop
do {
    Show-Menu
    $choice = Read-Host "Nhập lựa chọn của bạn (1-4)"
    
    switch ($choice) {
        '1' {
            Download-Chrome
        }
        '2' {
            Download-Edge
        }
        '3' {
            Download-Both
        }
        '4' {
            Write-Host "Cảm ơn bạn đã sử dụng! Tạm biệt! 👋" -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Lựa chọn không hợp lệ! Vui lòng chọn từ 1-4." -ForegroundColor Red
            Start-Sleep 2
        }
    }
} while ($true)

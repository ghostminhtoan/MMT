function Show-Menu {
    # Thiet lap font chu va mau sac
    $Host.UI.RawUI.FontName = "Consolas"
    $Host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.WindowTitle = "Menu Lua Chon"
    
    # Co gang thiet lap kich thuoc font chu
    try {
        $Host.UI.RawUI.FontSize = 24
    }
    catch {
        Write-Host "Khong the thiet lap co chu 24, su dung co chu mac dinh." -ForegroundColor Yellow
    }
    
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "           MENU LUA CHON" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    
    # Tao menu 1 cot da cap nhat
    Write-Host " 1. Cai dat va Active IDM (bao gom Windows/Office)" -ForegroundColor Green
    Write-Host " 2. Cai dat va active winrar theo ten tuy chon" -ForegroundColor Green
    Write-Host " 3. Cai winpe vao o X" -ForegroundColor Green
    Write-Host " 4. Xoa cache PowerShell" -ForegroundColor Green
    Write-Host ""
    Write-Host " 0. Thoat" -ForegroundColor Red
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
}

do {
    Show-Menu
    $choice = Read-Host "Vui long chon mot so (0-4)"
    
    switch ($choice) {
        '1' {
            Write-Host "Dang khoi chay: Cai dat va Active IDM (bao gom Windows/Office)..." -ForegroundColor Green
            try {
                # Chay trong cua so PowerShell moi doc lap (khong cho)
                Start-Process powershell -ArgumentList "-NoExit -Command &{irm tinyurl.com/mmtidmactive | iex; Write-Host 'Hoan thanh! Cua so se tu dong trong 5 giay...' -ForegroundColor Green; Start-Sleep -Seconds 5}" -WindowStyle Normal
                Write-Host "Da khoi chay thanh cong!" -ForegroundColor Green
            }
            catch {
                Write-Host "Co loi xay ra: $_" -ForegroundColor Red
            }
            # Tu dong quay ve menu sau 1 giay
            Start-Sleep -Seconds 1
        }
        '2' {
            Write-Host "Dang khoi chay: Cai dat va active winrar..." -ForegroundColor Green
            try {
                # Chay trong cua so PowerShell moi doc lap (khong cho)
                Start-Process powershell -ArgumentList "-NoExit -Command &{irm tinyurl.com/mmtwinrar | iex; Write-Host 'Hoan thanh! Cua so se tu dong trong 5 giay...' -ForegroundColor Green; Start-Sleep -Seconds 5}" -WindowStyle Normal
                Write-Host "Da khoi chay thanh cong!" -ForegroundColor Green
            }
            catch {
                Write-Host "Co loi xay ra: $_" -ForegroundColor Red
            }
            # Tu dong quay ve menu sau 1 giay
            Start-Sleep -Seconds 1
        }
        '3' {
            Write-Host "Dang khoi chay: Cai winpe vao o X..." -ForegroundColor Green
            try {
                # Chay trong cua so PowerShell moi doc lap (khong cho)
                Start-Process powershell -ArgumentList "-NoExit -Command &{irm tinyurl.com/mmtpe002 | iex; Write-Host 'Hoan thanh! Cua so se tu dong trong 5 giay...' -ForegroundColor Green; Start-Sleep -Seconds 5}" -WindowStyle Normal
                Write-Host "Da khoi chay thanh cong!" -ForegroundColor Green
            }
            catch {
                Write-Host "Co loi xay ra: $_" -ForegroundColor Red
            }
            # Tu dong quay ve menu sau 1 giay
            Start-Sleep -Seconds 1
        }
        '4' {
            Write-Host "Dang khoi chay: Xoa cache PowerShell..." -ForegroundColor Green
            try {
                # Chay trong cua so PowerShell moi doc lap (khong cho)
                Start-Process powershell -ArgumentList "-NoExit -Command &{irm tinyurl.com/clearcacheps1 | iex; Write-Host 'Hoan thanh! Cua so se tu dong trong 5 giay...' -ForegroundColor Green; Start-Sleep -Seconds 5}" -WindowStyle Normal
                Write-Host "Da khoi chay thanh cong!" -ForegroundColor Green
            }
            catch {
                Write-Host "Co loi xay ra: $_" -ForegroundColor Red
            }
            # Tu dong quay ve menu sau 1 giay
            Start-Sleep -Seconds 1
        }
        '0' {
            Write-Host "Dang thoat..." -ForegroundColor Yellow
        }
        default {
            Write-Host "Lua chon khong hop le. Vui long chon tu 0-4." -ForegroundColor Red
            # Tu dong quay ve menu sau 2 giay
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne '0')

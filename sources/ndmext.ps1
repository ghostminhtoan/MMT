# Mở trình duyệt Edge với link chỉ định
Start-Process "msedge.exe" "https://chromewebstore.google.com/detail/neatdownloadmanager-exten/cpcifbdmkopohnnofedkjghjiclmhdah"

# Chờ 3 giây để trang web load
Start-Sleep -Seconds 3

# Thêm thư viện .NET để gửi phím
Add-Type -AssemblyName System.Windows.Forms

# Tab 5 lần
1..5 | ForEach-Object {
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 100
}

# Space 1 lần
[System.Windows.Forms.SendKeys]::SendWait(" ")

# Chờ 1 giây
Start-Sleep -Seconds 1

# Tab 1 lần
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")

# Space 1 lần
[System.Windows.Forms.SendKeys]::SendWait(" ")

Write-Host "Đã hoàn thành các thao tác tự động!" -ForegroundColor Green

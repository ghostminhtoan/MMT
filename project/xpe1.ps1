function Check-XDriveAvailable {
    # Kiểm tra xem ổ X: đã được sử dụng chưa
    $XDrive = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
    if ($XDrive) {
        Write-Host "⚠️ Ổ X: đã được sử dụng. Bạn có muốn sử dụng lại ổ X: không?" -ForegroundColor Yellow
        $choice = Read-Host "Chọn Y để tiếp tục (dữ liệu sẽ mất) hoặc N để hủy (Y/N)"
        if ($choice -notmatch '^[Yy]') {
            Write-Host "❌ Hủy thao tác..." -ForegroundColor Red
            return $false
        }
        return $true
    }
    return $true
}

# ... (giữ nguyên các hàm khác) ...

# Main script execution
Write-Host "=== SCRIPT TẠO Ổ ĐĨA WINPE ===`n" -ForegroundColor Cyan

# Kiểm tra quyền administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Vui lòng chạy script với quyền Administrator!" -ForegroundColor Red
    pause
    exit
}

# Kiểm tra ổ X: có sẵn không
if (-not (Check-XDriveAvailable)) {
    pause
    exit
}

# Hỏi người dùng có muốn tiếp tục không
$Continue = Read-Host "Bạn có muốn tiếp tục? (Y/N)"
if ($Continue -notmatch '^[Yy]') {
    Write-Host "Thoát script..." -ForegroundColor Yellow
    pause
    exit
}

# Kiểm tra nếu ổ X đã tồn tại thì bỏ qua bước tạo ổ
$XDriveExists = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
$SkipCreateXDrive = $false

if ($XDriveExists) {
    Write-Host "✅ Ổ X: đã tồn tại, bỏ qua bước tạo ổ đĩa" -ForegroundColor Green
    $SkipCreateXDrive = $true
    
    # Format ổ X: ngay lập tức nếu đã tồn tại
    try {
        Write-Host "Đang format ổ X:..." -ForegroundColor Yellow
        Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel "WINPE" -Confirm:$false -Force
        Write-Host "✅ Đã format lại ổ X: thành công" -ForegroundColor Green
    } catch {
        Write-Host "❌ Lỗi khi format ổ X: $($_.Exception.Message)" -ForegroundColor Red
        pause
        exit
    }
} else {
    # ... (giữ nguyên phần tạo ổ X mới) ...
}

# ... (phần còn lại của script giữ nguyên) ...

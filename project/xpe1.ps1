# Bước 3: Hỏi đường dẫn file ISO
$isoPath = Read-Host "Dán đường dẫn file ISO (ví dụ: D:\win10.iso)"
$isoPath = $isoPath.Trim('"')

if (!(Test-Path $isoPath)) {
    Write-Host "❌ Không tìm thấy file ISO tại $isoPath"
    Pause
    return
}

try {
    # Mount ISO
    $iso = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop
    Start-Sleep -Seconds 2

    # Lấy danh sách volume trước và sau khi mount
    $diskImage = Get-DiskImage -ImagePath $isoPath
    $volumes = Get-Volume
    $isoDriveLetter = $null

    foreach ($v in $volumes) {
        if ($v.DriveType -eq 'CD-ROM') {
            $isoDriveLetter = $v.DriveLetter
            break
        }
    }

    if (-not $isoDriveLetter) {
        Write-Host "❌ Không lấy được ký tự ổ đĩa ISO. Đảm bảo ISO đã mount đúng."
        Dismount-DiskImage -ImagePath $isoPath
        Pause
        return
    }

    # Kiểm tra boot.wim
    $bootWimPath = $isoDriveLetter + ":\sources\boot.wim"
    if (!(Test-Path $bootWimPath)) {
        Write-Host "❌ Không tìm thấy \\sources\\boot.wim trong ISO."
        Dismount-DiskImage -ImagePath $isoPath
        Pause
        return
    }

    # Kiểm tra ổ X đã tồn tại chưa
    $volX = Get-Volume -DriveLetter X -ErrorAction SilentlyContinue
    if ($volX) {
        # Format lại ổ X nếu cần
        try {
            Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
            Dism /Apply-Image /ImageFile:$bootWimPath /Index:1 /ApplyDir:"X:\"
            bcdboot X:\windows
            bcdedit /set "{current}" bootmenupolicy legacy
            Write-Host "✅ Hoàn tất cài đặt WinPE vào ổ X."
        } catch {
            Write-Host "❌ Lỗi khi cài đặt WinPE vào ổ X: $_"
        }
    } else {
        Write-Host "⚠️ Không tìm thấy ổ X để cài WinPE. Bạn cần tạo hoặc gán ổ X trước."
    }

    # Dismount ISO
    Dismount-DiskImage -ImagePath $isoPath
}
catch {
    Write-Host "❌ Đã xảy ra lỗi: $_"
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
    Pause
}

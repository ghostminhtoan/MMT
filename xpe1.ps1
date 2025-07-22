# Biến kiểm soát việc có tạo ổ X hay không
$createX = $false

# Bước 1: Hỏi có tạo ổ X không?
$confirm = Read-Host "Bạn có muốn tạo ổ X không? (y/n)"
if ($confirm -eq 'y') {
    $createX = $true
}

# Nếu tạo ổ X thì cần thu nhỏ một ổ khác
if ($createX) {
    # Bước 2: Hỏi ổ cần lấy dung lượng để tạo ổ X
    $sourceDrive = Read-Host "Nhập ký tự ổ đĩa cần thu nhỏ (ví dụ: C)"
    $partition = Get-Partition -DriveLetter $sourceDrive.ToUpper()
    if (-not $partition) {
        Write-Host "❌ Không tìm thấy ổ đĩa $sourceDrive"
        Pause
        return
    }

    # Shrink ổ được chọn
    Resize-Partition -DriveLetter $sourceDrive -Size ($partition.Size - 6144MB)

    # Tạo phân vùng mới và gán ký tự X
    $diskList = Get-Disk
    $disk = $null
    foreach ($d in $diskList) {
        if ($d.Number -eq $partition.DiskNumber) {
            $disk = $d
            break
        }
    }

    if (-not $disk) {
        Write-Host "❌ Không xác định được ổ đĩa vật lý để tạo phân vùng."
        Pause
        return
    }

    $newPartition = New-Partition -DiskNumber $disk.Number -Size 6144MB -DriveLetter X
    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false
}

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
        Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false
        Dism /Apply-Image /ImageFile:$bootWimPath /Index:1 /ApplyDir:"X:\"
        bcdboot X:\windows
        bcdedit /set "{current}" bootmenupolicy legacy
        Write-Host "✅ Hoàn tất cài đặt WinPE vào ổ X."
    } else {
        Write-Host "⚠️ Không tìm thấy ổ X để cài WinPE. Bạn cần tạo hoặc gán ổ X trước."
    }

    # Dismount ISO
    Dismount-DiskImage -ImagePath $isoPath
}
catch {
    Write-Host "❌ Đã xảy ra lỗi: $_"
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
}
# Set console properties
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
$font = New-Object System.Management.Automation.Host.Font("Consolas", 24, [System.Windows.FontWeight]::Normal)
$Host.UI.RawUI.Font = $font
Clear-Host

function Show-Menu {
    param (
        [string]$Title = 'Welcome to MMTPE - made by Ma Minh Toàn 1993'
    )
    Clear-Host
    Write-Host "`n================ $Title ================`n"
    Write-Host "1. Tạo và cài windows PE vào ổ X"
    Write-Host "2. Lấy lại dung lượng ổ X"
    Write-Host "0. Ấn 0 để thoát`n"
}

function Create-WinPE {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Tạo và cài windows PE vào ổ X ===`n"
        
        # Biến kiểm soát việc có tạo ổ X hay không
        $createX = $false

        # Bước 1: Hỏi có tạo ổ X không?
        $confirm = Read-Host "Bạn có muốn tạo ổ X không? (y/n/z - z để về menu)"
        if ($confirm -eq 'z') { return }
        if ($confirm -eq 'y') {
            $createX = $true
        }

        # Nếu tạo ổ X thì cần thu nhỏ một ổ khác
        if ($createX) {
            # Bước 2: Hỏi ổ cần lấy dung lượng để tạo ổ X
            $sourceDrive = Read-Host "Nhập ký tự ổ đĩa cần thu nhỏ (ví dụ: C, z để về menu)"
            if ($sourceDrive -eq 'z') { return }
            
            $partition = Get-Partition -DriveLetter $sourceDrive.ToUpper()
            if (-not $partition) {
                Write-Host "❌ Không tìm thấy ổ đĩa $sourceDrive"
                Pause
                continue
            }

            # Kiểm tra dung lượng trước khi shrink
            $requiredSize = 6144MB
            $availableSize = $partition.Size - $partition.SizeNeededForShrink
            
            if ($availableSize -lt $requiredSize) {
                Write-Host "⚠️ Không đủ dung lượng trống để tạo ổ X (cần $($requiredSize/1MB) MB, chỉ có $($availableSize/1MB) MB khả dụng)"
                $createX = $false
                Pause
                continue
            } else {
                try {
                    # Shrink ổ được chọn
                    Resize-Partition -DriveLetter $sourceDrive -Size ($partition.Size - $requiredSize) -ErrorAction Stop

                    # Tạo phân vùng mới và gán ký tự X
                    $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction SilentlyContinue
                    if (-not $disk) {
                        Write-Host "❌ Không xác định được ổ đĩa vật lý để tạo phân vùng."
                        Pause
                        continue
                    }

                    $newPartition = New-Partition -DiskNumber $disk.Number -Size $requiredSize -DriveLetter X -ErrorAction Stop
                    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
                    Write-Host "✅ Đã tạo thành công ổ X với dung lượng $($requiredSize/1MB) MB"
                } catch {
                    Write-Host "❌ Không thể tạo ổ X: $_"
                    $createX = $false
                    Pause
                    continue
                }
            }
        }

        # Bước 3: Hỏi đường dẫn file ISO
        $isoPath = Read-Host "Dán đường dẫn file ISO (ví dụ: D:\win10.iso, z để về menu)"
        if ($isoPath -eq 'z') { return }
        $isoPath = $isoPath.Trim('"')

        if (!(Test-Path $isoPath)) {
            Write-Host "❌ Không tìm thấy file ISO tại $isoPath"
            Pause
            continue
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
                continue
            }

            # Kiểm tra boot.wim
            $bootWimPath = $isoDriveLetter + ":\sources\boot.wim"
            if (!(Test-Path $bootWimPath)) {
                Write-Host "❌ Không tìm thấy \\sources\\boot.wim trong ISO."
                Dismount-DiskImage -ImagePath $isoPath
                Pause
                continue
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
                    Pause
                    return
                } catch {
                    Write-Host "❌ Lỗi khi cài đặt WinPE vào ổ X: $_"
                    Pause
                    continue
                }
            } else {
                Write-Host "⚠️ Không tìm thấy ổ X để cài WinPE. Bạn cần tạo hoặc gán ổ X trước."
                Pause
                continue
            }

            # Dismount ISO
            Dismount-DiskImage -ImagePath $isoPath
        }
        catch {
            Write-Host "❌ Đã xảy ra lỗi: $_"
            Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
            Pause
            continue
        }
    }
}

function Reclaim-Space {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Lấy lại dung lượng ổ X ===`n"
        
        # Bước 1: Hiển thị ổ đĩa
        Write-Host "`n--- DANH SÁCH Ổ ĐĨA HIỆN TẠI ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Ký tự ổ đĩa: $($v.DriveLetter) - Tên hệ thống tệp: $($v.FileSystemLabel) - Không gian còn lại: $($v.SizeRemaining/1GB) GB - Tổng dung lượng: $($v.Size/1GB) GB"
        }

        # Bước 2: Xác nhận xóa ổ X
        $driveLetterToRemove = "X"
        $volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

        if (-not $volumeToRemove) {
            Write-Host "`n⚠️ Không tìm thấy ổ đĩa $driveLetterToRemove. Chuyển sang bước chọn ổ để mở rộng."
            # Bỏ qua bước xóa ổ X và chuyển thẳng đến bước chọn ổ mở rộng
        }
        else {
            Write-Host "`nBạn có chắc chắn muốn xóa ổ $driveLetterToRemove không? DỮ LIỆU SẼ MẤT HOÀN TOÀN! (Y/N/z - z để về menu)"
            $confirm = Read-Host
            if ($confirm -eq "z") { return }
            if ($confirm -eq "Y") {
                $partitionList = Get-Partition
                $diskList = Get-Disk
                $partition = $null
                $disk = $null

                foreach ($p in $partitionList) {
                    if ($p.DriveLetter -eq $driveLetterToRemove) {
                        $partition = $p
                        break
                    }
                }

                foreach ($d in $diskList) {
                    $partitions = Get-Partition -DiskNumber $d.Number
                    foreach ($p in $partitions) {
                        if ($p.DriveLetter -eq $driveLetterToRemove) {
                            $disk = $d
                            break
                        }
                    }
                    if ($disk) { break }
                }

                if ($partition -and $disk) {
                    $partitionNumber = $partition.PartitionNumber
                    $diskNumber = $disk.Number

                    Remove-Partition -DiskNumber $diskNumber -PartitionNumber $partitionNumber -Confirm:$false
                    Write-Host "✅ Đã xóa ổ đĩa $driveLetterToRemove. Không gian trống đã sẵn sàng.`n"
                } else {
                    Write-Host "❌ Không tìm thấy phân vùng hoặc ổ đĩa tương ứng."
                    Pause
                    continue
                }
            } else {
                Write-Host "❌ Hủy thao tác xóa."
                Pause
                continue
            }
        }

        # Bước 3: Chọn ổ cần mở rộng
        Write-Host "`n--- DANH SÁCH Ổ ĐĨA CÒN LẠI ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Ký tự ổ đĩa: $($v.DriveLetter) - Tên hệ thống tệp: $($v.FileSystemLabel) - Không gian còn lại: $($v.SizeRemaining/1GB) GB - Tổng dung lượng: $($v.Size/1GB) GB"
        }

        Write-Host "`nNhập ký tự ổ đĩa bạn muốn mở rộng (VD: C, z để về menu)"
        $targetDriveLetter = Read-Host
        if ($targetDriveLetter -eq 'z') { return }
        
        $partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

        if (!$partitionToExtend) {
            Write-Host "❌ Không tìm thấy ổ $targetDriveLetter."
            Pause
            continue
        }

        # Bước 4: Resize (extend)
        try {
            $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
            Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
            Write-Host "`n✅ Đã mở rộng ổ $targetDriveLetter thành công!"
            Pause
            return
        } catch {
            Write-Host "`n❌ Không thể mở rộng ổ đĩa. Lỗi: $_"
            Pause
            continue
        }
    }
}

# Main program loop
while ($true) {
    Show-Menu
    $selection = Read-Host "Vui lòng chọn"
    
    switch ($selection) {
        '1' { Create-WinPE }
        '2' { Reclaim-Space }
        '0' { exit }
        default {
            Write-Host "Lựa chọn không hợp lệ!"
            Start-Sleep -Seconds 1
        }
    }
}

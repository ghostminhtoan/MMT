# Bước 1: Hiển thị ổ đĩa
Write-Host "`n--- DANH SÁCH Ổ ĐĨA HIỆN TẠI ---"
$volumes = Get-Volume
foreach ($v in $volumes) {
    if ($v.DriveLetter) {
        Write-Host "Ký tự ổ đĩa: $($v.DriveLetter) - Tên hệ thống tệp: $($v.FileSystemLabel) - Không gian còn lại: $($v.SizeRemaining) - Tổng dung lượng: $($v.Size)"
    }
}

# Bước 2: Kiểm tra và xóa ổ X (nếu có)
$driveLetterToRemove = "X"
$volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

if ($volumeToRemove) {
    Write-Host "`n--- XỬ LÝ Ổ ĐĨA $driveLetterToRemove ---"
    Write-Host "Bạn có chắc chắn muốn xóa ổ $driveLetterToRemove không? DỮ LIỆU SẼ MẤT HOÀN TOÀN! (Y/N)"
    $confirm = Read-Host
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
        }
    } else {
        Write-Host "❌ Hủy thao tác xóa ổ $driveLetterToRemove."
    }
} else {
    Write-Host "`nℹ️ Không tìm thấy ổ đĩa $driveLetterToRemove. Tiếp tục với việc mở rộng ổ đĩa..."
}

# Bước 3: Chọn ổ cần mở rộng
Write-Host "`n--- CHỌN Ổ ĐĨA ĐỂ MỞ RỘNG ---"
$volumes = Get-Volume | Where-Object { $_.DriveLetter }
foreach ($v in $volumes) {
    Write-Host "Ký tự ổ đĩa: $($v.DriveLetter) - Tên hệ thống tệp: $($v.FileSystemLabel) - Không gian còn lại: $($v.SizeRemaining) - Tổng dung lượng: $($v.Size)"
}

$targetDriveLetter = Read-Host "`nNhập ký tự ổ đĩa bạn muốn mở rộng (VD: C)"
$partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

if (!$partitionToExtend) {
    Write-Host "❌ Không tìm thấy ổ $targetDriveLetter. Thoát."
    Write-Host "Nhấn phím bất kỳ để thoát..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Bước 4: Resize (extend)
try {
    Write-Host "`n⏳ Đang mở rộng ổ $targetDriveLetter..."
    $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
    Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
    Write-Host "✅ Đã mở rộng ổ $targetDriveLetter thành công!"
} catch {
    Write-Host "`n❌ Không thể mở rộng ổ đĩa. Lỗi: $_"
}

Write-Host "`nNhấn phím bất kỳ để thoát..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

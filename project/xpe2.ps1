# Buoc 1: Hien thi o dia
Write-Host "`n--- DANH SACH O DIA HIEN TAI ---"
$volumes = Get-Volume
foreach ($v in $volumes) {
    Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining) - Tong dung luong: $($v.Size)"
}

# Buoc 2: Xac nhan xoa o X
$driveLetterToRemove = "X"
$volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

if ($volumeToRemove) {
    Write-Host "`nBan co chac chan muon xoa o $driveLetterToRemove khong? DU LIEU SE MAT HOAN TOAN! (Y/N)"
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
            Write-Host "✅ Da xoa o dia $driveLetterToRemove. Khong gian trong da san sang.`n"
        } else {
            Write-Host "❌ Khong tim thay phan vung hoac o dia tuong ung."
            exit
        }
    } else {
        Write-Host "❌ Huy thao tac xoa. Thoat."
        exit
    }
} else {
    Write-Host "`n❌ Khong tim thay o dia $driveLetterToRemove. Thoat."
    exit
}

# Buoc 3: Chon o can mo rong
Write-Host "`n--- DANH SACH O DIA CON LAI ---"
$volumes = Get-Volume
foreach ($v in $volumes) {
    Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining) - Tong dung luong: $($v.Size)"
}

$targetDriveLetter = Read-Host "`nNhap ky tu o dia ban muon mo rong (VD: C)"
$partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

if (!$partitionToExtend) {
    Write-Host "❌ Khong tim thay o $targetDriveLetter. Thoat."
    exit
}

# Buoc 4: Resize (extend)
try {
    $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
    Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
    Write-Host "`n✅ Da mo rong o $targetDriveLetter thanh cong!"
} catch {
    Write-Host "`n❌ Khong the mo rong o dia. Loi: $_"
}

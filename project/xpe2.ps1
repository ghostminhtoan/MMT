# Buoc 1: Hien thi o dia
Write-Host "`n--- DANH SACH O DIA HIEN TAI ---"
$volumes = Get-Volume
foreach ($v in $volumes) {
    if ($v.DriveLetter) {
        Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining) - Tong dung luong: $($v.Size)"
    }
}

# Buoc 2: Kiem tra va xoa o X (neu co)
$driveLetterToRemove = "X"
$volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

if ($volumeToRemove) {
    Write-Host "`n--- XU LY O DIA $driveLetterToRemove ---"
    Write-Host "Ban co chac chan muon xoa o $driveLetterToRemove khong? DU LIEU SE MAT HOAN TOAN! (Y/N)"
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
            Write-Host "Da xoa o dia $driveLetterToRemove. Khong gian trong da san sang.`n"
        } else {
            Write-Host "Khong tim thay phan vung hoac o dia tuong ung."
        }
    } else {
        Write-Host "Huy thao tac xoa o $driveLetterToRemove."
    }
} else {
    Write-Host "`nKhong tim thay o dia $driveLetterToRemove. Tiep tuc voi viec mo rong o dia..."
}

# Buoc 3: Chon o can mo rong
Write-Host "`n--- CHON O DIA DE MO RONG ---"
$volumes = Get-Volume | Where-Object { $_.DriveLetter }
foreach ($v in $volumes) {
    Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining) - Tong dung luong: $($v.Size)"
}

$targetDriveLetter = Read-Host "`nNhap ky tu o dia ban muon mo rong (VD: C)"
$partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

if (!$partitionToExtend) {
    Write-Host "Khong tim thay o $targetDriveLetter. Thoat."
    Write-Host "Nhan phim bat ky de thoat..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Buoc 4: Resize (extend)
try {
    Write-Host "`nDang mo rong o $targetDriveLetter..."
    $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
    Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
    Write-Host "Da mo rong o $targetDriveLetter thanh cong!"
} catch {
    Write-Host "`nKhong the mo rong o dia. Loi: $_"
}

Write-Host "`nNhan phim bat ky de thoat..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

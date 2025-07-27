# Set console properties
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
$font = New-Object System.Management.Automation.Host.Font("Consolas", 24, [System.Windows.FontWeight]::Normal)
$Host.UI.RawUI.Font = $font
Clear-Host

function Show-Menu {
    param (
        [string]$Title = 'Welcome to MMTPE - made by Ma Minh Toan 1993'
    )
    Clear-Host
    Write-Host "`n================ $Title ================`n"
    Write-Host "1. Tao va cai windows PE vao o X"
    Write-Host "2. Lay lai dung luong o X"
    Write-Host "0. An 0 de thoat`n"
}

function Create-WinPE {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Tao va cai windows PE vao o X ===`n"
        
        # Bien kiem soat viec co tao o X hay khong
        $createX = $false

        # Buoc 1: Hoi co tao o X khong?
        $confirm = Read-Host "Ban co muon tao o X khong? (y/n/z - z de ve menu)"
        if ($confirm -eq 'z') { return }
        if ($confirm -eq 'y') {
            $createX = $true
        }

        # Neu tao o X thi can thu nho mot o khac
        if ($createX) {
            # Buoc 2: Hoi o can lay dung luong de tao o X
            $sourceDrive = Read-Host "Nhap ky tu o dia can thu nho (vi du: C, z de ve menu)"
            if ($sourceDrive -eq 'z') { return }
            
            $partition = Get-Partition -DriveLetter $sourceDrive.ToUpper()
            if (-not $partition) {
                Write-Host "❌ Khong tim thay o dia $sourceDrive"
                Pause
                continue
            }

            # Kiem tra dung luong truoc khi shrink
            $requiredSize = 6144MB
            $availableSize = $partition.Size - $partition.SizeNeededForShrink
            
            if ($availableSize -lt $requiredSize) {
                Write-Host "⚠️ Khong du dung luong trong de tao o X (can $($requiredSize/1MB) MB, chi co $($availableSize/1MB) MB kha dung)"
                $createX = $false
                Pause
                continue
            } else {
                try {
                    # Shrink o duoc chon
                    Resize-Partition -DriveLetter $sourceDrive -Size ($partition.Size - $requiredSize) -ErrorAction Stop

                    # Tao phan vung moi va gan ky tu X
                    $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction SilentlyContinue
                    if (-not $disk) {
                        Write-Host "❌ Khong xac dinh duoc o dia vat ly de tao phan vung."
                        Pause
                        continue
                    }

                    $newPartition = New-Partition -DiskNumber $disk.Number -Size $requiredSize -DriveLetter X -ErrorAction Stop
                    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
                    Write-Host "✅ Da tao thanh cong o X voi dung luong $($requiredSize/1MB) MB"
                } catch {
                    Write-Host "❌ Khong the tao o X: $_"
                    $createX = $false
                    Pause
                    continue
                }
            }
        }

        # Buoc 3: Hoi duong dan file ISO
        $isoPath = Read-Host "Dan duong dan file ISO (vi du: D:\win10.iso, z de ve menu)"
        if ($isoPath -eq 'z') { return }
        $isoPath = $isoPath.Trim('"')

        if (!(Test-Path $isoPath)) {
            Write-Host "❌ Khong tim thay file ISO tai $isoPath"
            Pause
            continue
        }

        try {
            # Mount ISO
            $iso = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop
            Start-Sleep -Seconds 2

            # Lay danh sach volume truoc va sau khi mount
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
                Write-Host "❌ Khong lay duoc ky tu o dia ISO. Dam bao ISO da mount dung."
                Dismount-DiskImage -ImagePath $isoPath
                Pause
                continue
            }

            # Kiem tra boot.wim
            $bootWimPath = $isoDriveLetter + ":\sources\boot.wim"
            if (!(Test-Path $bootWimPath)) {
                Write-Host "❌ Khong tim thay \\sources\\boot.wim trong ISO."
                Dismount-DiskImage -ImagePath $isoPath
                Pause
                continue
            }

            # Kiem tra o X da ton tai chua
            $volX = Get-Volume -DriveLetter X -ErrorAction SilentlyContinue
            if ($volX) {
                # Format lai o X neu can
                try {
                    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
                    Dism /Apply-Image /ImageFile:$bootWimPath /Index:1 /ApplyDir:"X:\"
                    bcdboot X:\windows
                    bcdedit /set "{current}" bootmenupolicy legacy
                    Write-Host "✅ Hoan tat cai dat WinPE vao o X."
                    Pause
                    return
                } catch {
                    Write-Host "❌ Loi khi cai dat WinPE vao o X: $_"
                    Pause
                    continue
                }
            } else {
                Write-Host "⚠️ Khong tim thay o X de cai WinPE. Ban can tao hoac gan o X truoc."
                Pause
                continue
            }

            # Dismount ISO
            Dismount-DiskImage -ImagePath $isoPath
        }
        catch {
            Write-Host "❌ Da xay ra loi: $_"
            Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
            Pause
            continue
        }
    }
}

function Reclaim-Space {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Lay lai dung luong o X ===`n"
        
        # Buoc 1: Hien thi o dia
        Write-Host "`n--- DANH SACH O DIA HIEN TAI ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining/1GB) GB - Tong dung luong: $($v.Size/1GB) GB"
        }

        # Buoc 2: Xac nhan xoa o X
        $driveLetterToRemove = "X"
        $volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

        if (-not $volumeToRemove) {
            Write-Host "`n⚠️ Khong tim thay o dia $driveLetterToRemove. Chuyen sang buoc chon o de mo rong."
            # Bo qua buoc xoa o X va chuyen thang den buoc chon o mo rong
        }
        else {
            Write-Host "`nBan co chac chan muon xoa o $driveLetterToRemove khong? DU LIEU SE MAT HOAN TOAN! (Y/N/z - z de ve menu)"
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
                    Write-Host "✅ Da xoa o dia $driveLetterToRemove. Khong gian trong da san sang.`n"
                } else {
                    Write-Host "❌ Khong tim thay phan vung hoac o dia tuong ung."
                    Pause
                    continue
                }
            } else {
                Write-Host "❌ Huy thao tac xoa."
                Pause
                continue
            }
        }

        # Buoc 3: Chon o can mo rong
        Write-Host "`n--- DANH SACH O DIA CON LAI ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Ky tu o dia: $($v.DriveLetter) - Ten he thong tep: $($v.FileSystemLabel) - Khong gian con lai: $($v.SizeRemaining/1GB) GB - Tong dung luong: $($v.Size/1GB) GB"
        }

        Write-Host "`nNhap ky tu o dia ban muon mo rong (VD: C, z de ve menu)"
        $targetDriveLetter = Read-Host
        if ($targetDriveLetter -eq 'z') { return }
        
        $partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

        if (!$partitionToExtend) {
            Write-Host "❌ Khong tim thay o $targetDriveLetter."
            Pause
            continue
        }

        # Buoc 4: Resize (extend)
        try {
            $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
            Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
            Write-Host "`n✅ Da mo rong o $targetDriveLetter thanh cong!"
            Pause
            return
        } catch {
            Write-Host "`n❌ Khong the mo rong o dia. Loi: $_"
            Pause
            continue
        }
    }
}

# Main program loop
while ($true) {
    Show-Menu
    $selection = Read-Host "Vui long chon"
    
    switch ($selection) {
        '1' { Create-WinPE }
        '2' { Reclaim-Space }
        '0' { exit }
        default {
            Write-Host "Lua chon khong hop le!"
            Start-Sleep -Seconds 1
        }
    }
}

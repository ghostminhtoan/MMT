function Get-AvailableDrives {
    # Lay danh sach cac o dia co the thu nho (o fixed, khong phai removable)
    $AvailableDrives = Get-Partition | Where-Object {
        $_.DriveLetter -and
        $_.DriveLetter -ne '' -and
        (Get-Volume -DriveLetter $_.DriveLetter).DriveType -eq 'Fixed'
    } | Select-Object DriveLetter, @{
        Name='SizeGB'
        Expression={[math]::Round(($_.Size / 1GB), 2)}
    }, @{
        Name='FreeSpaceGB'
        Expression={[math]::Round(((Get-Volume -DriveLetter $_.DriveLetter).SizeRemaining / 1GB), 2)}
    }
   
    return $AvailableDrives
}

function Check-XDriveAvailable {
    # Kiem tra xem o X: da duoc su dung chua
    $XDrive = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
    if ($XDrive) {
        Write-Host " O X: da duoc su dung. Ban co muon format va su dung lai o X: khong?" -ForegroundColor Yellow
        $choice = Read-Host "Chon Y de tiep tuc (du lieu se mat) hoac N de huy (Y/N)"
        if ($choice -notmatch '^[Yy]') {
            Write-Host " Huy thao tac..." -ForegroundColor Red
            return $false
        }
       
        # Format o X: de su dung lai
        try {
            Write-Host "Dang format o X:..." -ForegroundColor Yellow
            Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel "WINPE" -Confirm:$false -Force
            Write-Host " Da format lai o X: thanh cong" -ForegroundColor Green
            return $true
        } catch {
            Write-Host " Loi khi format o X: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Create-XDrive {
    param(
        [string]$SourceDrive,
        [int]$SizeGB
    )
   
    # Chuyen doi GB sang MB
    $SizeMB = $SizeGB * 1024
   
    # Kiem tra o nguon co ton tai khong
    $SourcePartition = Get-Partition -DriveLetter $SourceDrive -ErrorAction SilentlyContinue
    if (-not $SourcePartition) {
        Write-Host "Khong tim thay o $SourceDrive" -ForegroundColor Red
        return $false
    }
   
    # Kiem tra dung luong kha dung
    $SourceVolume = Get-Volume -DriveLetter $SourceDrive -ErrorAction SilentlyContinue
    if (-not $SourceVolume) {
        Write-Host "Khong the lay thong tin o $SourceDrive" -ForegroundColor Red
        return $false
    }
   
    $FreeSpaceGB = [math]::Round(($SourceVolume.SizeRemaining / 1GB), 2)
   
    if ($SizeGB -gt $FreeSpaceGB) {
        Write-Host "O $SourceDrive khong du dung luong. Dung luong kha dung: $FreeSpaceGB GB" -ForegroundColor Red
        return $false
    }
   
    try {
        # Thu nho o nguon
        Write-Host "Dang thu nho o $SourceDrive voi $SizeMB MB..." -ForegroundColor Yellow
       
        # Su dung Resize-Partition voi tham so -Size de shrink
        $NewSize = (Get-Partition -DriveLetter $SourceDrive).Size - ($SizeMB * 1MB)
        Resize-Partition -DriveLetter $SourceDrive -Size $NewSize -ErrorAction Stop
        Write-Host " Da thu nho o $SourceDrive thanh cong" -ForegroundColor Green
       
        # Lay thong tin disk va partition sau khi shrink
        $DiskNumber = $SourcePartition.DiskNumber
        Start-Sleep -Seconds 3
       
        # Lay thong tin partition moi nhat (unallocated space)
        $DiskPartitions = Get-Partition -DiskNumber $DiskNumber | Sort-Object PartitionNumber
        $LastPartition = $DiskPartitions | Sort-Object PartitionNumber -Descending | Select-Object -First 1
       
        # Tao phan vung moi tu khong gian chua phan bo
        Write-Host "Dang tao phan vung moi..." -ForegroundColor Yellow
       
        # Su dung diskpart de tao partition (dang tin cay hon)
        $DiskPartScript = @"
select disk $DiskNumber
create partition primary size=$SizeMB
format fs=ntfs quick label="WINPE"
assign letter=X
exit
"@
       
        $DiskPartScript | diskpart
        Start-Sleep -Seconds 5
       
        # Kiem tra xem o X: da duoc tao thanh cong chua
        $XPartition = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
        if ($XPartition) {
            Write-Host " Da tao thanh cong o X: voi $SizeGB GB tu o $SourceDrive" -ForegroundColor Green
            return $true
        } else {
            Write-Host " Khong the tao o X: bang diskpart" -ForegroundColor Red
            return $false
        }
       
    } catch {
        Write-Host " Loi khi tao o X: $($_.Exception.Message)" -ForegroundColor Red
       
        # Kiem tra va khoi phuc dung luong neu co phan vung trong
        try {
            $Disk = Get-Disk -Number $SourcePartition.DiskNumber
            $Partitions = Get-Partition -DiskNumber $SourcePartition.DiskNumber | Sort-Object PartitionNumber
           
            foreach ($Partition in $Partitions) {
                $SupportedSize = Get-PartitionSupportedSize -InputObject $Partition -ErrorAction SilentlyContinue
                if ($SupportedSize -and $Partition.Size -lt $SupportedSize.SizeMax) {
                    try {
                        Write-Host "Dang khoi phuc dung luong cho partition $($Partition.PartitionNumber)..." -ForegroundColor Yellow
                        Resize-Partition -InputObject $Partition -Size $SupportedSize.SizeMax -ErrorAction Stop
                        Write-Host " Da khoi phuc dung luong thanh cong" -ForegroundColor Green
                        break
                    } catch {
                        Write-Host " Khong the khoi phuc dung luong: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        } catch {
            Write-Host " Loi khi khoi phuc dung luong: $($_.Exception.Message)" -ForegroundColor Red
        }
       
        return $false
    }
}

function Mount-WindowsISO {
    param(
        [string]$ISOPath
    )
   
    if (-not (Test-Path $ISOPath)) {
        Write-Host " File ISO khong ton tai: $ISOPath" -ForegroundColor Red
        return $null
    }
   
    try {
        Write-Host "Dang mount file ISO..." -ForegroundColor Yellow
        $MountResult = Mount-DiskImage -ImagePath $ISOPath -PassThru
        Start-Sleep -Seconds 3
        $DriveLetter = (Get-DiskImage -ImagePath $ISOPath | Get-Volume).DriveLetter
       
        Write-Host " Da mount ISO thanh cong vao o $DriveLetter" -ForegroundColor Green
        return $DriveLetter
       
    } catch {
        Write-Host " Loi khi mount ISO: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Apply-WinPE {
    param(
        [string]$ISODrive,
        [string]$TargetDrive
    )
   
    try {
        Write-Host "Dang tim kiem file .wim trong ISO..." -ForegroundColor Yellow
        # Tim tat ca file .wim trong ISO, loai tru install.esd va install.wim
        $WimFiles = Get-ChildItem -Path "${ISODrive}:\" -Recurse -Include *.wim | 
                    Where-Object { $_.Name -notlike "install.esd" -and $_.Name -notlike "install.wim" }
       
        if ($WimFiles.Count -eq 0) {
            Write-Host " Khong tim thay file .wim hop le trong ISO (loai tru install.esd va install.wim)" -ForegroundColor Red
            return $false
        }
       
        # Chon file .wim dau tien tim thay
        $WimPath = $WimFiles[0].FullName
        Write-Host " Da tim thay file .wim: $WimPath" -ForegroundColor Green
       
        # Liet ke cac index trong file .wim
        Write-Host "Dang lay danh sach index trong file .wim..." -ForegroundColor Yellow
        $imageInfo = dism /get-wiminfo /wimfile:"$WimPath" | Select-String "Index :"
        $indexes = $imageInfo | ForEach-Object { $_ -replace "Index : ", "" } | ForEach-Object { [int]$_.Trim() }
       
        if ($indexes.Count -eq 0) {
            Write-Host " Khong tim thay index nao trong file .wim" -ForegroundColor Red
            return $false
        }
       
        # Hien thi danh sach index
        Write-Host "`nDanh sach index trong file .wim:" -ForegroundColor Yellow
        foreach ($index in $indexes) {
            $indexInfo = dism /get-wiminfo /wimfile:"$WimPath" /index:$index | Select-String "Name :"
            $indexName = if ($indexInfo) { $indexInfo -replace "Name : ", "" } else { "Khong co ten" }
            Write-Host "Index $index : $indexName"
        }
       
        # Cho nguoi dung chon index
        do {
            $selectedIndex = Read-Host "`nChon index de ap dung (nhap so)"
            if ($indexes -notcontains $selectedIndex) {
                Write-Host " Index khong hop le. Vui long chon mot index tu danh sach tren." -ForegroundColor Red
                $isValidIndex = $false
            } else {
                $isValidIndex = $true
            }
        } while (-not $isValidIndex)
       
        # Kiem tra xem o X: co ton tai khong
        if (-not (Test-Path "${TargetDrive}:\")) {
            Write-Host " O $TargetDrive khong ton tai" -ForegroundColor Red
            return $false
        }
       
        # Ap dung image WinPE voi index da chon
        $TargetPath = "${TargetDrive}:\"
        Write-Host "Dang ap dung image tu $WimPath (Index: $selectedIndex) vao $TargetPath..." -ForegroundColor Yellow
       
        # Tao duong dan tam thoi cho log DISM
        $logPath = "$env:TEMP\dism_apply_image.log"
       
        # Chay dism voi log de theo doi tien do
        $dismProcess = Start-Process -FilePath "dism.exe" -ArgumentList "/apply-image /imagefile:`"$WimPath`" /index:$selectedIndex /applydir:`"$TargetPath`" /logpath:`"$logPath`"" -PassThru -NoNewWindow
       
        # Theo doi log file de tinh toan phan tram
        while (-not $dismProcess.HasExited) {
            if (Test-Path $logPath) {
                $logContent = Get-Content $logPath -Raw -ErrorAction SilentlyContinue
                if ($logContent -match "(\d+\.\d+)%") {
                    $percentComplete = $matches[1]
                    Write-Progress -Activity "Dang ap dung WinPE image" -Status "Tien do: $percentComplete%" -PercentComplete $percentComplete
                }
            }
            Start-Sleep -Milliseconds 500
        }
       
        # Kiem tra ket qua DISM
        if ($dismProcess.ExitCode -eq 0) {
            Write-Progress -Activity "Dang ap dung WinPE image" -Status "Hoan tat" -Completed
            Write-Host " Da ap dung WinPE thanh cong" -ForegroundColor Green
            return $true
        } else {
            Write-Host " Loi khi ap dung WinPE. Ma loi: $($dismProcess.ExitCode)" -ForegroundColor Red
            return $false
        }
       
    } catch {
        Write-Host " Loi khi ap dung WinPE: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        # Xoa file log tam thoi
        if (Test-Path $logPath) {
            Remove-Item $logPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Setup-BootEnvironment {
    param(
        [string]$TargetDrive
    )
   
    try {
        Write-Host "Dang thiet lap moi truong khoi dong..." -ForegroundColor Yellow
       
        # Kiem tra xem thu muc windows co ton tai khong
        if (-not (Test-Path "${TargetDrive}:\windows")) {
            Write-Host " Thu muc windows khong ton tai tren o $TargetDrive" -ForegroundColor Red
            return $false
        }
       
        # Su dung bcdboot de tao boot files
        $TargetPath = "${TargetDrive}:\windows"
        bcdboot $TargetPath
       
        if ($LASTEXITCODE -eq 0) {
            # Thiet lap boot menu legacy
            bcdedit /set {current} bootmenupolicy legacy
           
            Write-Host " Da thiet lap moi truong khoi dong thanh cong" -ForegroundColor Green
            return $true
        } else {
            Write-Host " Loi khi thiet lap boot environment. Ma loi: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
       
    } catch {
        Write-Host " Loi khi thiet lap boot environment: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main script execution
Write-Host "=== SCRIPT TAO O DIA WINPE ===`n" -ForegroundColor Cyan
# Kiem tra quyen administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host " Vui long chay script voi quyen Administrator!" -ForegroundColor Red
    exit
}
# Kiem tra o X: co san khong
if (-not (Check-XDriveAvailable)) {
    exit
}
# Kiem tra neu o X da ton tai thi bo qua buoc tao o
$XDriveExists = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
$SkipCreateXDrive = $false
if ($XDriveExists) {
    Write-Host " O X: da ton tai, bo qua buoc tao o dia" -ForegroundColor Green
    $SkipCreateXDrive = $true
} else {
    # Hien thi danh sach o dia co the thu nho
    Write-Host "`nDanh sach o dia co the thu nho:" -ForegroundColor Yellow
    $AvailableDrives = Get-AvailableDrives
    $AvailableDrives | Format-Table -AutoSize
    # Hoi o dia nguon de thu nho
    do {
        $SourceDrive = Read-Host "`nChon o dia de thu nho (nhap ky tu o dia, vi du: C)"
        $SourceDrive = $SourceDrive.ToUpper()
       
        # Kiem tra o dia co ton tai va co the thu nho khong
        $SelectedDrive = $AvailableDrives | Where-Object { $_.DriveLetter -eq $SourceDrive }
        if (-not $SelectedDrive) {
            Write-Host " O dia khong hop le hoac khong the thu nho. Vui long chon tu danh sach tren." -ForegroundColor Red
            $IsValidDrive = $false
        } else {
            Write-Host " Da chon o $SourceDrive - Dung luong trong: $($SelectedDrive.FreeSpaceGB) GB" -ForegroundColor Green
            $IsValidDrive = $true
        }
    } while (-not $IsValidDrive)
    # Hoi dung luong voi de nghi lon hon 6GB
    do {
        $SizeInput = Read-Host "Nhap dung luong cho o X: (GB - de nghi lon hon 6GB)"
        $SizeGB = 0
        if ([int]::TryParse($SizeInput, [ref]$SizeGB)) {
            # Parse thanh cong
            if ($SizeGB -lt 6) {
                Write-Host " De nghi dung luong lon hon 6GB!" -ForegroundColor Yellow
            }
           
            # Kiem tra dung luong co du khong
            $SelectedDrive = $AvailableDrives | Where-Object { $_.DriveLetter -eq $SourceDrive }
            if ($SizeGB -gt $SelectedDrive.FreeSpaceGB) {
                Write-Host " Dung luong vuot qua kha dung ($($SelectedDrive.FreeSpaceGB) GB)" -ForegroundColor Red
                $SizeGB = 0
            }
        } else {
            Write-Host " Vui long nhap so hop le!" -ForegroundColor Red
            $SizeGB = 0
        }
    } while ($SizeGB -lt 1)
    # Tao o X:
    if (-not (Create-XDrive -SourceDrive $SourceDrive -SizeGB $SizeGB)) {
        Write-Host " Khong the tiep tuc do loi tao o dia" -ForegroundColor Red
        exit
    }
}
# Buoc 3: Hoi duong dan file ISO
$isoPath = Read-Host "Dan duong dan file ISO (vi du: D:\win10.iso)"
$isoPath = $isoPath.Trim('"')
if (!(Test-Path $isoPath)) {
    Write-Host " Khong tim thay file ISO tai $isoPath"
    Pause
    return
}
try {
    # Mount ISO
    $isoDriveLetter = Mount-WindowsISO -ISOPath $isoPath
    if (-not $isoDriveLetter) {
        Write-Host " Khong the mount ISO." -ForegroundColor Red
        Pause
        return
    }
    # Kiem tra o X da ton tai chua
    $volX = Get-Volume -DriveLetter X -ErrorAction SilentlyContinue
    if ($volX) {
        # Format lai o X neu can
        try {
            Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
            # Ap dung WinPE
            if (-not (Apply-WinPE -ISODrive $isoDriveLetter -TargetDrive 'X')) {
                Write-Host " Loi khi ap dung WinPE vao o X." -ForegroundColor Red
                Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
                Pause
                return
            }
            # Thiet lap moi truong khoi dong
            if (-not (Setup-BootEnvironment -TargetDrive 'X')) {
                Write-Host " Loi khi thiet lap moi truong khoi dong." -ForegroundColor Red
                Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
                Pause
                return
            }
            Write-Host " Hoan tat cai dat WinPE vao o X." -ForegroundColor Green
        } catch {
            Write-Host " Loi khi cai dat WinPE vao o X: $_" -ForegroundColor Red
        }
    } else {
        Write-Host " Khong tim thay o X de cai WinPE. Ban can tao hoac gan o X truoc." -ForegroundColor Red
    }
    # Dismount ISO
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
}
catch {
    Write-Host " Da xay ra loi: $_" -ForegroundColor Red
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
    Pause
}

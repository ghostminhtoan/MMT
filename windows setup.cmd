@echo off
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo.
echo ==============================
echo    WINDOWS INSTALLATION TOOL
echo ==============================
echo.
echo 1. Bat dau cai dat Windows
echo 2. Thoat
echo.
set /p choice="Lua chon cua ban (1-2, z de quay ve menu): "

if "%choice%"=="1" goto INSTALL_WINDOWS
if "%choice%"=="2" exit
if "%choice%"=="z" goto MAIN_MENU
echo Lua chon khong hop le, vui long thu lai...
pause
goto MAIN_MENU

:INSTALL_WINDOWS
cls
echo.
echo ==============================
echo    CAI DAT WINDOWS
echo ==============================
echo.

:SELECT_INSTALL_DRIVE
echo Chon o dia de cai dat Windows:
echo.
for /f "tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description^,size ^| find "Fixed"') do (
    set drive=%%a
    set size=%%b
    set size=!size:~0,-9!
    set /a sizeGB=!size!/1073741824
    echo !drive! - !sizeGB! GB
)
echo.
set /p install_drive="Nhap o dia (vi du: C, D,...), z de quay ve: "
if "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    echo O dia khong ton tai!
    pause
    goto SELECT_INSTALL_DRIVE
)

:ASK_FORMAT
echo.
set /p format_drive="Ban co muon format o dia %install_drive%: khong? (y/n, z de quay ve): "
if "%format_drive%"=="z" goto MAIN_MENU
if /i "%format_drive%"=="y" (
    echo Dang format o dia %install_drive%:...
    format %install_drive%: /FS:NTFS /Q /Y
    if errorlevel 1 (
        echo Co loi xay ra khi format!
        pause
        goto ASK_FORMAT
    )
    echo Format thanh cong!
) else if /i not "%format_drive%"=="n" (
    echo Lua chon khong hop le!
    goto ASK_FORMAT
)

:SELECT_ISO_FILE
echo.
echo Hay chon file ISO Windows:
set "iso_path="
for /f "delims=" %%I in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $openFileDialog.Filter = 'ISO files (*.iso)|*.iso|All files (*.*)|*.*'; $openFileDialog.Title = 'Chon file ISO Windows'; if($openFileDialog.ShowDialog() -eq 'OK') { Write-Output $openFileDialog.FileName }"') do set "iso_path=%%I"

if not defined iso_path (
    echo Khong co file ISO nao duoc chon!
    pause
    goto SELECT_ISO_FILE
)

echo.
echo Thong tin cai dat:
echo O dia: %install_drive%:
echo File ISO: %iso_path%
echo.

set /p confirm="Ban co chac chan muon cai dat? (y/n, z de quay ve): "
if "%confirm%"=="z" goto MAIN_MENU
if /i "%confirm%"=="y" (
    echo Dang giai nen file ISO...
    powershell Mount-DiskImage -ImagePath "%iso_path%"
    
    for /f "tokens=1" %%d in ('powershell "(Get-DiskImage -ImagePath \"%iso_path%\").DriveLetter"') do set "iso_drive=%%d"
    
    echo Dang cai dat Windows tu %iso_drive%: vao %install_drive%:...
    xcopy %iso_drive%:\*.* %install_drive%:\ /E /H /K
    
    echo Cai dat hoan tat!
    pause
) else (
    echo Da huy qua trinh cai dat!
    pause
)

goto MAIN_MENU

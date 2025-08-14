@echo off
setlocal enabledelayedexpansion
color 0a
cls

:: Hàm hiển thị hộp thoại chọn file
:FileBrowser
set "file_path="
for /f "delims=" %%I in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $openFileDialog.Filter = 'WIM files (*.wim)|*.wim|All files (*.*)|*.*'; $openFileDialog.Title = 'Chọn file install.wim'; if($openFileDialog.ShowDialog() -eq 'OK') { Write-Output $openFileDialog.FileName }"') do set "file_path=%%I"
exit /b

:: Hàm hiển thị hộp thoại chọn ổ đĩa
:DriveBrowser
set "selected_drive="
for /f "delims=" %%D in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Chọn ổ đĩa cài đặt'; $folderBrowser.RootFolder = 'MyComputer'; if($folderBrowser.ShowDialog() -eq 'OK') { Write-Output $folderBrowser.SelectedPath }"') do set "selected_drive=%%D"
exit /b

:MAIN_MENU
cls
echo.
echo   ==============================
echo      WINDOWS INSTALLATION TOOL
echo   ==============================
echo.
echo   1. Bat dau cai dat Windows
echo   2. Thoat
echo.
set /p choice="   Lua chon cua ban (1-2, z de quay ve menu): "

if "%choice%"=="1" goto INSTALL_WINDOWS
if "%choice%"=="2" exit
if /i "%choice%"=="z" goto MAIN_MENU
echo    Lua chon khong hop le!
timeout /t 2 >nul
goto MAIN_MENU

:INSTALL_WINDOWS
cls
echo.
echo   ==============================
echo      CAI DAT WINDOWS
echo   ==============================
echo.

:SHOW_AVAILABLE_DRIVES
echo   Danh sach o dia kha dung:
echo.
for /f "tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description^,size ^| findstr /v "CD-ROM X:"') do (
    set drive=%%a
    set size=%%b
    if "!size!" neq "" (
        set /a sizeGB=!size!/1073741824
        echo    !drive! - !sizeGB! GB
    ) else (
        echo    !drive! - Kich thuoc khong xac dinh
    )
)
echo.

:SELECT_INSTALL_DRIVE
echo   1. Chon o dia tu danh sach tren (nhap ky tu o dia)
echo   2. Chon o dia bang cua so duyet (khuyen dung)
echo.
set /p drive_choice="   Chon cach thuc (1/2, z de quay ve): "

if /i "%drive_choice%"=="z" goto MAIN_MENU
if "%drive_choice%"=="1" goto MANUAL_DRIVE_SELECT
if "%drive_choice%"=="2" goto GUI_DRIVE_SELECT
echo    Lua chon khong hop le!
goto SELECT_INSTALL_DRIVE

:MANUAL_DRIVE_SELECT
set /p install_drive="   Nhap ky tu o dia (VD: C, D,...), z de quay ve: "
if /i "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    echo    O dia khong ton tai!
    timeout /t 2 >nul
    goto MANUAL_DRIVE_SELECT
)
goto ASK_FORMAT

:GUI_DRIVE_SELECT
call :DriveBrowser
if not defined selected_drive (
    echo    Khong co o dia nao duoc chon!
    timeout /t 2 >nul
    goto SELECT_INSTALL_DRIVE
)
set "install_drive=%selected_drive:~0,1%"
echo    Da chon o dia: %install_drive%:
timeout /t 1 >nul

:ASK_FORMAT
echo.
set /p format_drive="   Ban co muon format o dia %install_drive%: khong? (y/n, z de quay ve): "
if /i "%format_drive%"=="z" goto MAIN_MENU
if /i "%format_drive%"=="y" (
    echo    Dang format o dia %install_drive%:...
    format %install_drive%: /FS:NTFS /Q /Y
    if errorlevel 1 (
        echo    Co loi xay ra khi format!
        timeout /t 2 >nul
        goto ASK_FORMAT
    )
    echo    Format thanh cong!
    timeout /t 2 >nul
) else if /i not "%format_drive%"=="n" (
    echo    Lua chon khong hop le!
    goto ASK_FORMAT
)

:SELECT_WIM_FILE
cls
echo.
echo   ==============================
echo      CHON FILE INSTALL.WIM
echo   ==============================
echo.
echo   HUONG DAN:
echo   1. Chuan bi file ISO Windows
echo   2. Click chuot phai vao file ISO -> Mount
echo   3. Vao thu muc sources cua o dia ao
echo   4. Tim file install.wim
echo   5. Chon file nay trong cua so duyet
echo.
pause

call :FileBrowser
if not defined file_path (
    echo    Khong co file nao duoc chon!
    timeout /t 2 >nul
    goto SELECT_WIM_FILE
)

set "wim_path=%file_path%"
echo    Da chon file: %wim_path%
timeout /t 1 >nul

:CONFIRM_INSTALL
cls
echo.
echo   ==============================
echo      XAC NHAN THONG TIN CAI DAT
echo   ==============================
echo.
echo   O dia cai dat:    %install_drive%:
echo   File WIM:         %wim_path%
echo.
set /p confirm="   Ban co chac chan muon cai dat? (y/n, z de quay ve): "
if /i "%confirm%"=="z" goto MAIN_MENU
if /i "%confirm%"=="n" (
    echo    Da huy qua trinh cai dat!
    timeout /t 2 >nul
    goto MAIN_MENU
)
if /i not "%confirm%"=="y" (
    echo    Lua chon khong hop le!
    timeout /t 2 >nul
    goto CONFIRM_INSTALL
)

:START_INSTALL
echo.
echo   Dang cai dat Windows...
echo   File WIM: %wim_path%
echo   O dia: %install_drive%:
echo.

dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%install_drive%:\

if errorlevel 1 (
    echo    Co loi xay ra trong qua trinh cai dat!
    echo    Ma loi: %errorlevel%
    pause
    goto MAIN_MENU
)

echo.
echo   Da cai dat thanh cong!
echo   Dang tao boot sector...
bootsect /nt60 %install_drive%: /force /mbr

echo.
echo   Hoan tat qua trinh cai dat!
timeout /t 3 >nul
goto MAIN_MENU

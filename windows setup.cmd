@echo off
setlocal enabledelayedexpansion
color 0a
cls

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

:SHOW_DRIVES
echo   Danh sach o dia kha dung:
echo.
for /f "tokens=1-3 delims= " %%a in ('wmic logicaldisk where "DriveType=3" get caption^,size^,description /format:list ^| find "="') do (
    set drive_%%a=%%b
)
for /f "tokens=2 delims==" %%d in ('set drive_') do (
    set "drive=%%d"
    if /i not "!drive!"=="X:" (
        if defined drive_!drive! (
            set /a sizeGB=drive_!drive!/1073741824 2>nul
            echo    !drive! - !sizeGB! GB
        ) else (
            echo    !drive! - Kich thuoc khong xac dinh
        )
    )
)
echo.

:SELECT_DRIVE
set /p install_drive="   Nhap ky tu o dia (VD: C, D,...), z de quay ve: "
if /i "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    echo    O dia khong ton tai!
    timeout /t 2 >nul
    goto SELECT_DRIVE
)

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

:SELECT_WIM
cls
echo.
echo   ==============================
echo      CHON FILE INSTALL.WIM
echo   ==============================
echo.
echo   HUONG DAN:
echo   1. Mount file ISO bang cach:
echo      - Click chuot phai vao file ISO
echo      - Chon "Mount"
echo   2. Mo o dia ao moi xuat hien
echo   3. Di den thu muc \sources
echo   4. Copy duong dan cua file install.wim
echo.
echo   Vi du: E:\sources\install.wim
echo.
set /p wim_path="   Nhap duong dan day du den file install.wim (z de quay ve): "
if /i "%wim_path%"=="z" goto MAIN_MENU
if not exist "%wim_path%" (
    echo    File WIM khong ton tai!
    echo    Vui long kiem tra lai duong dan
    timeout /t 3 >nul
    goto SELECT_WIM
)

:CONFIRM
cls
echo.
echo   ==============================
echo      XAC NHAN CAI DAT
echo   ==============================
echo.
echo   O dia cai dat: %install_drive%:
echo   File WIM:      %wim_path%
echo.
set /p confirm="   Ban co chac chan? (y/n, z de quay ve): "
if /i "%confirm%"=="z" goto MAIN_MENU
if /i "%confirm%"=="n" goto MAIN_MENU
if /i not "%confirm%"=="y" goto CONFIRM

:INSTALL
echo.
echo   Dang cai dat Windows...
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%install_drive%:\

if errorlevel 1 (
    echo    LOI: Cai dat that bai (Ma loi: %errorlevel%)
    pause
    goto MAIN_MENU
)

echo   Tao boot sector...
bootsect /nt60 %install_drive%: /force /mbr
echo.
echo   CAI DAT THANH CONG!
timeout /t 3 >nul
goto MAIN_MENU

@echo off
setlocal enabledelayedexpansion
color 0a
cls

:MAIN_MENU
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

:SELECT_INSTALL_DRIVE
echo   Danh sach o dia kha dung:
echo.
for /f "skip=1 tokens=1,3" %%a in ('wmic logicaldisk get caption^,size^,description ^| find "Fixed"') do (
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
set /p install_drive="   Nhap o dia cai dat (VD: C, D,...), z de quay ve: "
if /i "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    echo    O dia khong ton tai!
    timeout /t 2 >nul
    goto SELECT_INSTALL_DRIVE
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

:SELECT_WIM_FILE
echo.
echo   Hay nhap duong dan day du den file install.wim
echo   Vi du: D:\sources\install.wim
echo   Hoac: X:\path\to\install.wim
echo.
set /p wim_path="   Nhap duong dan file install.wim (z de quay ve): "
if /i "%wim_path%"=="z" goto MAIN_MENU
if not exist "%wim_path%" (
    echo    File WIM khong ton tai!
    echo    Vui long kiem tra lai duong dan
    timeout /t 3 >nul
    goto SELECT_WIM_FILE
)

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

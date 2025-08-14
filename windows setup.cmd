@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Thiết lập màu xanh lá
color 0a
title Windows Installation Script
mode con: cols=80 lines=25

:MAIN_MENU
cls
echo ==============================
echo    WINDOWS INSTALLATION SCRIPT
echo ==============================
echo 1. English
echo 2. Tieng Viet
echo Z. Thoat/Exit
echo ==============================
set /p choice="Select language/Chon ngon ngu (1/2/Z): "

if "%choice%"=="1" (
    set LANG=EN
    goto ENGLISH
) else if "%choice%"=="2" (
    set LANG=VI
    goto VIETNAM
) else if /i "%choice%"=="Z" (
    exit
) else (
    echo Invalid choice/Lua chon khong hop le
    timeout /t 1 >nul
    goto MAIN_MENU
)

:ENGLISH
:SELECT_DRIVE_EN
cls
echo ==============================
echo    SELECT TARGET DRIVE (English)
echo ==============================
echo Available drives (excluding X: and CD-ROM):
echo.

set drive_list=
for /f "tokens=1 delims= " %%a in ('wmic logicaldisk get caption ^| find ":"') do (
    if /i not "%%a"=="X:" (
        echo Drive %%a
        set drive_list=!drive_list! %%a
    )
)

echo.
echo ==============================
set /p target_drive="Enter drive letter (e.g. C:), or Z to return: "
if /i "%target_drive%"=="Z" goto MAIN_MENU

:: Kiểm tra ổ đĩa hợp lệ
echo %drive_list% | find /i "%target_drive%" >nul
if errorlevel 1 (
    echo Invalid drive letter/Loi ky tu o dia
    timeout /t 1 >nul
    goto SELECT_DRIVE_EN
)

goto FORMAT_EN

:FORMAT_EN
cls
echo ==============================
echo    FORMAT OPTION (English)
echo ==============================
echo Selected drive: %target_drive%
echo.
set /p format="Format this drive? (Y/N/Z): "
if /i "%format%"=="Z" goto ENGLISH
if /i "%format%"=="Y" (
    echo Formatting %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Format completed.
) else if /i "%format%"=="N" (
    echo Skipping format.
) else (
    echo Invalid choice/Lua chon khong hop le
    timeout /t 1 >nul
    goto FORMAT_EN
)

:SELECT_WIM_EN
cls
echo ==============================
echo    SELECT INSTALL.WIM (English)
echo ==============================
echo Selected drive: %target_drive%
echo Format option: %format%
echo.
set /p wim_path="Enter path to install.wim, or Z to return: "
if /i "%wim_path%"=="Z" goto FORMAT_EN
if not exist "%wim_path%" (
    echo File not found/Khong tim thay file
    timeout /t 1 >nul
    goto SELECT_WIM_EN
)

:CONFIRM_EN
cls
echo ==============================
echo    CONFIRM INSTALLATION (English)
echo ==============================
echo Target drive: %target_drive%
echo WIM file: %wim_path%
echo.
set /p confirm="Start installation? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_EN
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto ENGLISH
) else (
    echo Invalid choice/Lua chon khong hop le
    timeout /t 1 >nul
    goto CONFIRM_EN
)

:VIETNAM
:SELECT_DRIVE_VI
cls
echo ==============================
echo    CHON O DIA (Tieng Viet)
echo ==============================
echo Cac o dia kha dung (tru X: va CD-ROM):
echo.

set drive_list=
for /f "tokens=1 delims= " %%a in ('wmic logicaldisk get caption ^| find ":"') do (
    if /i not "%%a"=="X:" (
        echo O dia %%a
        set drive_list=!drive_list! %%a
    )
)

echo.
echo ==============================
set /p target_drive="Nhap ky tu o dia (vi du C:), hoac Z de quay ve: "
if /i "%target_drive%"=="Z" goto MAIN_MENU

:: Kiểm tra ổ đĩa hợp lệ
echo %drive_list% | find /i "%target_drive%" >nul
if errorlevel 1 (
    echo Ky tu o dia khong hop le
    timeout /t 1 >nul
    goto SELECT_DRIVE_VI
)

goto FORMAT_VI

:FORMAT_VI
cls
echo ==============================
echo    TUY CHON DINH DANG (Tieng Viet)
echo ==============================
echo O dia da chon: %target_drive%
echo.
set /p format="Dinh dang o dia nay? (Y/N/Z): "
if /i "%format%"=="Z" goto VIETNAM
if /i "%format%"=="Y" (
    echo Dang dinh dang %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Dinh dang hoan tat.
) else if /i "%format%"=="N" (
    echo Bo qua dinh dang.
) else (
    echo Lua chon khong hop le
    timeout /t 1 >nul
    goto FORMAT_VI
)

:SELECT_WIM_VI
cls
echo ==============================
echo    CHON FILE INSTALL.WIM (Tieng Viet)
echo ==============================
echo O dia da chon: %target_drive%
echo Tuy chon dinh dang: %format%
echo.
set /p wim_path="Nhap duong dan toi file install.wim, hoac Z de quay ve: "
if /i "%wim_path%"=="Z" goto FORMAT_VI
if not exist "%wim_path%" (
    echo Khong tim thay file
    timeout /t 1 >nul
    goto SELECT_WIM_VI
)

:CONFIRM_VI
cls
echo ==============================
echo    XAC NHAN CAI DAT (Tieng Viet)
echo ==============================
echo O dia: %target_drive%
echo File WIM: %wim_path%
echo.
set /p confirm="Bat dau cai dat? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_VI
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto VIETNAM
) else (
    echo Lua chon khong hop le
    timeout /t 1 >nul
    goto CONFIRM_VI
)

:INSTALL
cls
echo.
echo Starting installation/Bat dau cai dat...
echo Applying Windows image...

dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%target_drive%\

echo.
echo Installation completed/Cai dat hoan tat!
echo.
pause
exit

@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Thiết lập màu xanh lá
color 0a
title Windows Installation Script
mode con: cols=100 lines=30

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
    timeout /t 2 >nul
    goto MAIN_MENU
)

:ENGLISH
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo.
echo STEP 1: SELECT TARGET DRIVE
echo (Press Z to return to menu)
echo ==============================
echo List of available drives:
echo (excluding X: and CD drives)
echo.

set count=0
for /f "skip=1 tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description 2^>nul') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. Drive: %%a
            )
        )
    )
)

if %count% equ 0 (
    echo No available drives found!
    echo Khong tim thay o dia nao!
    pause
    goto MAIN_MENU
)

:SELECT_DRIVE_EN
echo.
set /p drive_num="Select drive number (1-%count%), or Z to return: "
if /i "%drive_num%"=="Z" goto MAIN_MENU
if %drive_num% lss 1 (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
if %drive_num% gtr %count% (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
set target_drive=!drive[%drive_num%]!
goto FORMAT_EN

:FORMAT_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo Selected Drive: %target_drive%
echo.
echo STEP 2: FORMAT OPTION
echo (Press Z to return to drive selection)
echo ==============================
set /p format="Format the drive %target_drive%? (Y/N/Z): "
if /i "%format%"=="Z" goto ENGLISH
if /i "%format%"=="Y" (
    echo Formatting drive %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Format completed.
) else if /i "%format%"=="N" (
    echo Skipping format.
) else (
    echo Invalid choice. Please enter Y, N or Z.
    goto FORMAT_EN
)
goto SELECT_WIM_EN

:SELECT_WIM_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo Selected Drive: %target_drive%
echo Format Option: %format%
echo.
echo STEP 3: SELECT INSTALL.WIM
echo (Press Z to return to format option)
echo ==============================
echo.
set /p wim_path="Enter path to install.wim (e.g., D:\sources\install.wim), or Z to return: "
if /i "%wim_path%"=="Z" goto FORMAT_EN
if not exist "%wim_path%" (
    echo File not found. Please try again.
    goto SELECT_WIM_EN
)
goto CONFIRM_EN

:CONFIRM_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo INSTALLATION SUMMARY
echo (Press Z to return to WIM selection)
echo ==============================
echo Target Drive: %target_drive%
echo Format Drive: %format%
echo WIM Location: %wim_path%
echo.
set /p confirm="Start installation? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_EN
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto ENGLISH
) else (
    echo Invalid choice. Please enter Y, N or Z.
    goto CONFIRM_EN
)

:VIETNAM
cls
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo.
echo BUOC 1: CHON O DIA
echo (Nhan Z de quay ve menu)
echo ==============================
echo Danh sach o dia kha dung:
echo (khong bao gom o X: va o CD)
echo.

set count=0
for /f "skip=1 tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description 2^>nul') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. O dia: %%a
            )
        )
    )
)

if %count% equ 0 (
    echo No available drives found!
    echo Khong tim thay o dia nao!
    pause
    goto MAIN_MENU
)

:SELECT_DRIVE_VI
echo.
set /p drive_num="Chon so thu tu o dia (1-%count%), hoac Z de quay ve: "
if /i "%drive_num%"=="Z" goto MAIN_MENU
if %drive_num% lss 1 (
    echo Lua chon khong hop le. Vui long thu lai.
    goto SELECT_DRIVE_VI
)
if %drive_num% gtr %count% (
    echo Lua chon khong hop le. Vui long thu lai.
    goto SELECT_DRIVE_VI
)
set target_drive=!drive[%drive_num%]!
goto FORMAT_VI

:FORMAT_VI
cls
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo O dia da chon: %target_drive%
echo.
echo BUOC 2: TUY CHON DINH DANG
echo (Nhan Z de quay ve chon o dia)
echo ==============================
set /p format="Dinh dang o dia %target_drive%? (Y/N/Z): "
if /i "%format%"=="Z" goto VIETNAM
if /i "%format%"=="Y" (
    echo Dang dinh dang o dia %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Dinh dang hoan tat.
) else if /i "%format%"=="N" (
    echo Bo qua dinh dang.
) else (
    echo Lua chon khong hop le. Vui long nhap Y, N hoac Z.
    goto FORMAT_VI
)
goto SELECT_WIM_VI

:SELECT_WIM_VI
cls
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo O dia da chon: %target_drive%
echo Tuy chon dinh dang: %format%
echo.
echo BUOC 3: CHON FILE INSTALL.WIM
echo (Nhan Z de quay ve tuy chon dinh dang)
echo ==============================
echo.
set /p wim_path="Nhap duong dan den file install.wim (vi du: D:\sources\install.wim), hoac Z de quay ve: "
if /i "%wim_path%"=="Z" goto FORMAT_VI
if not exist "%wim_path%" (
    echo Khong tim thay file. Vui long thu lai.
    goto SELECT_WIM_VI
)
goto CONFIRM_VI

:CONFIRM_VI
cls
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo TOM TAT CAI DAT
echo (Nhan Z de quay ve chon file WIM)
echo ==============================
echo O dia: %target_drive%
echo Dinh dang: %format%
echo Vi tri WIM: %wim_path%
echo.
set /p confirm="Bat dau cai dat? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_VI
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto VIETNAM
) else (
    echo Lua chon khong hop le. Vui long nhap Y, N hoac Z.
    goto CONFIRM_VI
)

:INSTALL
cls
echo.
echo Starting installation/Bat dau cai dat...
echo Using dism to apply the image...

dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%target_drive%\

echo.
echo Installation completed/Cai dat hoan tat!
echo You may now reboot your system/Co the khoi dong lai may.
pause
exit

@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo ==============================
echo    WINDOWS INSTALLATION SCRIPT
echo ==============================
echo 1. English
echo 2. Tieng Viet
echo ==============================
set /p choice="Select language/Chon ngon ngu (1/2): "

if "%choice%"=="1" (
    set LANG=EN
    goto ENGLISH
) else if "%choice%"=="2" (
    set LANG=VI
    goto VIETNAM
) else (
    echo Invalid choice. Please try again.
    echo Lua chon khong hop le. Vui long thu lai.
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
echo ==============================
echo List of available drives:
echo (excluding X: and CD drives)
echo.

set count=0
for /f "skip=1 tokens=1,2,3,4 delims= " %%a in ('wmic logicaldisk get caption^,description^,size^,volumename') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. Drive: %%a ^(%%b^) - Volume: %%d - Size: %%c bytes
            )
        )
    )
)

:SELECT_DRIVE_EN
set /p drive_num="Select drive number (1-%count%): "
if %drive_num% lss 1 (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
if %drive_num% gtr %count% (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
set target_drive=!drive[%drive_num%]!

:FORMAT_EN
echo.
echo ==============================
echo STEP 2: FORMAT OPTION
echo ==============================
set /p format="Format the drive %target_drive%? (Y/N): "
if /i "%format%"=="Y" (
    echo Formatting drive %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Format completed.
) else if /i "%format%"=="N" (
    echo Skipping format.
) else (
    echo Invalid choice. Please enter Y or N.
    goto FORMAT_EN
)

:SELECT_WIM_EN
echo.
echo ==============================
echo STEP 3: SELECT INSTALL.WIM
echo ==============================
echo.
set /p wim_path="Enter path to install.wim (e.g., D:\sources\install.wim): "
if not exist "%wim_path%" (
    echo File not found. Please try again.
    goto SELECT_WIM_EN
)

:CONFIRM_EN
echo.
echo ==============================
echo INSTALLATION SUMMARY
echo ==============================
echo Target Drive: %target_drive%
echo Format Drive: %format%
echo WIM Location: %wim_path%
echo.
set /p confirm="Start installation? (Y/N): "
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto ENGLISH
) else (
    echo Invalid choice. Please enter Y or N.
    goto CONFIRM_EN
)

:VIETNAM
cls
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo.
echo BUOC 1: CHON O DIA
echo ==============================
echo Danh sach o dia kha dung:
echo (khong bao gom o X: va o CD)
echo.

set count=0
for /f "skip=1 tokens=1,2,3,4 delims= " %%a in ('wmic logicaldisk get caption^,description^,size^,volumename') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. O dia: %%a ^(%%b^) - Ten: %%d - Dung luong: %%c bytes
            )
        )
    )
)

:SELECT_DRIVE_VI
set /p drive_num="Chon so thu tu o dia (1-%count%): "
if %drive_num% lss 1 (
    echo Lua chon khong hop le. Vui long thu lai.
    goto SELECT_DRIVE_VI
)
if %drive_num% gtr %count% (
    echo Lua chon khong hop le. Vui long thu lai.
    goto SELECT_DRIVE_VI
)
set target_drive=!drive[%drive_num%]!

:FORMAT_VI
echo.
echo ==============================
echo BUOC 2: TUY CHON DINH DANG
echo ==============================
set /p format="Dinh dang o dia %target_drive%? (Y/N): "
if /i "%format%"=="Y" (
    echo Dang dinh dang o dia %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Dinh dang hoan tat.
) else if /i "%format%"=="N" (
    echo Bo qua dinh dang.
) else (
    echo Lua chon khong hop le. Vui long nhap Y hoac N.
    goto FORMAT_VI
)

:SELECT_WIM_VI
echo.
echo ==============================
echo BUOC 3: CHON FILE INSTALL.WIM
echo ==============================
echo.
set /p wim_path="Nhap duong dan den file install.wim (vi du: D:\sources\install.wim): "
if not exist "%wim_path%" (
    echo Khong tim thay file. Vui long thu lai.
    goto SELECT_WIM_VI
)

:CONFIRM_VI
echo.
echo ==============================
echo TOM TAT CAI DAT
echo ==============================
echo O dia: %target_drive%
echo Dinh dang: %format%
echo Vi tri WIM: %wim_path%
echo.
set /p confirm="Bat dau cai dat? (Y/N): "
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto VIETNAM
) else (
    echo Lua chon khong hop le. Vui long nhap Y hoac N.
    goto CONFIRM_VI
)

:INSTALL
echo.
echo Starting installation/Bat dau cai dat...
echo Using dism to apply the image...

dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%target_drive%\

echo.
echo Installation completed/Cai dat hoan tat!
echo You may now reboot your system/Co the khoi dong lai may.
pause
exit

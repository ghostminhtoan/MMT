@echo off
setlocal enabledelayedexpansion
color 0a
cls

:: Kiểm tra WinPE
wpeutil UpdateBootInfo >nul 2>&1
if not errorlevel 1 set WINPE=YES

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

:SELECT_ISO_FILE
echo.
echo   Hay nhap duong dan den file ISO Windows
echo   Vi du: D:\win10.iso
echo.
set /p iso_path="   Nhap duong dan (z de quay ve): "
if /i "%iso_path%"=="z" goto MAIN_MENU
if not exist "%iso_path%" (
    echo    File ISO khong ton tai!
    timeout /t 2 >nul
    goto SELECT_ISO_FILE
)

:MOUNT_ISO_WINPE
if defined WINPE (
    echo    Dang mount file ISO (phuong phap WinPE)...
    
    :: Tạo ổ đĩa ảo bằng ImDisk
    for /f "tokens=2 delims==" %%d in ('wmic volume get DriveLetter /value ^| findstr /r /v "^$"') do (
        set "last_drive=%%d"
    )
    set /a next_drive=!last_drive:~0,1!+1
    set "mount_drive=!next_drive!:"
    
    imdisk -a -f "%iso_path%" -m %mount_drive% >nul 2>&1
    if errorlevel 1 (
        echo    Khong the mount ISO bang ImDisk!
        echo    Co the do:
        echo    - Thieu tien ich ImDisk trong WinPE
        echo    - File ISO bi hong
        timeout /t 5 >nul
        goto SELECT_ISO_FILE
    )
    
    set "iso_drive=%mount_drive%"
    goto FIND_WIM_FILE
)

:MOUNT_ISO_NORMAL
echo    Dang mount file ISO (phuong phap DiskPart)...
(
    echo select vdisk file="%iso_path%"
    echo attach vdisk
    echo list volume
    echo exit
) > %temp%\mount_iso.txt

diskpart /s %temp%\mount_iso.txt > %temp%\diskpart_out.txt
del %temp%\mount_iso.txt

for /f "tokens=2,3" %%a in ('type %temp%\diskpart_out.txt ^| find "DVD"') do (
    set "iso_drive=%%a"
)

if not defined iso_drive (
    echo    Khong the mount file ISO!
    echo    Co the do:
    echo    - Khong co quyen Administrator
    echo    - File ISO khong hop le
    timeout /t 5 >nul
    goto SELECT_ISO_FILE
)

:FIND_WIM_FILE
set "wim_path=%iso_drive%:\sources\install.wim"
if not exist "%wim_path%" (
    echo    Khong tim thay file install.wim trong %wim_path%!
    
    if defined WINPE (
        imdisk -d -m %iso_drive% >nul 2>&1
    ) else (
        echo select vdisk file="%iso_path%" > %temp%\unmount.txt
        echo detach vdisk >> %temp%\unmount.txt
        echo exit >> %temp%\unmount.txt
        diskpart /s %temp%\unmount.txt
        del %temp%\unmount.txt
    )
    
    timeout /t 2 >nul
    goto SELECT_ISO_FILE
)

:CONFIRM_INSTALL
cls
echo.
echo   ==============================
echo      XAC NHAN THONG TIN CAI DAT
echo   ==============================
echo.
echo   O dia cai dat:    %install_drive%:
echo   File ISO:         %iso_path%
echo   File WIM:         %wim_path%
echo.
set /p confirm="   Ban co chac chan muon cai dat? (y/n, z de quay ve): "
if /i "%confirm%"=="z" goto UNMOUNT_AND_RETURN
if /i "%confirm%"=="n" (
    echo    Da huy qua trinh cai dat!
    goto UNMOUNT_AND_RETURN
)
if /i not "%confirm%"=="y" (
    echo    Lua chon khong hop le!
    timeout /t 2 >nul
    goto CONFIRM_INSTALL
)

:START_INSTALL
echo.
echo   Dang cai dat Windows...
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%install_drive%:\

if errorlevel 1 (
    echo    Co loi xay ra trong qua trinh cai dat!
    pause
    goto UNMOUNT_AND_RETURN
)

echo.
echo   Da cai dat thanh cong!
echo   Dang tao boot sector...
bootsect /nt60 %install_drive%: /force /mbr

:UNMOUNT_AND_RETURN
if defined iso_drive (
    if defined WINPE (
        imdisk -d -m %iso_drive% >nul 2>&1
    ) else (
        echo select vdisk file="%iso_path%" > %temp%\unmount.txt
        echo detach vdisk >> %temp%\unmount.txt
        echo exit >> %temp%\unmount.txt
        diskpart /s %temp%\unmount.txt
        del %temp%\unmount.txt
    )
)

echo.
echo   Hoan tat qua trinh cai dat!
timeout /t 3 >nul
goto MAIN_MENU

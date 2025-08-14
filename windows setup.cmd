@echo off
setlocal enabledelayedexpansion
color 0a
cls

:LANGUAGE_SELECTION
cls
echo.
echo   ==============================
echo      LANGUAGE SELECTION
echo        CHON NGON NGU
echo   ==============================
echo.
echo   1. English
echo   2. Tieng Viet
echo.
set /p lang_choice="   Select language/Chon ngon ngu (1-2): "

if "%lang_choice%"=="1" (
    set lang=en
    goto MAIN_MENU
)
if "%lang_choice%"=="2" (
    set lang=vi
    goto MAIN_MENU
)
echo    Invalid selection/Lua chon khong hop le!
timeout /t 2 >nul
goto LANGUAGE_SELECTION

:MAIN_MENU
cls
echo.
echo   ==============================
if "%lang%"=="en" (
    echo      WINDOWS INSTALLATION TOOL
) else (
    echo      CONG CU CAI DAT WINDOWS
)
echo   ==============================
echo.
if "%lang%"=="en" (
    echo   1. Install Windows
    echo   2. Exit
) else (
    echo   1. Bat dau cai dat Windows
    echo   2. Thoat
)
echo.
if "%lang%"=="en" (
    set /p choice="   Your choice (1-2, z to return to menu): "
) else (
    set /p choice="   Lua chon cua ban (1-2, z de quay ve menu): "
)

if "%choice%"=="1" goto INSTALL_WINDOWS
if "%choice%"=="2" exit
if /i "%choice%"=="z" goto MAIN_MENU
if "%lang%"=="en" (
    echo    Invalid selection!
) else (
    echo    Lua chon khong hop le!
)
timeout /t 2 >nul
goto MAIN_MENU

:INSTALL_WINDOWS
cls
echo.
echo   ==============================
if "%lang%"=="en" (
    echo      INSTALL WINDOWS
) else (
    echo      CAI DAT WINDOWS
)
echo   ==============================
echo.

:SHOW_DRIVES
if "%lang%"=="en" (
    echo   Available drives:
) else (
    echo   Danh sach o dia kha dung:
)
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
            if "%lang%"=="en" (
                echo    !drive! - Size unknown
            ) else (
                echo    !drive! - Kich thuoc khong xac dinh
            )
        )
    )
)
echo.

:SELECT_DRIVE
if "%lang%"=="en" (
    set /p install_drive="   Enter drive letter (e.g. C, D,...), z to return: "
) else (
    set /p install_drive="   Nhap ky tu o dia (VD: C, D,...), z de quay ve: "
)
if /i "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    if "%lang%"=="en" (
        echo    Drive does not exist!
    ) else (
        echo    O dia khong ton tai!
    )
    timeout /t 2 >nul
    goto SELECT_DRIVE
)

:ASK_FORMAT
echo.
if "%lang%"=="en" (
    set /p format_drive="   Format drive %install_drive%:? (y/n, z to return): "
) else (
    set /p format_drive="   Ban co muon format o dia %install_drive%: khong? (y/n, z de quay ve): "
)
if /i "%format_drive%"=="z" goto MAIN_MENU
if /i "%format_drive%"=="y" (
    if "%lang%"=="en" (
        echo    Formatting drive %install_drive%:...
    ) else (
        echo    Dang format o dia %install_drive%:...
    )
    format %install_drive%: /FS:NTFS /Q /Y
    if errorlevel 1 (
        if "%lang%"=="en" (
            echo    Error during formatting!
        ) else (
            echo    Co loi xay ra khi format!
        )
        timeout /t 2 >nul
        goto ASK_FORMAT
    )
    if "%lang%"=="en" (
        echo    Format successful!
    ) else (
        echo    Format thanh cong!
    )
    timeout /t 2 >nul
) else if /i not "%format_drive%"=="n" (
    if "%lang%"=="en" (
        echo    Invalid selection!
    ) else (
        echo    Lua chon khong hop le!
    )
    goto ASK_FORMAT
)

:SELECT_WIM
cls
echo.
echo   ==============================
if "%lang%"=="en" (
    echo      SELECT INSTALL.WIM FILE
) else (
    echo      CHON FILE INSTALL.WIM
)
echo   ==============================
echo.
if "%lang%"=="en" (
    echo   INSTRUCTIONS:
    echo   1. Right-click the ISO file
    echo   2. Select 'Mount' from the context menu
    echo   3. Go to the new virtual drive
    echo   4. Find install.wim in \sources folder
    echo   5. Enter full path (e.g. E:\sources\install.wim)
) else (
    echo   HUONG DAN:
    echo   1. Click chuot phai vao file ISO
    echo   2. Chon 'Mount' tu menu chuot phai
    echo   3. Vao o dia ao moi xuat hien
    echo   4. Tim file install.wim trong thu muc \sources
    echo   5. Nhap duong dan day du (VD: E:\sources\install.wim)
)
echo.
if "%lang%"=="en" (
    set /p wim_path="   Enter install.wim path (z to return): "
) else (
    set /p wim_path="   Nhap duong dan file install.wim (z de quay ve): "
)
if /i "%wim_path%"=="z" goto MAIN_MENU
if not exist "%wim_path%" (
    if "%lang%"=="en" (
        echo    WIM file does not exist!
        echo    Please check the path
    ) else (
        echo    File WIM khong ton tai!
        echo    Vui long kiem tra lai duong dan
    )
    timeout /t 3 >nul
    goto SELECT_WIM
)

:CONFIRM
cls
echo.
echo   ==============================
if "%lang%"=="en" (
    echo      CONFIRM INSTALLATION
) else (
    echo      XAC NHAN CAI DAT
)
echo   ==============================
echo.
if "%lang%"=="en" (
    echo   Installation drive: %install_drive%:
    echo   WIM file:         %wim_path%
) else (
    echo   O dia cai dat: %install_drive%:
    echo   File WIM:      %wim_path%
)
echo.
if "%lang%"=="en" (
    set /p confirm="   Are you sure? (y/n, z to return): "
) else (
    set /p confirm="   Ban co chac chan? (y/n, z de quay ve): "
)
if /i "%confirm%"=="z" goto MAIN_MENU
if /i "%confirm%"=="n" goto MAIN_MENU
if /i not "%confirm%"=="y" goto CONFIRM

:INSTALL
echo.
if "%lang%"=="en" (
    echo   Installing Windows...
) else (
    echo   Dang cai dat Windows...
)
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%install_drive%:\

if errorlevel 1 (
    if "%lang%"=="en" (
        echo    ERROR: Installation failed (Error code: %errorlevel%)
    ) else (
        echo    LOI: Cai dat that bai (Ma loi: %errorlevel%)
    )
    pause
    goto MAIN_MENU
)

if "%lang%"=="en" (
    echo   Creating boot sector...
) else (
    echo   Tao boot sector...
)
bootsect /nt60 %install_drive%: /force /mbr
echo.
if "%lang%"=="en" (
    echo   INSTALLATION SUCCESSFUL!
) else (
    echo   CAI DAT THANH CONG!
)
timeout /t 3 >nul
goto MAIN_MENU

@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo.
echo ==============================
echo    WINDOWS INSTALLATION TOOL
echo    CONG CU CAI DAT WINDOWS
echo ==============================
echo 1. English
echo 2. Tieng Viet
echo.
set /p choice="Select language/Chon ngon ngu: "

if "%choice%"=="1" (
    set lang=en
    goto ENGLISH_MENU
)
if "%choice%"=="2" (
    set lang=vi
    goto VIETNAMESE_MENU
)
goto MAIN_MENU

:ENGLISH_MENU
cls
echo.
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo 1. Select drive to install Windows (check format option)
echo 2. Select install.wim location
echo z. Back to main menu
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" goto EN_DRIVE_SELECT
if "%choice%"=="2" goto EN_WIM_LOCATION
if "%choice%"=="z" goto MAIN_MENU
goto ENGLISH_MENU

:VIETNAMESE_MENU
cls
echo.
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo 1. Chon o dia de cai Windows (co hoi format)
echo 2. Chon vi tri file install.wim
echo z. Tro ve menu chinh
echo.
set /p choice="Nhap lua chon cua ban: "

if "%choice%"=="1" goto VI_DRIVE_SELECT
if "%choice%"=="2" goto VI_WIM_LOCATION
if "%choice%"=="z" goto MAIN_MENU
goto VIETNAMESE_MENU

:EN_DRIVE_SELECT
cls
echo.
echo === AVAILABLE DRIVES ===
echo.
echo Listing all available drives (excluding X: and CD drives):
echo.

set drives_count=0
for /f "tokens=1,2 delims=:" %%a in ('wmic logicaldisk get caption^,drivetype 2^>nul') do (
    if "%%b"=="3" (
        if /i not "%%a"=="X" (
            echo Drive %%a: (Local Disk)
            set /a drives_count+=1
            set drive_!drives_count!=%%a
        )
    )
    if "%%b"=="2" (
        echo Drive %%a: (CD-ROM - Skipped)
    )
)

if %drives_count% equ 0 (
    echo No available drives found!
    pause
    goto ENGLISH_MENU
)

echo.
set /p drive="Enter drive letter to install Windows (e.g. C): "
set drive=%drive:~0,1%
if /i "%drive%"=="X" (
    echo Cannot select X: drive!
    pause
    goto ENGLISH_MENU
)

:: Check if drive exists
set drive_exists=0
for /f "tokens=1 delims==" %%d in ('set drive_') do (
    if /i "!%%d!"=="%drive%" set drive_exists=1
)

if %drive_exists% equ 0 (
    echo Invalid drive selection!
    pause
    goto ENGLISH_MENU
)

echo.
set /p format="Format the drive? (Y/N - Yes/No): "

if /i "%format%"=="Y" (
    echo WARNING: This will erase all data on Drive %drive%:
    set /p confirm="Are you sure? (Y/N): "
    if /i "%confirm%"=="Y" (
        echo Formatting Drive %drive%:...
        REM Add your formatting commands here
    )
)
echo Windows will be installed on Drive %drive%:
pause
goto ENGLISH_MENU

:VI_DRIVE_SELECT
cls
echo.
echo === DANH SACH O DIA ===
echo.
echo Liet ke tat ca o dia co san (tru o X: va o CD):
echo.

set drives_count=0
for /f "tokens=1,2 delims=:" %%a in ('wmic logicaldisk get caption^,drivetype 2^>nul') do (
    if "%%b"=="3" (
        if /i not "%%a"=="X" (
            echo O dia %%a: (O cung)
            set /a drives_count+=1
            set drive_!drives_count!=%%a
        )
    )
    if "%%b"=="2" (
        echo O dia %%a: (CD-ROM - Bo qua)
    )
)

if %drives_count% equ 0 (
    echo Khong tim thay o dia nao!
    pause
    goto VIETNAMESE_MENU
)

echo.
set /p drive="Nhap ky tu o dia de cai Windows (vd: C): "
set drive=%drive:~0,1%
if /i "%drive%"=="X" (
    echo Khong the chon o X:!
    pause
    goto VIETNAMESE_MENU
)

:: Kiem tra o dia co ton tai khong
set drive_exists=0
for /f "tokens=1 delims==" %%d in ('set drive_') do (
    if /i "!%%d!"=="%drive%" set drive_exists=1
)

if %drive_exists% equ 0 (
    echo Lua chon o dia khong hop le!
    pause
    goto VIETNAMESE_MENU
)

echo.
set /p format="Co format o dia khong? (Y/N - Co/Khong): "

if /i "%format%"=="Y" (
    echo CANH BAO: Toan bo du lieu tren o %drive%: se bi xoa
    set /p confirm="Ban co chac chan? (Y/N): "
    if /i "%confirm%"=="Y" (
        echo Dang format o %drive%:...
        REM Them lenh format o day
    )
)
echo Windows se duoc cai dat tren o %drive%:
pause
goto VIETNAMESE_MENU

:EN_WIM_LOCATION
cls
echo.
echo === INSTALL.WIM LOCATION ===
echo Instructions:
echo 1. Right-click the Windows ISO file and select Mount
echo 2. Note the drive letter of the mounted ISO (e.g. E:)
echo 3. The file path will be [Drive]:\sources\install.wim
echo    For example: E:\sources\install.wim
echo.
set /p wim_path="Enter full path to install.wim: "
echo.
echo Install.wim location set to: %wim_path%
pause
goto ENGLISH_MENU

:VI_WIM_LOCATION
cls
echo.
echo === VI TRI FILE INSTALL.WIM ===
echo Huong dan:
echo 1. Nhan chuot phai vao file ISO Windows va chon Mount
echo 2. Ghi nho ky tu o dia cua ISO (vd: E:)
echo 3. Duong dan file se la [O dia]:\sources\install.wim
echo    Vi du: E:\sources\install.wim
echo.
set /p wim_path="Nhap duong dan day du den file install.wim: "
echo.
echo Da thiet lap vi tri install.wim: %wim_path%
pause
goto VIETNAMESE_MENU

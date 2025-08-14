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
echo 1. Select disk to install Windows (check format option)
echo 2. Select install.wim location
echo z. Back to main menu
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" goto EN_DISK_SELECT
if "%choice%"=="2" goto EN_WIM_LOCATION
if "%choice%"=="z" goto MAIN_MENU
goto ENGLISH_MENU

:VIETNAMESE_MENU
cls
echo.
echo ==============================
echo    CAI DAT WINDOWS - TIENG VIET
echo ==============================
echo 1. Chon o cung de cai Windows (co hoi format)
echo 2. Chon vi tri file install.wim
echo z. Tro ve menu chinh
echo.
set /p choice="Nhap lua chon cua ban: "

if "%choice%"=="1" goto VI_DISK_SELECT
if "%choice%"=="2" goto VI_WIM_LOCATION
if "%choice%"=="z" goto MAIN_MENU
goto VIETNAMESE_MENU

:EN_DISK_SELECT
cls
echo.
echo === AVAILABLE DISKS ===
echo.
wmic diskdrive list brief
echo.
set /p disk="Enter disk number to install Windows (e.g. 0): "
echo.
set /p format="Format the disk? (Y/N - Yes/No): "

if /i "%format%"=="Y" (
    echo WARNING: This will erase all data on Disk %disk%
    set /p confirm="Are you sure? (Y/N): "
    if /i "%confirm%"=="Y" (
        echo Formatting Disk %disk%...
        REM Add your formatting commands here
    )
)
echo Windows will be installed on Disk %disk%
pause
goto ENGLISH_MENU

:VI_DISK_SELECT
cls
echo.
echo === DANH SACH O CUNG ===
echo.
wmic diskdrive list brief
echo.
set /p disk="Nhap so o cung de cai Windows (vd: 0): "
echo.
set /p format="Co format o cung khong? (Y/N - Co/Khong): "

if /i "%format%"=="Y" (
    echo CANH BAO: Toan bo du lieu tren O %disk% se bi xoa
    set /p confirm="Ban co chac chan? (Y/N): "
    if /i "%confirm%"=="Y" (
        echo Dang format O %disk%...
        REM Them lenh format o day
    )
)
echo Windows se duoc cai dat tren O %disk%
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

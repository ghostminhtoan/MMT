@echo off
chcp 65001 >nul
cls

:MAIN_MENU
echo.
echo ==============================
echo    WINDOWS INSTALLATION MENU
echo    MENU CAI DAT WINDOWS
echo ==============================
echo 1. English
echo 2. Tieng Viet
echo ==============================
set /p choice="Select your language/Chon ngon ngu (1/2): "

if "%choice%"=="1" goto ENGLISH
if "%choice%"=="2" goto VIETNAMESE
goto MAIN_MENU

:ENGLISH
set lang=EN
set drive_text=Select disk to install Windows (e.g. 0,1,2...)
set format_text=Format this disk? (Y/N)
set format_note=Note: Y=Yes, N=No
set wim_text=Enter path to install.wim file
set wim_guide=Guide: Right-click ISO -> Mount -> Look in mounted drive (e.g. E:\sources\install.wim)
set back_text=Press 'z' to go back
set invalid_text=Invalid choice, please try again
set install_text=Installing Windows...
set success_text=Installation completed successfully!
goto DISK_SELECT

:VIETNAMESE
set lang=VI
set drive_text=Chon o cung de cai Windows (vd: 0,1,2...)
set format_text=Co format o cung nay khong? (Y/N)
set format_note=Chu y: Y=Co, N=Khong
set wim_text=Nhap duong dan toi file install.wim
set wim_guide=Huong dan: Chuot phai vao file ISO -> Mount -> Tim trong o dia vua mount (vd: E:\sources\install.wim)
set back_text=Nhan 'z' de quay lai
set invalid_text=Lua chon khong hop le, vui long thu lai
set install_text=Dang cai dat Windows...
set success_text=Cai dat thanh cong!
goto DISK_SELECT

:DISK_SELECT
cls
echo.
echo ==============================
if "%lang%"=="EN" echo    WINDOWS INSTALLATION - DISK SELECTION
if "%lang%"=="VI" echo    CAI DAT WINDOWS - CHON O CUNG
echo ==============================
echo %drive_text%
echo %back_text%
echo ==============================
diskpart /s "%~dp0list_disks.txt" | find "Disk ###"
set /p disk="Disk number/So thu tu o dia: "

if "%disk%"=="z" goto MAIN_MENU

:FORMAT_PROMPT
cls
echo.
echo ==============================
if "%lang%"=="EN" echo    FORMAT DISK %disk%?
if "%lang%"=="VI" echo    FORMAT O DIA %disk%?
echo ==============================
echo %format_text%
echo %format_note%
echo ==============================
set /p format="(Y/N): "

if /i "%format%"=="z" goto DISK_SELECT
if /i "%format%"=="y" (
    echo select disk %disk% > format.txt
    echo clean >> format.txt
    echo convert gpt >> format.txt
    echo create partition primary >> format.txt
    echo format fs=ntfs quick >> format.txt
    echo active >> format.txt
    echo assign >> format.txt
    diskpart /s format.txt
    del format.txt
) else if /i "%format%" neq "n" (
    echo %invalid_text%
    timeout /t 2 >nul
    goto FORMAT_PROMPT
)

:WIM_SELECT
cls
echo.
echo ==============================
if "%lang%"=="EN" echo    SELECT INSTALL.WIM LOCATION
if "%lang%"=="VI" echo    CHON VI TRI FILE INSTALL.WIM
echo ==============================
echo %wim_text%
echo %wim_guide%
echo %back_text%
echo ==============================
set /p wim_path="Path/Duong dan: "

if "%wim_path%"=="z" goto DISK_SELECT
if not exist "%wim_path%" (
    echo %invalid_text%
    timeout /t 2 >nul
    goto WIM_SELECT
)

:INSTALLATION
cls
echo.
echo ==============================
echo %install_text%
echo ==============================
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:\\.\PhysicalDrive%disk%

echo.
echo ==============================
echo %success_text%
echo ==============================
timeout /t 5
exit

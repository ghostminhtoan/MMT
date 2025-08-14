@echo off
chcp 65001 >nul
cls

:MAIN_MENU
echo.
echo ==============================
echo    WINDOWS INSTALLATION MENU
echo    MENU CAI DẶT WINDOWS
echo ==============================
echo 1. English
echo 2. Tiếng Việt
echo ==============================
set /p choice="Select your language/Chọn ngôn ngữ (1/2): "

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
set drive_text=Chọn ổ cứng để cài Windows (vd: 0,1,2...)
set format_text=Có format ổ cứng này không? (Y/N)
set format_note=Chú ý: Y=Có, N=Không
set wim_text=Nhập đường dẫn tới file install.wim
set wim_guide=Hướng dẫn: Chuột phải vào file ISO -> Mount -> Tìm trong ổ đĩa vừa mount (vd: E:\sources\install.wim)
set back_text=Nhấn 'z' để quay lại
set invalid_text=Lựa chọn không hợp lệ, vui lòng thử lại
set install_text=Đang cài đặt Windows...
set success_text=Cài đặt thành công!
goto DISK_SELECT

:DISK_SELECT
cls
echo.
echo ==============================
if "%lang%"=="EN" echo    WINDOWS INSTALLATION - DISK SELECTION
if "%lang%"=="VI" echo    CÀI ĐẶT WINDOWS - CHỌN Ổ CỨNG
echo ==============================
echo %drive_text%
echo %back_text%
echo ==============================
for /f "tokens=*" %%a in ('diskpart /s "%~dp0list_disks.txt" ^| find "Disk ###"') do (
    echo %%a
)
set /p disk="Disk number/Số thứ tự ổ đĩa: "

if "%disk%"=="z" goto MAIN_MENU

:FORMAT_PROMPT
cls
echo.
echo ==============================
if "%lang%"=="EN" echo    FORMAT DISK %disk%?
if "%lang%"=="VI" echo    FORMAT Ổ ĐĨA %disk%?
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
if "%lang%"=="VI" echo    CHỌN VỊ TRÍ FILE INSTALL.WIM
echo ==============================
echo %wim_text%
echo %wim_guide%
echo %back_text%
echo ==============================
set /p wim_path="Path/Đường dẫn: "

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

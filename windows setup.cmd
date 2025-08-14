@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

:lang_select
cls
echo ================================================
echo Select language / Chọn ngôn ngữ
echo ================================================
echo 1. English
echo 2. Tiếng Việt
echo.
set /p lang=Choice / Lựa chọn: 
if "%lang%"=="1" goto main_menu_en
if "%lang%"=="2" goto main_menu_vi
goto lang_select

:: ========== ENGLISH MENU ==========
:main_menu_en
cls
echo ================================================
echo Windows Installation Tool - ENGLISH
echo ================================================
echo 1. Select target disk to install Windows
echo 2. Select location of install.wim
echo z. Back
echo.
set /p choice=Your choice: 
if /i "%choice%"=="1" goto select_disk_en
if /i "%choice%"=="2" goto select_wim_en
if /i "%choice%"=="z" goto lang_select
goto main_menu_en

:select_disk_en
cls
echo List of disks:
diskpart /s "%~f0".list >nul 2>&1
echo (Dummy) Please manually list disks using diskpart if needed.
set /p disknum=Enter target disk number: 
set /p fmt=Do you want to format the disk? (Y=Yes / N=No): 
if /i "%fmt%"=="y" (
    echo Formatting disk %disknum% ...
    rem put diskpart commands here
) else (
    echo Skipping format.
)
pause
goto main_menu_en

:select_wim_en
cls
echo Instructions:
echo Right-click your Windows ISO, choose "Mount".
echo Find the new drive letter (e.g., E:\).
echo The install.wim will be in E:\sources\install.wim
set /p wimpath=Enter full path to install.wim: 
echo You entered: %wimpath%
pause
goto main_menu_en

:: ========== VIETNAMESE MENU ==========
:main_menu_vi
cls
echo ================================================
echo Công cụ cài đặt Windows - TIẾNG VIỆT
echo ================================================
echo 1. Chọn ổ đĩa để cài Windows
echo 2. Chọn nơi lưu file install.wim
echo z. Quay lại
echo.
set /p choice=Nhập lựa chọn: 
if /i "%choice%"=="1" goto select_disk_vi
if /i "%choice%"=="2" goto select_wim_vi
if /i "%choice%"=="z" goto lang_select
goto main_menu_vi

:select_disk_vi
cls
echo Danh sách ổ đĩa:
diskpart /s "%~f0".list >nul 2>&1
echo (Ví dụ) Hãy dùng lệnh diskpart để xem danh sách ổ đĩa nếu cần.
set /p disknum=Nhập số ổ đĩa: 
set /p fmt=Bạn có muốn format ổ này không? (Y=Đồng ý / N=Không): 
if /i "%fmt%"=="y" (
    echo Đang format ổ %disknum% ...
    rem put diskpart commands here
) else (
    echo Bỏ qua format.
)
pause
goto main_menu_vi

:select_wim_vi
cls
echo Hướng dẫn:
echo Chuột phải file Windows ISO, chọn "Mount".
echo Xem ổ đĩa mới xuất hiện (ví dụ: E:\).
echo File install.wim nằm trong E:\sources\install.wim
set /p wimpath=Nhập đường dẫn đầy đủ tới install.wim: 
echo Bạn đã nhập: %wimpath%
pause
goto main_menu_vi

endlocal
exit /b


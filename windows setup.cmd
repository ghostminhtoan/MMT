@echo off
setlocal enabledelayedexpansion
color 0a
cls

:: Language setting
set lang=EN
if "%1"=="/vi" set lang=VI

:: Language strings
if "%lang%"=="VI" (
    set str_menu_title=~ CÔNG CỤ CÀI ĐẶT WINDOWS ~
    set str_option1=1. Bắt đầu cài đặt
    set str_option2=2. Thoát
    set str_choice=Lựa chọn của bạn (1-2, z để quay về):
    set str_invalid=Lựa chọn không hợp lệ!
    
    set str_install_title=~ CÀI ĐẶT WINDOWS ~
    set str_drive_list=Danh sách ổ đĩa khả dụng:
    set str_drive_size=GB
    set str_unknown_size=Không xác định
    set str_select_drive=Nhập ký tự ổ đĩa (VD: C, D,...), z để quay về:
    set str_invalid_drive=Ổ đĩa không tồn tại!
    
    set str_format=Format ổ đĩa %drive%: không? (y/n, z để quay về):
    set str_formatting=Đang format...
    set str_format_success=Format thành công!
    set str_format_error=Lỗi khi format!
    
    set str_wim_guide=HƯỚNG DẪN:
    set str_wim_step1=1. Click chuột phải vào file ISO
    set str_wim_step2=2. Chọn 'Mount' từ menu
    set str_wim_step3=3. Mở ổ đĩa ảo mới xuất hiện
    set str_wim_step4=4. Tìm file install.wim trong thư mục \sources
    set str_wim_step5=5. Nhập đường dẫn đầy đủ (VD: E:\sources\install.wim)
    set str_wim_prompt=Nhập đường dẫn file install.wim (z để quay về):
    set str_wim_missing=File WIM không tồn tại!
    
    set str_confirm_title=~ XÁC NHẬN CÀI ĐẶT ~
    set str_target_drive=Ổ đĩa đích: 
    set str_wim_file=File WIM:     
    set str_confirm=Xác nhận? (y/n, z để quay về):
    set str_cancel=Đã hủy quá trình!
    
    set str_installing=Đang cài đặt Windows...
    set str_error=LỖI: Cài đặt thất bại (Mã lỗi: %errorlevel%)
    set str_bootsect=Đang tạo boot sector...
    set str_success=CÀI ĐẶT THÀNH CÔNG!
    set str_reboot=Khởi động lại máy? (y/n):
) else (
    set str_menu_title=~ WINDOWS INSTALLATION TOOL ~
    set str_option1=1. Start installation
    set str_option2=2. Exit
    set str_choice=Your choice (1-2, z to return):
    set str_invalid=Invalid choice!
    
    set str_install_title=~ WINDOWS INSTALLATION ~
    set str_drive_list=Available drives:
    set str_drive_size=GB
    set str_unknown_size=Unknown
    set str_select_drive=Enter drive letter (e.g. C, D,...), z to return:
    set str_invalid_drive=Drive doesn't exist!
    
    set str_format=Format drive %drive%: ? (y/n, z to return):
    set str_formatting=Formatting...
    set str_format_success=Format successful!
    set str_format_error=Format error!
    
    set str_wim_guide=INSTRUCTIONS:
    set str_wim_step1=1. Right-click ISO file
    set str_wim_step2=2. Select 'Mount' from menu
    set str_wim_step3=3. Open the new virtual drive
    set str_wim_step4=4. Find install.wim in \sources folder
    set str_wim_step5=5. Enter full path (e.g. E:\sources\install.wim)
    set str_wim_prompt=Enter install.wim path (z to return):
    set str_wim_missing=WIM file not found!
    
    set str_confirm_title=~ INSTALLATION CONFIRMATION ~
    set str_target_drive=Target drive: 
    set str_wim_file=WIM file:     
    set str_confirm=Confirm? (y/n, z to return):
    set str_cancel=Operation cancelled!
    
    set str_installing=Installing Windows...
    set str_error=ERROR: Installation failed (Code: %errorlevel%)
    set str_bootsect=Creating boot sector...
    set str_success=INSTALLATION SUCCESSFUL!
    set str_reboot=Reboot now? (y/n):
)

:MAIN_MENU
cls
echo.
echo   ==============================
echo   %str_menu_title%
echo   ==============================
echo.
echo   %str_option1%
echo   %str_option2%
echo.
set /p choice="   %str_choice% "

if "%choice%"=="1" goto INSTALL_WINDOWS
if "%choice%"=="2" exit
if /i "%choice%"=="z" goto MAIN_MENU
echo    %str_invalid%
timeout /t 2 >nul
goto MAIN_MENU

:INSTALL_WINDOWS
cls
echo.
echo   ==============================
echo   %str_install_title%
echo   ==============================
echo.

:SHOW_DRIVES
echo   %str_drive_list%
echo.
for /f "tokens=1-3 delims= " %%a in ('wmic logicaldisk where "DriveType=3" get caption^,size^,description /format:list ^| find "="') do (
    set drive_%%a=%%b
)
for /f "tokens=2 delims==" %%d in ('set drive_') do (
    set "drive=%%d"
    if /i not "!drive!"=="X:" (
        if defined drive_!drive! (
            set /a sizeGB=drive_!drive!/1073741824 2>nul
            echo    !drive! - !sizeGB! %str_drive_size%
        ) else (
            echo    !drive! - %str_unknown_size%
        )
    )
)
echo.

:SELECT_DRIVE
set /p install_drive="   %str_select_drive% "
if /i "%install_drive%"=="z" goto MAIN_MENU
if not exist %install_drive%:\ (
    echo    %str_invalid_drive%
    timeout /t 2 >nul
    goto SELECT_DRIVE
)

:ASK_FORMAT
echo.
set /p format_drive="   %str_format% "
if /i "%format_drive%"=="z" goto MAIN_MENU
if /i "%format_drive%"=="y" (
    echo    %str_formatting%
    format %install_drive%: /FS:NTFS /Q /Y
    if errorlevel 1 (
        echo    %str_format_error%
        timeout /t 2 >nul
        goto ASK_FORMAT
    )
    echo    %str_format_success%
    timeout /t 2 >nul
) else if /i not "%format_drive%"=="n" (
    goto ASK_FORMAT
)

:SELECT_WIM
cls
echo.
echo   ==============================
echo   %str_wim_guide%
echo   ==============================
echo.
echo   %str_wim_step1%
echo   %str_wim_step2%
echo   %str_wim_step3%
echo   %str_wim_step4%
echo   %str_wim_step5%
echo.
set /p wim_path="   %str_wim_prompt% "
if /i "%wim_path%"=="z" goto MAIN_MENU
if not exist "%wim_path%" (
    echo    %str_wim_missing%
    timeout /t 3 >nul
    goto SELECT_WIM
)

:CONFIRM
cls
echo.
echo   ==============================
echo   %str_confirm_title%
echo   ==============================
echo.
echo   %str_target_drive% %install_drive%:
echo   %str_wim_file% %wim_path%
echo.
set /p confirm="   %str_confirm% "
if /i "%confirm%"=="z" goto MAIN_MENU
if /i "%confirm%"=="n" (
    echo    %str_cancel%
    timeout /t 2 >nul
    goto MAIN_MENU
)
if /i not "%confirm%"=="y" goto CONFIRM

:INSTALL
echo.
echo   %str_installing%
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%install_drive%:\

if errorlevel 1 (
    echo    %str_error%
    pause
    goto MAIN_MENU
)

echo   %str_bootsect%
bootsect /nt60 %install_drive%: /force /mbr
echo.
echo   %str_success%
echo.

:ASK_REBOOT
set /p reboot="   %str_reboot% "
if /i "%reboot%"=="y" (
    wpeutil reboot
) else if /i "%reboot%"=="n" (
    timeout /t 3 >nul
    goto MAIN_MENU
) else (
    goto ASK_REBOOT
)

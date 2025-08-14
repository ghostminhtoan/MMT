@echo off
setlocal enabledelayedexpansion
color 0a
cls

:: ==============================================
:: CẤU HÌNH NGÔN NGỮ (Language Configuration)
:: ==============================================
if "%1"=="/en" (
    set lang=EN
) else (
    set lang=VI
)

:: ==============================================
:: ĐỊNH NGHĨA CHUỖI NGÔN NGỮ (Language Strings)
:: ==============================================
if "%lang%"=="VI" (
    set str_title=~ CÔNG CỤ CÀI ĐẶT WINDOWS ~
    set str_menu1=1. Bắt đầu cài đặt
    set str_menu2=2. Thoát chương trình
    set str_prompt=Lựa chọn của bạn (1-2):
    set str_invalid=Lựa chọn không hợp lệ!
    
    set str_drive_title=~ CHỌN Ổ ĐĨA CÀI ĐẶT ~
    set str_drive_list=Các ổ đĩa hiện có:
    set str_drive_select=Nhập ký tự ổ đĩa (VD: C, D...):
    set str_drive_error=Ổ đĩa không tồn tại!
    
    set str_format=Format ổ đĩa %drive%:? (y/n):
    set str_formatting=Đang thực hiện format...
    set str_format_ok=Format thành công!
    set str_format_fail=Lỗi khi format!
    
    set str_wim_title=~ CHỌN FILE INSTALL.WIM ~
    set str_wim_guide=HƯỚNG DẪN:
    set str_wim_step1=1. Chuột phải vào file ISO -> Mount
    set str_wim_step2=2. Mở ổ đĩa ảo vừa tạo
    set str_wim_step3=3. Vào thư mục \sources
    set str_wim_step4=4. Nhập đường dẫn file install.wim
    set str_wim_example=VD: E:\sources\install.wim
    set str_wim_prompt=Nhập đường dẫn file install.wim:
    set str_wim_error=Không tìm thấy file WIM!
    
    set str_confirm_title=~ XÁC NHẬN CÀI ĐẶT ~
    set str_confirm_drive=Ổ đĩa đích: %drive%:
    set str_confirm_wim=File WIM: %wim%
    set str_confirm_ask=Xác nhận cài đặt? (y/n):
    
    set str_installing=Đang cài đặt Windows...
    set str_error=LỖI: Không thể cài đặt (Mã lỗi: %errorlevel%)
    set str_bootsect=Đang tạo boot sector...
    set str_success=CÀI ĐẶT HOÀN TẤT!
    set str_reboot=Khởi động lại ngay? (y/n):
) else (
    set str_title=~ WINDOWS SETUP TOOL ~
    set str_menu1=1. Start Installation
    set str_menu2=2. Exit
    set str_prompt=Your choice (1-2):
    set str_invalid=Invalid selection!
    
    set str_drive_title=~ SELECT TARGET DRIVE ~
    set str_drive_list=Available drives:
    set str_drive_select=Enter drive letter (e.g. C, D...):
    set str_drive_error=Drive not found!
    
    set str_format=Format drive %drive%:? (y/n):
    set str_formatting=Formatting...
    set str_format_ok=Format successful!
    set str_format_fail=Format failed!
    
    set str_wim_title=~ SELECT INSTALL.WIM ~
    set str_wim_guide=INSTRUCTIONS:
    set str_wim_step1=1. Right-click ISO -> Mount
    set str_wim_step2=2. Open virtual drive
    set str_wim_step3=3. Go to \sources folder
    set str_wim_step4=4. Enter install.wim path
    set str_wim_example=e.g. E:\sources\install.wim
    set str_wim_prompt=Enter install.wim path:
    set str_wim_error=WIM file not found!
    
    set str_confirm_title=~ CONFIRM INSTALLATION ~
    set str_confirm_drive=Target drive: %drive%:
    set str_confirm_wim=WIM file: %wim%
    set str_confirm_ask=Confirm installation? (y/n):
    
    set str_installing=Installing Windows...
    set str_error=ERROR: Installation failed (Code: %errorlevel%)
    set str_bootsect=Creating boot sector...
    set str_success=INSTALLATION COMPLETE!
    set str_reboot=Reboot now? (y/n):
)

:: ==============================================
:: MENU CHÍNH (MAIN MENU)
:: ==============================================
:MAIN_MENU
cls
echo.
echo   ==============================
echo   %str_title%
echo   ==============================
echo.
echo   %str_menu1%
echo   %str_menu2%
echo.
set /p choice="   %str_prompt% "

if "%choice%"=="1" goto DRIVE_SELECT
if "%choice%"=="2" exit
echo    %str_invalid%
timeout /t 2 >nul
goto MAIN_MENU

:: ==============================================
:: CHỌN Ổ ĐĨA (DRIVE SELECTION)
:: ==============================================
:DRIVE_SELECT
cls
echo.
echo   ==============================
echo   %str_drive_title%
echo   ==============================
echo.
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
            echo    !drive! - !sizeGB! GB
        ) else (
            echo    !drive! - Size unknown
        )
    )
)
echo.
:DRIVE_INPUT
set /p drive="   %str_drive_select% "
if not exist %drive%:\ (
    echo    %str_drive_error%
    timeout /t 2 >nul
    goto DRIVE_INPUT
)

:: ==============================================
:: FORMAT Ổ ĐĨA (DRIVE FORMATTING)
:: ==============================================
:DRIVE_FORMAT
echo.
set /p format="   %str_format% "
if /i "%format%"=="y" (
    echo    %str_formatting%
    format %drive%: /FS:NTFS /Q /Y
    if errorlevel 1 (
        echo    %str_format_fail%
        timeout /t 2 >nul
        goto DRIVE_FORMAT
    )
    echo    %str_format_ok%
    timeout /t 2 >nul
) else if /i not "%format%"=="n" (
    goto DRIVE_FORMAT
)

:: ==============================================
:: CHỌN FILE WIM (WIM SELECTION)
:: ==============================================
:WIM_SELECT
cls
echo.
echo   ==============================
echo   %str_wim_title%
echo   ==============================
echo.
echo   %str_wim_guide%
echo   %str_wim_step1%
echo   %str_wim_step2%
echo   %str_wim_step3%
echo   %str_wim_step4%
echo.
echo   %str_wim_example%
echo.
:WIM_INPUT
set /p wim="   %str_wim_prompt% "
if not exist "%wim%" (
    echo    %str_wim_error%
    timeout /t 2 >nul
    goto WIM_INPUT
)

:: ==============================================
:: XÁC NHẬN (CONFIRMATION)
:: ==============================================
:CONFIRM
cls
echo.
echo   ==============================
echo   %str_confirm_title%
echo   ==============================
echo.
echo   %str_confirm_drive%
echo   %str_confirm_wim%
echo.
set /p confirm="   %str_confirm_ask% "
if /i "%confirm%"=="n" goto MAIN_MENU
if /i not "%confirm%"=="y" goto CONFIRM

:: ==============================================
:: CÀI ĐẶT (INSTALLATION)
:: ==============================================
:INSTALL
cls
echo.
echo   %str_installing%
dism /apply-image /imagefile:"%wim%" /index:1 /applydir:%drive%:\

if errorlevel 1 (
    echo    %str_error%
    pause
    goto MAIN_MENU
)

echo   %str_bootsect%
bootsect /nt60 %drive%: /force /mbr
echo.
echo   %str_success%
echo.

:: ==============================================
:: KHỞI ĐỘNG LẠI (REBOOT)
:: ==============================================
:REBOOT
set /p reboot="   %str_reboot% "
if /i "%reboot%"=="y" (
    wpeutil reboot
) else if /i "%reboot%"=="n" (
    timeout /t 3 >nul
    goto MAIN_MENU
) else (
    goto REBOOT
)

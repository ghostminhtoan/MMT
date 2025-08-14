@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Thiết lập màu xanh lá
color 0a
title Windows Installation Script
mode con: cols=100 lines=30

:MAIN_MENU
cls
echo ==============================
echo    WINDOWS INSTALLATION SCRIPT
echo ==============================
echo 1. English
echo 2. Tiếng Việt
echo Z. Thoát/Exit
echo ==============================
set /p choice="Select language/Chọn ngôn ngữ (1/2/Z): "

if "%choice%"=="1" (
    set LANG=EN
    goto ENGLISH
) else if "%choice%"=="2" (
    set LANG=VI
    goto VIETNAM
) else if /i "%choice%"=="Z" (
    exit
) else (
    echo Invalid choice/Lựa chọn không hợp lệ
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
echo (Press Z to return to menu)
echo ==============================
echo List of available drives:
echo (excluding X: and CD drives)
echo.

set count=0
for /f "skip=1 tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description 2^>nul') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. Drive: %%a
            )
        )
    )
)

if %count% equ 0 (
    echo No available drives found!
    echo Không tìm thấy ổ đĩa nào!
    pause
    goto MAIN_MENU
)

:SELECT_DRIVE_EN
echo.
set /p drive_num="Select drive number (1-%count%), or Z to return: "
if /i "%drive_num%"=="Z" goto MAIN_MENU
if %drive_num% lss 1 (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
if %drive_num% gtr %count% (
    echo Invalid selection. Please try again.
    goto SELECT_DRIVE_EN
)
set target_drive=!drive[%drive_num%]!
goto FORMAT_EN

:FORMAT_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo Selected Drive: %target_drive%
echo.
echo STEP 2: FORMAT OPTION
echo (Press Z to return to drive selection)
echo ==============================
set /p format="Format the drive %target_drive%? (Y/N/Z): "
if /i "%format%"=="Z" goto ENGLISH
if /i "%format%"=="Y" (
    echo Formatting drive %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Format completed.
) else if /i "%format%"=="N" (
    echo Skipping format.
) else (
    echo Invalid choice. Please enter Y, N or Z.
    goto FORMAT_EN
)
goto SELECT_WIM_EN

:SELECT_WIM_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo Selected Drive: %target_drive%
echo Format Option: %format%
echo.
echo STEP 3: SELECT INSTALL.WIM
echo (Press Z to return to format option)
echo ==============================
echo.
echo INSTRUCTIONS TO FIND INSTALL.WIM:
echo 1. Right-click on Windows ISO file and select "Mount"
echo 2. A new drive will appear (e.g. E:)
echo 3. The file is typically in E:\sources\install.wim
echo.
set /p wim_path="Enter path to install.wim (e.g., E:\sources\install.wim), or Z to return: "
if /i "%wim_path%"=="Z" goto FORMAT_EN
if not exist "%wim_path%" (
    echo File not found. Please try again.
    goto SELECT_WIM_EN
)
goto CONFIRM_EN

:CONFIRM_EN
cls
echo ==============================
echo    WINDOWS INSTALLATION - ENGLISH
echo ==============================
echo INSTALLATION SUMMARY
echo (Press Z to return to WIM selection)
echo ==============================
echo Target Drive: %target_drive%
echo Format Drive: %format%
echo WIM Location: %wim_path%
echo.
set /p confirm="Start installation? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_EN
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto ENGLISH
) else (
    echo Invalid choice. Please enter Y, N or Z.
    goto CONFIRM_EN
)

:VIETNAM
cls
echo ==============================
echo    CÀI ĐẶT WINDOWS - TIẾNG VIỆT
echo ==============================
echo.
echo BƯỚC 1: CHỌN Ổ ĐĨA
echo (Nhấn Z để quay về menu)
echo ==============================
echo Danh sách ổ đĩa khả dụng:
echo (không bao gồm ổ X: và ổ CD)
echo.

set count=0
for /f "skip=1 tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption^,description 2^>nul') do (
    if "%%a" neq "" (
        if /i not "%%a"=="X:" (
            if /i not "%%b"=="CD-ROM" (
                set /a count+=1
                set drive[!count!]=%%a
                echo !count!. Ổ đĩa: %%a
            )
        )
    )
)

if %count% equ 0 (
    echo No available drives found!
    echo Không tìm thấy ổ đĩa nào!
    pause
    goto MAIN_MENU
)

:SELECT_DRIVE_VI
echo.
set /p drive_num="Chọn số thứ tự ổ đĩa (1-%count%), hoặc Z để quay về: "
if /i "%drive_num%"=="Z" goto MAIN_MENU
if %drive_num% lss 1 (
    echo Lựa chọn không hợp lệ. Vui lòng thử lại.
    goto SELECT_DRIVE_VI
)
if %drive_num% gtr %count% (
    echo Lựa chọn không hợp lệ. Vui lòng thử lại.
    goto SELECT_DRIVE_VI
)
set target_drive=!drive[%drive_num%]!
goto FORMAT_VI

:FORMAT_VI
cls
echo ==============================
echo    CÀI ĐẶT WINDOWS - TIẾNG VIỆT
echo ==============================
echo Ổ đĩa đã chọn: %target_drive%
echo.
echo BƯỚC 2: TÙY CHỌN ĐỊNH DẠNG
echo (Nhấn Z để quay về chọn ổ đĩa)
echo ==============================
set /p format="Định dạng ổ đĩa %target_drive%? (Y/N/Z): "
if /i "%format%"=="Z" goto VIETNAM
if /i "%format%"=="Y" (
    echo Đang định dạng ổ đĩa %target_drive%...
    format %target_drive% /FS:NTFS /Q /Y >nul
    echo Định dạng hoàn tất.
) else if /i "%format%"=="N" (
    echo Bỏ qua định dạng.
) else (
    echo Lựa chọn không hợp lệ. Vui lòng nhập Y, N hoặc Z.
    goto FORMAT_VI
)
goto SELECT_WIM_VI

:SELECT_WIM_VI
cls
echo ==============================
echo    CÀI ĐẶT WINDOWS - TIẾNG VIỆT
echo ==============================
echo Ổ đĩa đã chọn: %target_drive%
echo Tùy chọn định dạng: %format%
echo.
echo BƯỚC 3: CHỌN FILE INSTALL.WIM
echo (Nhấn Z để quay về tùy chọn định dạng)
echo ==============================
echo.
echo HƯỚNG DẪN TÌM FILE INSTALL.WIM:
echo 1. Click chuột phải vào file ISO và chọn "Mount"
echo 2. Một ổ đĩa mới sẽ xuất hiện (ví dụ E:)
echo 3. File cần tìm thường ở vị trí E:\sources\install.wim
echo.
set /p wim_path="Nhập đường dẫn đến file install.wim (ví dụ: E:\sources\install.wim), hoặc Z để quay về: "
if /i "%wim_path%"=="Z" goto FORMAT_VI
if not exist "%wim_path%" (
    echo Không tìm thấy file. Vui lòng thử lại.
    goto SELECT_WIM_VI
)
goto CONFIRM_VI

:CONFIRM_VI
cls
echo ==============================
echo    CÀI ĐẶT WINDOWS - TIẾNG VIỆT
echo ==============================
echo TÓM TẮT CÀI ĐẶT
echo (Nhấn Z để quay về chọn file WIM)
echo ==============================
echo Ổ đĩa: %target_drive%
echo Định dạng: %format%
echo Vị trí WIM: %wim_path%
echo.
set /p confirm="Bắt đầu cài đặt? (Y/N/Z): "
if /i "%confirm%"=="Z" goto SELECT_WIM_VI
if /i "%confirm%"=="Y" (
    goto INSTALL
) else if /i "%confirm%"=="N" (
    goto VIETNAM
) else (
    echo Lựa chọn không hợp lệ. Vui lòng nhập Y, N hoặc Z.
    goto CONFIRM_VI
)

:INSTALL
cls
echo.
echo Starting installation/Bắt đầu cài đặt...
echo Using dism to apply the image...

dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%target_drive%\

echo.
echo Installation completed/Cài đặt hoàn tất!
echo You may now reboot your system/Có thể khởi động lại máy.
pause
exit

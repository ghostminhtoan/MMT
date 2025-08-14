@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Biến ngôn ngữ mặc định
set "LANG=vi"

:MAIN_MENU
cls
echo.
if "%LANG%"=="vi" (
    echo ======================================
    echo    CÔNG CỤ CÀI ĐẶT WINDOWS TRÊN PE
    echo ======================================
    echo.
    echo 1. Chọn ổ cứng để cài Windows
    echo 2. Chọn nơi lưu file install.wim  
    echo 3. Bắt đầu cài đặt Windows
    echo 4. Chuyển sang tiếng Anh ^(English^)
    echo 5. Thoát
    echo.
    echo z. Quay lại menu chính
    echo.
    set /p choice="Nhập lựa chọn của bạn: "
) else (
    echo ======================================
    echo    WINDOWS INSTALLER TOOL FOR PE
    echo ======================================
    echo.
    echo 1. Select hard drive to install Windows
    echo 2. Select install.wim file location
    echo 3. Start Windows installation
    echo 4. Switch to Vietnamese ^(Tiếng Việt^)
    echo 5. Exit
    echo.
    echo z. Return to main menu
    echo.
    set /p choice="Enter your choice: "
)

if /i "%choice%"=="1" goto SELECT_DRIVE
if /i "%choice%"=="2" goto SELECT_WIM
if /i "%choice%"=="3" goto START_INSTALL
if /i "%choice%"=="4" goto SWITCH_LANG
if /i "%choice%"=="5" goto EXIT
if /i "%choice%"=="z" goto MAIN_MENU
goto MAIN_MENU

:SELECT_DRIVE
cls
echo.
if "%LANG%"=="vi" (
    echo =======================================
    echo         CHỌN Ổ CỨNG CÀI WINDOWS
    echo =======================================
    echo.
    echo Danh sách các ổ cứng có sẵn:
    echo.
) else (
    echo =======================================
    echo      SELECT HARD DRIVE FOR WINDOWS
    echo =======================================
    echo.
    echo Available hard drives:
    echo.
)

:: Hiển thị danh sách ổ đĩa
wmic logicaldisk get size,freespace,caption

echo.
if "%LANG%"=="vi" (
    set /p target_drive="Nhập ổ đĩa đích (ví dụ: C:): "
    echo.
    echo Bạn có muốn format ổ đĩa !target_drive! không?
    echo Y ^(Yes - Có^) / N ^(No - Không^)
    set /p format_choice="Lựa chọn: "
) else (
    set /p target_drive="Enter target drive (example: C:): "
    echo.
    echo Do you want to format drive !target_drive!?
    echo Y ^(Yes^) / N ^(No^)
    set /p format_choice="Choice: "
)

if /i "!format_choice!"=="Y" (
    if "%LANG%"=="vi" (
        echo Sẽ format ổ đĩa !target_drive!
        echo CẢNH BÁO: Tất cả dữ liệu sẽ bị xóa!
    ) else (
        echo Will format drive !target_drive!
        echo WARNING: All data will be deleted!
    )
    set "FORMAT_DRIVE=YES"
) else (
    if "%LANG%"=="vi" (
        echo Không format ổ đĩa !target_drive!
    ) else (
        echo Will not format drive !target_drive!
    )
    set "FORMAT_DRIVE=NO"
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lại menu chính
    echo.
    set /p back="Nhấn z để quay lại hoặc Enter để tiếp tục: "
) else (
    echo z. Return to main menu
    echo.
    set /p back="Press z to return or Enter to continue: "
)

if /i "%back%"=="z" goto MAIN_MENU
goto MAIN_MENU

:SELECT_WIM
cls
echo.
if "%LANG%"=="vi" (
    echo =======================================
    echo       CHỌN FILE INSTALL.WIM
    echo =======================================
    echo.
    echo HƯỚNG DẪN:
    echo 1. Chuột phải file ISO Windows
    echo 2. Chọn Mount ^(Gắn kết^)
    echo 3. Tìm ổ đĩa vừa được mount
    echo 4. Nếu là ổ E: thì đường dẫn sẽ là: E:\sources\install.wim
    echo.
    echo Danh sách ổ đĩa hiện tại:
) else (
    echo =======================================
    echo       SELECT INSTALL.WIM FILE
    echo =======================================
    echo.
    echo INSTRUCTIONS:
    echo 1. Right-click Windows ISO file
    echo 2. Select Mount
    echo 3. Find the mounted drive
    echo 4. If it's drive E: then path will be: E:\sources\install.wim
    echo.
    echo Current drive list:
)

echo.
wmic logicaldisk get caption,volumename

echo.
if "%LANG%"=="vi" (
    set /p wim_path="Nhập đường dẫn đầy đủ đến file install.wim: "
) else (
    set /p wim_path="Enter full path to install.wim file: "
)

:: Kiểm tra file tồn tại
if exist "!wim_path!" (
    if "%LANG%"=="vi" (
        echo File install.wim được tìm thấy: !wim_path!
    ) else (
        echo install.wim file found: !wim_path!
    )
) else (
    if "%LANG%"=="vi" (
        echo KHÔNG TÌM THẤY FILE: !wim_path!
        echo Vui lòng kiểm tra lại đường dẫn.
    ) else (
        echo FILE NOT FOUND: !wim_path!
        echo Please check the path again.
    )
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lại menu chính
    echo.
    set /p back="Nhấn z để quay lại hoặc Enter để tiếp tục: "
) else (
    echo z. Return to main menu
    echo.
    set /p back="Press z to return or Enter to continue: "
)

if /i "%back%"=="z" goto MAIN_MENU
goto MAIN_MENU

:START_INSTALL
cls
echo.
if "%LANG%"=="vi" (
    echo =======================================
    echo        BẮT ĐẦU CÀI ĐẶT WINDOWS
    echo =======================================
    echo.
    echo Thông tin cài đặt:
    echo - Ổ đích: !target_drive!
    echo - Format: !FORMAT_DRIVE!
    echo - File WIM: !wim_path!
    echo.
    echo Bạn có chắc chắn muốn bắt đầu cài đặt?
    echo Y ^(Yes - Có^) / N ^(No - Không^)
    set /p confirm="Xác nhận: "
) else (
    echo =======================================
    echo       START WINDOWS INSTALLATION
    echo =======================================
    echo.
    echo Installation info:
    echo - Target drive: !target_drive!
    echo - Format: !FORMAT_DRIVE!
    echo - WIM file: !wim_path!
    echo.
    echo Are you sure you want to start installation?
    echo Y ^(Yes^) / N ^(No^)
    set /p confirm="Confirm: "
)

if /i "!confirm!"=="Y" (
    if "%LANG%"=="vi" (
        echo Bắt đầu quá trình cài đặt...
        echo ^(Đây là demo - thực tế sẽ chạy lệnh DISM^)
        echo dism /apply-image /imagefile:"!wim_path!" /index:1 /applydir:!target_drive!\
    ) else (
        echo Starting installation process...
        echo ^(This is demo - actual command would be DISM^)
        echo dism /apply-image /imagefile:"!wim_path!" /index:1 /applydir:!target_drive!\
    )
) else (
    if "%LANG%"=="vi" (
        echo Hủy cài đặt.
    ) else (
        echo Installation cancelled.
    )
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lại menu chính
    echo.
    set /p back="Nhấn z để quay lại: "
) else (
    echo z. Return to main menu
    echo.
    set /p back="Press z to return: "
)

if /i "%back%"=="z" goto MAIN_MENU
goto MAIN_MENU

:SWITCH_LANG
if "%LANG%"=="vi" (
    set "LANG=en"
) else (
    set "LANG=vi"
)
goto MAIN_MENU

:EXIT
cls
echo.
if "%LANG%"=="vi" (
    echo Cảm ơn bạn đã sử dụng công cụ!
    echo Tạm biệt!
) else (
    echo Thank you for using this tool!
    echo Goodbye!
)
echo.
pause
exit /b

:ERROR
cls
echo.
if "%LANG%"=="vi" (
    echo ĐÃ XẢY RA LỖI!
    echo Vui lòng thử lại.
) else (
    echo AN ERROR OCCURRED!
    echo Please try again.
)
echo.
pause
goto MAIN_MENU

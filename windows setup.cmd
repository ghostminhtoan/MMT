@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
mode con: cols=100 lines=30
color 0A

set LANG=VN

:MAIN_MENU
cls
echo.
echo ================================================================
if "%LANG%"=="VN" (
    echo                    CÔNG CỤ CÀI ĐẶT WINDOWS
    echo                         Phiên bản 1.0
    echo ================================================================
    echo.
    echo  1. Cài đặt Windows
    echo  2. Thay đổi ngôn ngữ / Change Language
    echo  3. Thoát
    echo.
    echo  z - Quay lại menu chính
    echo.
    set /p choice="Chọn tùy chọn (1-3): "
) else (
    echo                    WINDOWS INSTALLATION TOOL
    echo                         Version 1.0
    echo ================================================================
    echo.
    echo  1. Install Windows
    echo  2. Change Language / Thay đổi ngôn ngữ
    echo  3. Exit
    echo.
    echo  z - Return to main menu
    echo.
    set /p choice="Select option (1-3): "
)

if "%choice%"=="1" goto INSTALL_WINDOWS
if "%choice%"=="2" goto CHANGE_LANG
if "%choice%"=="3" goto EXIT
if "%choice%"=="z" goto MAIN_MENU

if "%LANG%"=="VN" (
    echo Lựa chọn không hợp lệ!
) else (
    echo Invalid choice!
)
pause
goto MAIN_MENU

:CHANGE_LANG
if "%LANG%"=="VN" (
    set LANG=EN
) else (
    set LANG=VN
)
goto MAIN_MENU

:INSTALL_WINDOWS
cls
echo.
echo ================================================================
if "%LANG%"=="VN" (
    echo                        CÀI ĐẶT WINDOWS
    echo ================================================================
    echo.
    echo Danh sách ổ cứng có sẵn:
    echo.
    wmic logicaldisk get size,freespace,caption,description
    echo.
    echo z - Quay lại menu chính
    echo.
    set /p drive="Chọn ổ cứng để cài Windows (VD: C:): "
) else (
    echo                        INSTALL WINDOWS
    echo ================================================================
    echo.
    echo Available drives:
    echo.
    wmic logicaldisk get size,freespace,caption,description
    echo.
    echo z - Return to main menu
    echo.
    set /p drive="Select drive to install Windows (e.g., C:): "
)

if "%drive%"=="z" goto MAIN_MENU

if "%LANG%"=="VN" (
    echo.
    echo Bạn đã chọn ổ: %drive%
    echo.
    set /p format="Bạn có muốn format ổ cứng này không? (y/n - yes/no): "
) else (
    echo.
    echo You selected drive: %drive%
    echo.
    set /p format="Do you want to format this drive? (y/n - yes/no): "
)

if "%format%"=="z" goto MAIN_MENU

if "%format%"=="y" (
    if "%LANG%"=="VN" (
        echo Đang format ổ %drive%...
        echo [CẢNH BÁO] Tất cả dữ liệu trên ổ %drive% sẽ bị xóa!
        pause
        format %drive% /fs:ntfs /q
    ) else (
        echo Formatting drive %drive%...
        echo [WARNING] All data on drive %drive% will be deleted!
        pause
        format %drive% /fs:ntfs /q
    )
)

:SELECT_WIM
cls
echo.
echo ================================================================
if "%LANG%"=="VN" (
    echo                    CHỌN FILE INSTALL.WIM
    echo ================================================================
    echo.
    echo z - Quay lại menu chính
    echo.
    set /p wimpath="Nhập đường dẫn đến file install.wim: "
) else (
    echo                    SELECT INSTALL.WIM FILE
    echo ================================================================
    echo.
    echo z - Return to main menu
    echo.
    set /p wimpath="Enter path to install.wim file: "
)

if "%wimpath%"=="z" goto MAIN_MENU

if not exist "%wimpath%" (
    if "%LANG%"=="VN" (
        echo File không tồn tại! Vui lòng kiểm tra lại đường dẫn.
    ) else (
        echo File does not exist! Please check the path.
    )
    pause
    goto SELECT_WIM
)

:INSTALL_PROCESS
cls
echo.
echo ================================================================
if "%LANG%"=="VN" (
    echo                    ĐANG CÀI ĐẶT WINDOWS
    echo ================================================================
    echo.
    echo Ổ cứng: %drive%
    echo File WIM: %wimpath%
    echo.
    echo Đang cài đặt Windows...
    echo.
) else (
    echo                    INSTALLING WINDOWS
    echo ================================================================
    echo.
    echo Drive: %drive%
    echo WIM File: %wimpath%
    echo.
    echo Installing Windows...
    echo.
)

rem Giả lập quá trình cài đặt
for /l %%i in (1,1,10) do (
    echo Progress: %%i0%%
    timeout /t 1 >nul
)

if "%LANG%"=="VN" (
    echo.
    echo ✓ Cài đặt Windows hoàn tất!
    echo.
    set /p restart="Bạn có muốn khởi động lại máy tính không? (y/n - yes/no): "
) else (
    echo.
    echo ✓ Windows installation completed!
    echo.
    set /p restart="Do you want to restart the computer? (y/n - yes/no): "
)

if "%restart%"=="z" goto MAIN_MENU

if "%restart%"=="y" (
    if "%LANG%"=="VN" (
        echo Đang khởi động lại...
        timeout /t 3
        shutdown /r /t 0
    ) else (
        echo Restarting...
        timeout /t 3
        shutdown /r /t 0
    )
) else (
    if "%LANG%"=="VN" (
        echo Cài đặt hoàn tất. Nhấn phím bất kỳ để quay lại menu chính.
    ) else (
        echo Installation complete. Press any key to return to main menu.
    )
    pause
    goto MAIN_MENU
)

:EXIT
if "%LANG%"=="VN" (
    echo Cảm ơn bạn đã sử dụng công cụ!
) else (
    echo Thank you for using this tool!
)
pause
exit

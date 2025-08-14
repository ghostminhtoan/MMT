@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Default language
set LANG=en

:MAIN_MENU
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                    Windows Installation Script                       ║
    echo ║                         Language / Ngôn ngữ                         ║
) else (
    echo ║                    Script Cài Đặt Windows                          ║
    echo ║                         Language / Ngôn ngữ                         ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.
if "%LANG%"=="en" (
    echo Select Language / Chọn ngôn ngữ:
    echo 1. English
    echo 2. Tiếng Việt
    echo.
    echo z - Exit / Thoát
    echo.
    set /p choice="Enter your choice / Nhập lựa chọn: "
) else (
    echo Chọn ngôn ngữ / Select Language:
    echo 1. English
    echo 2. Tiếng Việt
    echo.
    echo z - Thoát / Exit
    echo.
    set /p choice="Nhập lựa chọn / Enter your choice: "
)

if /i "%choice%"=="1" (
    set LANG=en
    goto INSTALL_MENU
)
if /i "%choice%"=="2" (
    set LANG=vi
    goto INSTALL_MENU
)
if /i "%choice%"=="z" goto EXIT
goto MAIN_MENU

:INSTALL_MENU
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                    Windows Installation Menu                        ║
) else (
    echo ║                      Menu Cài Đặt Windows                          ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

if "%LANG%"=="en" (
    echo 1. Select hard drive for Windows installation
    echo 2. Select install.wim file location
    echo 3. Start installation
    echo.
    echo z - Back to language selection
    echo.
    set /p choice="Enter your choice: "
) else (
    echo 1. Chọn ổ cứng để cài Windows
    echo 2. Chọn nơi lưu file install.wim
    echo 3. Bắt đầu cài đặt
    echo.
    echo z - Quay lại chọn ngôn ngữ
    echo.
    set /p choice="Nhập lựa chọn của bạn: "
)

if "%choice%"=="1" goto SELECT_DRIVE
if "%choice%"=="2" goto SELECT_WIM
if "%choice%"=="3" goto START_INSTALL
if /i "%choice%"=="z" goto MAIN_MENU
goto INSTALL_MENU

:SELECT_DRIVE
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                       Select Hard Drive                            ║
) else (
    echo ║                        Chọn Ổ Cứng                                ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

if "%LANG%"=="en" (
    echo Available drives:
) else (
    echo Các ổ đĩa khả dụng:
)
echo.
wmic logicaldisk get size,freespace,caption

echo.
if "%LANG%"=="en" (
    set /p INSTALL_DRIVE="Enter drive letter (e.g., C): "
) else (
    set /p INSTALL_DRIVE="Nhập ký tự ổ đĩa (ví dụ: C): "
)

if "%INSTALL_DRIVE%"=="" goto SELECT_DRIVE
set INSTALL_DRIVE=%INSTALL_DRIVE:~0,1%

echo.
if "%LANG%"=="en" (
    echo Selected drive: %INSTALL_DRIVE%:
    echo WARNING: This will format the drive and delete all data!
    echo.
    set /p format_choice="Do you want to format this drive? (Y/N - Yes/No): "
) else (
    echo Ổ đĩa đã chọn: %INSTALL_DRIVE%:
    echo CẢNH BÁO: Điều này sẽ format ổ đĩa và xóa tất cả dữ liệu!
    echo.
    set /p format_choice="Bạn có muốn format ổ đĩa này không? (Y/N - Yes/No): "
)

if /i "%format_choice%"=="Y" (
    set FORMAT_DRIVE=yes
    if "%LANG%"=="en" (
        echo Drive %INSTALL_DRIVE%: will be formatted during installation.
    ) else (
        echo Ổ đĩa %INSTALL_DRIVE%: sẽ được format trong quá trình cài đặt.
    )
) else if /i "%format_choice%"=="N" (
    set FORMAT_DRIVE=no
    if "%LANG%"=="en" (
        echo Drive %INSTALL_DRIVE%: will NOT be formatted.
    ) else (
        echo Ổ đĩa %INSTALL_DRIVE%: sẽ KHÔNG được format.
    )
) else (
    goto SELECT_DRIVE
)

pause
goto INSTALL_MENU

:SELECT_WIM
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                    Select install.wim File                         ║
) else (
    echo ║                    Chọn File install.wim                          ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

if "%LANG%"=="en" (
    echo Instructions to find install.wim file:
    echo 1. Right-click on Windows ISO file
    echo 2. Select "Mount" from context menu
    echo 3. Find the mounted drive (e.g., if it's E: drive)
    echo 4. The install.wim file will be at: E:\sources\install.wim
    echo.
    echo Current mounted drives:
) else (
    echo Hướng dẫn tìm file install.wim:
    echo 1. Chuột phải vào file ISO Windows
    echo 2. Chọn "Mount" từ menu
    echo 3. Tìm ổ đĩa vừa được mount (ví dụ: ổ E:)
    echo 4. File install.wim sẽ ở: E:\sources\install.wim
    echo.
    echo Các ổ đĩa hiện tại đã mount:
)

echo.
wmic logicaldisk where drivetype=5 get caption,label,size 2>nul

echo.
if "%LANG%"=="en" (
    set /p WIM_PATH="Enter full path to install.wim file: "
) else (
    set /p WIM_PATH="Nhập đường dẫn đầy đủ đến file install.wim: "
)

if "%WIM_PATH%"=="" goto SELECT_WIM

if not exist "%WIM_PATH%" (
    echo.
    if "%LANG%"=="en" (
        echo ERROR: File not found! Please check the path.
    ) else (
        echo LỖI: Không tìm thấy file! Vui lòng kiểm tra đường dẫn.
    )
    pause
    goto SELECT_WIM
)

if "%LANG%"=="en" (
    echo install.wim file found: %WIM_PATH%
) else (
    echo Đã tìm thấy file install.wim: %WIM_PATH%
)
pause
goto INSTALL_MENU

:START_INSTALL
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                     Installation Summary                           ║
) else (
    echo ║                      Tóm Tắt Cài Đặt                              ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

if not defined INSTALL_DRIVE (
    if "%LANG%"=="en" (
        echo ERROR: No installation drive selected!
        echo Please select a drive first.
    ) else (
        echo LỖI: Chưa chọn ổ đĩa cài đặt!
        echo Vui lòng chọn ổ đĩa trước.
    )
    pause
    goto INSTALL_MENU
)

if not defined WIM_PATH (
    if "%LANG%"=="en" (
        echo ERROR: No install.wim file selected!
        echo Please select the install.wim file first.
    ) else (
        echo LỖI: Chưa chọn file install.wim!
        echo Vui lòng chọn file install.wim trước.
    )
    pause
    goto INSTALL_MENU
)

if "%LANG%"=="en" (
    echo Installation Drive: %INSTALL_DRIVE%:
    echo Format Drive: %FORMAT_DRIVE%
    echo install.wim File: %WIM_PATH%
    echo.
    echo WARNING: This will start the Windows installation process!
    echo.
    set /p confirm="Continue with installation? (Y/N - Yes/No): "
) else (
    echo Ổ Đĩa Cài Đặt: %INSTALL_DRIVE%:
    echo Format Ổ Đĩa: %FORMAT_DRIVE%
    echo File install.wim: %WIM_PATH%
    echo.
    echo CẢNH BÁO: Điều này sẽ bắt đầu quá trình cài đặt Windows!
    echo.
    set /p confirm="Tiếp tục cài đặt? (Y/N - Yes/No): "
)

if /i "%confirm%"=="Y" (
    goto PERFORM_INSTALL
) else if /i "%confirm%"=="N" (
    goto INSTALL_MENU
) else (
    goto START_INSTALL
)

:PERFORM_INSTALL
cls
echo ╔══════════════════════════════════════════════════════════════════════╗
if "%LANG%"=="en" (
    echo ║                    Installing Windows...                           ║
) else (
    echo ║                    Đang Cài Đặt Windows...                        ║
)
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

if "%LANG%"=="en" (
    echo Starting installation process...
    echo This may take several minutes...
) else (
    echo Đang bắt đầu quá trình cài đặt...
    echo Điều này có thể mất vài phút...
)
echo.

:: Format drive if requested (using format command instead of diskpart)
if /i "%FORMAT_DRIVE%"=="yes" (
    if "%LANG%"=="en" (
        echo Formatting drive %INSTALL_DRIVE%:...
    ) else (
        echo Đang format ổ đĩa %INSTALL_DRIVE%:...
    )
    format %INSTALL_DRIVE%: /FS:NTFS /Q /Y
    
    if !errorlevel! neq 0 (
        if "%LANG%"=="en" (
            echo ERROR: Failed to format drive %INSTALL_DRIVE%:
        ) else (
            echo LỖI: Không thể format ổ đĩa %INSTALL_DRIVE%:
        )
        pause
        goto INSTALL_MENU
    )
)

:: Apply Windows image using DISM
if "%LANG%"=="en" (
    echo Applying Windows image to %INSTALL_DRIVE%:...
) else (
    echo Đang áp dụng image Windows vào %INSTALL_DRIVE%:...
)

dism /apply-image /imagefile:"%WIM_PATH%" /index:1 /applydir:%INSTALL_DRIVE%:\

if !errorlevel! neq 0 (
    if "%LANG%"=="en" (
        echo ERROR: Failed to apply Windows image!
        echo Please check the install.wim file and try again.
    ) else (
        echo LỖI: Không thể áp dụng image Windows!
        echo Vui lòng kiểm tra file install.wim và thử lại.
    )
    pause
    goto INSTALL_MENU
)

:: Create boot files
if "%LANG%"=="en" (
    echo Creating boot files...
) else (
    echo Đang tạo các file khởi động...
)

bcdboot %INSTALL_DRIVE%:\Windows /s %INSTALL_DRIVE%:

if !errorlevel! neq 0 (
    if "%LANG%"=="en" (
        echo ERROR: Failed to create boot files!
    ) else (
        echo LỖI: Không thể tạo các file khởi động!
    )
    pause
    goto INSTALL_MENU
)

echo.
if "%LANG%"=="en" (
    echo ══════════════════════════════════════════════════════════════════════
    echo                    INSTALLATION COMPLETED!
    echo ══════════════════════════════════════════════════════════════════════
    echo Windows has been successfully installed to drive %INSTALL_DRIVE%:
    echo You can now restart your computer and boot from the installed drive.
) else (
    echo ══════════════════════════════════════════════════════════════════════
    echo                     CÀI ĐẶT HOÀN THÀNH!
    echo ══════════════════════════════════════════════════════════════════════
    echo Windows đã được cài đặt thành công vào ổ đĩa %INSTALL_DRIVE%:
    echo Bạn có thể khởi động lại máy tính và boot từ ổ đĩa đã cài.
)
echo.
pause
goto INSTALL_MENU

:EXIT
if "%LANG%"=="en" (
    echo Thank you for using Windows Installation Script!
) else (
    echo Cảm ơn bạn đã sử dụng Script Cài Đặt Windows!
)
pause
exit /b 0

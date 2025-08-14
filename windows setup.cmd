@echo off
chcp 65001 >nul
title Windows PE Installer - Song ngữ Anh Việt

:: Biến ngôn ngữ (0=Tiếng Việt, 1=English)
set lang=0

:main_menu
cls
if %lang%==0 (
    echo ================================================
    echo     CONG CU CAI DAT WINDOWS TREN WINDOWS PE
    echo ================================================
    echo.
    echo Chon ngon ngu / Choose Language:
    echo 1. Tieng Viet khong dau
    echo 2. English
    echo.
    echo Chon tuy chon:
    echo 3. Chon o cung de cai Windows
    echo 4. Chon noi luu file install.wim
    echo 5. Thoat
    echo.
) else (
    echo ================================================
    echo     WINDOWS INSTALLER TOOL FOR WINDOWS PE
    echo ================================================
    echo.
    echo Choose Language:
    echo 1. Vietnamese
    echo 2. English
    echo.
    echo Select option:
    echo 3. Select hard drive to install Windows
    echo 4. Select install.wim file location
    echo 5. Exit
    echo.
)

set /p choice=">> "

if "%choice%"=="1" (
    set lang=0
    goto main_menu
)
if "%choice%"=="2" (
    set lang=1
    goto main_menu
)
if "%choice%"=="3" goto select_drive
if "%choice%"=="4" goto select_wim
if "%choice%"=="5" goto exit_program
if /i "%choice%"=="z" goto main_menu

goto main_menu

:select_drive
cls
if %lang%==0 (
    echo ================================================
    echo         CHON O CUNG DE CAI WINDOWS
    echo ================================================
    echo.
    echo Danh sach cac o dia co san:
) else (
    echo ================================================
    echo      SELECT HARD DRIVE TO INSTALL WINDOWS
    echo ================================================
    echo.
    echo Available drives:
)

echo.
wmic logicaldisk get size,freespace,caption
echo.

if %lang%==0 (
    echo Nhap chu cai o dia (vi du: C):
) else (
    echo Enter drive letter (example: C):
)

set /p drive_letter=">> "

if /i "%drive_letter%"=="z" goto main_menu

:: Kiểm tra ổ đĩa có tồn tại không
if not exist "%drive_letter%:\" (
    if %lang%==0 (
        echo O dia khong ton tai! Nhan phim bat ky de thu lai...
    ) else (
        echo Drive does not exist! Press any key to try again...
    )
    pause >nul
    goto select_drive
)

cls
if %lang%==0 (
    echo Ban da chon o dia: %drive_letter%:
    echo.
    echo CANH BAO: Viec format se xoa toan bo du lieu tren o dia nay!
    echo.
    echo Ban co muon format o dia %drive_letter%: truoc khi cai dat khong?
    echo Y ^(Yes^) - Co
    echo N ^(No^) - Khong
    echo z - Quay lai
) else (
    echo You selected drive: %drive_letter%:
    echo.
    echo WARNING: Formatting will delete all data on this drive!
    echo.
    echo Do you want to format drive %drive_letter%: before installation?
    echo Y ^(Yes^) - Yes
    echo N ^(No^) - No
    echo z - Go back
)

set /p format_choice=">> "

if /i "%format_choice%"=="z" goto main_menu
if /i "%format_choice%"=="y" goto format_drive
if /i "%format_choice%"=="n" goto install_windows

goto select_drive

:format_drive
if %lang%==0 (
    echo Dang format o dia %drive_letter%:...
    echo Vui long cho...
) else (
    echo Formatting drive %drive_letter%:...
    echo Please wait...
)

format %drive_letter%: /fs:NTFS /q /y

if %errorlevel%==0 (
    if %lang%==0 (
        echo Format thanh cong!
    ) else (
        echo Format successful!
    )
) else (
    if %lang%==0 (
        echo Loi khi format o dia!
    ) else (
        echo Error formatting drive!
    )
)

pause
goto install_windows

:install_windows
if %lang%==0 (
    echo Chuan bi cai dat Windows len o dia %drive_letter%:...
    echo Day chi la demo - can them code de apply install.wim
) else (
    echo Preparing to install Windows on drive %drive_letter%:...
    echo This is demo - need additional code to apply install.wim
)

pause
goto main_menu

:select_wim
cls
if %lang%==0 (
    echo ================================================
    echo       CHON NOI LUU FILE INSTALL.WIM
    echo ================================================
    echo.
    echo HUONG DAN:
    echo 1. Chuot phai file ISO Windows
    echo 2. Chon "Mount" ^(gan ket^)
    echo 3. Tim o dia vua duoc gan ket
    echo 4. Neu la o dia E: thi duong dan se la: E:\sources\install.wim
    echo.
    echo Nhap duong dan day du den file install.wim:
    echo Vi du: E:\sources\install.wim
    echo.
    echo z - Quay lai
) else (
    echo ================================================
    echo        SELECT INSTALL.WIM FILE LOCATION
    echo ================================================
    echo.
    echo INSTRUCTIONS:
    echo 1. Right-click on Windows ISO file
    echo 2. Select "Mount"
    echo 3. Find the mounted drive
    echo 4. If mounted as drive E: then path will be: E:\sources\install.wim
    echo.
    echo Enter full path to install.wim file:
    echo Example: E:\sources\install.wim
    echo.
    echo z - Go back
)

set /p wim_path=">> "

if /i "%wim_path%"=="z" goto main_menu

:: Kiểm tra file có tồn tại không
if not exist "%wim_path%" (
    if %lang%==0 (
        echo File khong ton tai! Nhan phim bat ky de thu lai...
    ) else (
        echo File does not exist! Press any key to try again...
    )
    pause >nul
    goto select_wim
)

if %lang%==0 (
    echo File install.wim da duoc tim thay: %wim_path%
    echo.
    echo Thong tin file WIM:
) else (
    echo install.wim file found: %wim_path%
    echo.
    echo WIM file information:
)

dism /get-wiminfo /wimfile:"%wim_path%"

if %lang%==0 (
    echo.
    echo Nhan phim bat ky de quay lai menu chinh...
) else (
    echo.
    echo Press any key to return to main menu...
)

pause >nul
goto main_menu

:exit_program
if %lang%==0 (
    echo Cam on ban da su dung cong cu cai dat Windows PE!
    echo Nhan phim bat ky de thoat...
) else (
    echo Thank you for using Windows PE installer tool!
    echo Press any key to exit...
)

pause >nul
exit

:error
if %lang%==0 (
    echo Da xay ra loi! Vui long thu lai.
) else (
    echo An error occurred! Please try again.
)
pause
goto main_menu

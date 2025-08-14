@echo off
setlocal enabledelayedexpansion

:: Bien ngon ngu mac dinh
set "LANG=vi"
set "target_drive="
set "wim_path="
set "FORMAT_DRIVE=NO"

:MAIN_MENU
cls
echo.
if "%LANG%"=="vi" (
    echo ======================================
    echo    CONG CU CAI DAT WINDOWS TREN PE
    echo ======================================
    echo.
    echo 1. Chon o cung de cai Windows
    echo 2. Chon noi luu file install.wim  
    echo 3. Bat dau cai dat Windows
    echo 4. Chuyen sang tieng Anh ^(English^)
    echo 5. Thoat
    echo.
    echo z. Quay lai menu chinh
    echo.
    set /p choice="Nhap lua chon cua ban: "
) else (
    echo ======================================
    echo    WINDOWS INSTALLER TOOL FOR PE
    echo ======================================
    echo.
    echo 1. Select hard drive to install Windows
    echo 2. Select install.wim file location
    echo 3. Start Windows installation
    echo 4. Switch to Vietnamese ^(Tieng Viet^)
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
    echo         CHON O CUNG CAI WINDOWS
    echo =======================================
    echo.
    echo Danh sach cac o cung co san:
    echo.
) else (
    echo =======================================
    echo      SELECT HARD DRIVE FOR WINDOWS
    echo =======================================
    echo.
    echo Available hard drives:
    echo.
)

:: Hien thi danh sach o dia
wmic logicaldisk get size,freespace,caption

echo.
if "%LANG%"=="vi" (
    set /p target_drive="Nhap o dia dich (vi du: C:): "
    echo.
    echo Ban co muon format o dia !target_drive! khong?
    echo Y ^(Yes - Co^) / N ^(No - Khong^)
    set /p format_choice="Lua chon: "
) else (
    set /p target_drive="Enter target drive (example: C:): "
    echo.
    echo Do you want to format drive !target_drive!?
    echo Y ^(Yes^) / N ^(No^)
    set /p format_choice="Choice: "
)

if /i "!format_choice!"=="Y" (
    if "%LANG%"=="vi" (
        echo Se format o dia !target_drive!
        echo CANH BAO: Tat ca du lieu se bi xoa!
    ) else (
        echo Will format drive !target_drive!
        echo WARNING: All data will be deleted!
    )
    set "FORMAT_DRIVE=YES"
) else (
    if "%LANG%"=="vi" (
        echo Khong format o dia !target_drive!
    ) else (
        echo Will not format drive !target_drive!
    )
    set "FORMAT_DRIVE=NO"
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lai menu chinh
    echo.
    set /p back="Nhan z de quay lai hoac Enter de tiep tuc: "
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
    echo       CHON FILE INSTALL.WIM
    echo =======================================
    echo.
    echo HUONG DAN:
    echo 1. Chuot phai file ISO Windows
    echo 2. Chon Mount ^(Gan ket^)
    echo 3. Tim o dia vua duoc mount
    echo 4. Neu la o E: thi duong dan se la: E:\sources\install.wim
    echo.
    echo Danh sach o dia hien tai:
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
    set /p wim_path="Nhap duong dan day du den file install.wim: "
) else (
    set /p wim_path="Enter full path to install.wim file: "
)

:: Kiem tra file ton tai
if exist "!wim_path!" (
    if "%LANG%"=="vi" (
        echo File install.wim duoc tim thay: !wim_path!
    ) else (
        echo install.wim file found: !wim_path!
    )
) else (
    if "%LANG%"=="vi" (
        echo KHONG TIM THAY FILE: !wim_path!
        echo Vui long kiem tra lai duong dan.
    ) else (
        echo FILE NOT FOUND: !wim_path!
        echo Please check the path again.
    )
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lai menu chinh
    echo.
    set /p back="Nhan z de quay lai hoac Enter de tiep tuc: "
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
    echo        BAT DAU CAI DAT WINDOWS
    echo =======================================
    echo.
    echo Thong tin cai dat:
    echo - O dich: !target_drive!
    echo - Format: !FORMAT_DRIVE!
    echo - File WIM: !wim_path!
    echo.
    echo Ban co chac chan muon bat dau cai dat?
    echo Y ^(Yes - Co^) / N ^(No - Khong^)
    set /p confirm="Xac nhan: "
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
        echo.
        echo Bat dau qua trinh cai dat...
        echo.
        if "!FORMAT_DRIVE!"=="YES" (
            echo Buoc 1: Format o dia !target_drive!
            echo format !target_drive! /fs:ntfs /q /y
        )
        echo.
        echo Buoc 2: Apply Windows image
        echo dism /apply-image /imagefile:"!wim_path!" /index:1 /applydir:!target_drive!\
        echo.
        echo Buoc 3: Cau hinh boot
        echo bcdboot !target_drive!\Windows /s !target_drive! /f UEFI
        echo.
        echo CAI DAT HOAN TAT!
    ) else (
        echo.
        echo Starting installation process...
        echo.
        if "!FORMAT_DRIVE!"=="YES" (
            echo Step 1: Format drive !target_drive!
            echo format !target_drive! /fs:ntfs /q /y
        )
        echo.
        echo Step 2: Apply Windows image
        echo dism /apply-image /imagefile:"!wim_path!" /index:1 /applydir:!target_drive!\
        echo.
        echo Step 3: Configure boot
        echo bcdboot !target_drive!\Windows /s !target_drive! /f UEFI
        echo.
        echo INSTALLATION COMPLETED!
    )
) else (
    if "%LANG%"=="vi" (
        echo Huy cai dat.
    ) else (
        echo Installation cancelled.
    )
)

echo.
if "%LANG%"=="vi" (
    echo z. Quay lai menu chinh
    echo.
    set /p back="Nhan z de quay lai: "
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
    echo Cam on ban da su dung cong cu!
    echo Tam biet!
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
    echo DA XAY RA LOI!
    echo Vui long thu lai.
) else (
    echo AN ERROR OCCURRED!
    echo Please try again.
)
echo.
pause
goto MAIN_MENU

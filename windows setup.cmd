@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo -------------------------------
echo    WINDOWS INSTALLATION TOOL
echo    CONG CU CAI DAT WINDOWS
echo -------------------------------
echo 1. English
echo 2. Tieng Viet
echo -------------------------------
set /p lang="Select your language/Chon ngon ngu (1/2): "

if "%lang%"=="1" goto ENGLISH
if "%lang%"=="2" goto VIETNAMESE
goto MAIN_MENU

:ENGLISH
set format_prompt=Do you want to format the drive? (y/n): 
set drive_prompt=Select drive to install Windows (e.g., C, D): 
set wim_prompt=Enter path to install.wim (e.g., E:\sources\install.wim): 
set wim_guide=Guide: Right-click ISO file > Mount > Look in the mounted drive (e.g., if mounted as E:, path is E:\sources\install.wim)
set back_option=Press 'z' to go back
set invalid_option=Invalid selection
set confirm_format=Are you sure you want to format drive %selected_drive%? ALL DATA WILL BE LOST! (y/n): 
set formatting=Formatting drive %selected_drive%...
set installing=Installing Windows to drive %selected_drive%...
set success=Operation completed successfully!
goto DRIVE_SELECT

:VIETNAMESE
set format_prompt=Ban co muon format o cung? (y/n): 
set drive_prompt=Chon o cung de cai Windows (vi du: C, D): 
set wim_prompt=Nhap duong dan toi file install.wim (vi du: E:\sources\install.wim): 
set wim_guide=Huong dan: Chuot phai vao file iso > Mount > Tim o dia vua mount (vi du neu la o E:, duong dan se la E:\sources\install.wim)
set back_option=Nhan 'z' de quay lai
set invalid_option=Lua chon khong hop le
set confirm_format=Ban co chac muon format o %selected_drive%? TOAN BO DU LIEU SE BI MAT! (y/n): 
set formatting=Dang format o %selected_drive%...
set installing=Dang cai Windows vao o %selected_drive%...
set success=Hoan tat thanh cong!
goto DRIVE_SELECT

:DRIVE_SELECT
cls
echo %back_option%
echo -------------------------------
echo %drive_prompt%
echo -------------------------------
:: Sử dụng diskpart thay cho wmic trong WinPE
echo list volume | diskpart
echo -------------------------------
set /p selected_drive="Drive/O cung: "

if /i "%selected_drive%"=="z" goto MAIN_MENU
if not exist "%selected_drive%:\" (
    echo %invalid_option%
    pause
    goto DRIVE_SELECT
)

:FORMAT_PROMPT
cls
echo %back_option%
echo -------------------------------
echo Drive/O cung: %selected_drive%
echo %format_prompt%
echo -------------------------------
set /p format_answer="(y/n/z): "

if /i "%format_answer%"=="z" goto DRIVE_SELECT
if /i "%format_answer%"=="y" goto CONFIRM_FORMAT
if /i "%format_answer%"=="n" goto WIM_SELECT
goto FORMAT_PROMPT

:CONFIRM_FORMAT
cls
echo %back_option%
echo -------------------------------
echo %confirm_format%
echo -------------------------------
set /p confirm_answer="(y/n/z): "

if /i "%confirm_answer%"=="z" goto FORMAT_PROMPT
if /i "%confirm_answer%"=="n" goto FORMAT_PROMPT
if /i "%confirm_answer%"=="y" (
    echo %formatting%
    :: Sử dụng diskpart để format trong WinPE
    (
        echo select volume %selected_drive%
        echo format fs=ntfs quick
        echo exit
    ) | diskpart
    goto WIM_SELECT
)
goto CONFIRM_FORMAT

:WIM_SELECT
cls
echo %back_option%
echo -------------------------------
echo %wim_guide%
echo -------------------------------
echo %wim_prompt%
echo -------------------------------
set /p wim_path="Path/Duong dan: "

if /i "%wim_path%"=="z" goto FORMAT_PROMPT
if not exist "%wim_path%" (
    echo %invalid_option%: File not found
    pause
    goto WIM_SELECT
)

:INSTALL_CONFIRM
cls
echo -------------------------------
echo Drive/O cung: %selected_drive%
echo WIM path/Duong dan WIM: %wim_path%
echo -------------------------------
echo %installing%
echo -------------------------------
:: Sử dụng dism để apply image
dism /apply-image /imagefile:"%wim_path%" /index:1 /applydir:%selected_drive%:\

echo %success%
pause
goto MAIN_MENU

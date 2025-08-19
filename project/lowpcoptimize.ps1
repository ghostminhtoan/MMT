# Yeu cau chay voi quyen Administrator

$servicesToDisable = @(
    "SysMain",  # Tang toc doc truoc du lieu, nhung hao o cung (Superfetch)
    "DiagTrack",  # Gui du lieu nguoi dung ve Microsoft
    "WSearch",  # Chi muc tim kiem Windows, ngon RAM va HDD
    "Fax",  # Dich vu gui nhan fax, khong can thiet
    "XblGameSave",  # Luu tru game Xbox, khong can
    "XboxGipSvc",  # Dich vu dieu khien game Xbox
    "XboxNetApiSvc",  # Mang Xbox, khong can
    "MapsBroker",  # Ban do ngoai tuyen, ton RAM
    "WalletService",  # Vi dien tu, khong can
    "PhoneSvc",  # Dich vu lien quan dien thoai
    "RetailDemo",  # Che do demo cho may truong bay
    "PcaSvc",  # Tro ly tuong thich chuong trinh cu
    "AJRouter",  # AllJoyn router, lien quan IoT
    "tzautoupdate",  # Tu dong cap nhat mui gio
    "CDPSvc",  # Ket noi thiet bi, it su dung
    "dmwappushservice",  # Gui thong bao day
    "lfsvc",  # Dinh vi vi tri
    "CscService",  # Tep ngoai tuyen, it can dung
    "WpcMonSvc",  # Kiem soat phu huynh
    "SCardSvr",  # The thong minh (Smart Card)
    "ScDeviceEnum",  # Liet ke thiet bi the thong minh
    "SCPolicySvc",  # Chinh sach the thong minh
    "TapiSrv",  # Dich vu dien thoai
    "wisvc"  # Dich vu nguoi tham gia Windows Insider
)

foreach ($service in $servicesToDisable) {
    Write-Output "Dang tat $service..."
    Stop-Service -Name $service -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
}
Write-Host "Tat ca cac dich vu khong can thiet da duoc tat." -ForegroundColor Green

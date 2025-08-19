dim tcommand, wshshell, pscommand, psresult, isrealtimeenabled

' kiem tra trang thai real-time protection bang powershell
pscommand = "powershell -command ""& { $prefs = get-mppreference; if ($prefs.disablerealtimemonitoring) { 'off' } else { 'on' } }"""
set wshshell = createobject("wscript.shell")
set exec = wshshell.exec(pscommand)
psresult = exec.stdout.readall()

' xac dinh trang thai hien tai
isrealtimeenabled = (instr(1, psresult, "on", vbtextcompare) > 0)

if not isrealtimeenabled then
    ' mo windows defender
    tcommand = createobject("wscript.shell").expandenvironmentstrings("%programfiles%\windows defender\msascui.exe")
    if not (createobject("scripting.filesystemobject").fileexists(tcommand)) then tcommand = "windowsdefender://threatsettings"
    createobject("shell.application").shellexecute tcommand

    ' doi cua so mo
    wscript.sleep 3000

    ' gui phim space de bat real-time protection
    wshshell.sendkeys " "
    wscript.sleep 500

    
    msgbox "Da bat real-time protection.", vbinformation, "Thong bao"
else
    msgbox "Real-time protection dang bat, khong can thao tac.", vbinformation, "Thong bao"
end if


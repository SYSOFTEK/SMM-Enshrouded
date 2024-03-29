#Region
#AutoIt3Wrapper_Icon=app.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=SMM-Enshourded
#AutoIt3Wrapper_Res_Fileversion=2.4.0.0
#AutoIt3Wrapper_Res_ProductName=SMM-Enshourded
#AutoIt3Wrapper_Res_ProductVersion=2.4.0.0
#AutoIt3Wrapper_Res_LegalCopyright=(c) sysoftek@github
#AutoIt3Wrapper_Res_Language=1036
#EndRegion


#include<GuiButton.au3>
#include<WindowsConstants.au3>
#include<GuiListView.au3>
#include<File.au3>
#include<String.au3>
#include<WinAPISys.au3>
#include<WinAPIProc.au3>

Opt("GuiCloseOnESC",0)
Opt("GUIOnEventMode",1)
Opt("MouseCoordMode",2)
Opt("TrayOnEventMode",1)
Opt("TrayAutoPause",0)
Opt("GUIResizeMode",802)
Opt("TrayMenuMode",3)

$job = StringReplace(@ScriptName,".au3","")
$job = StringReplace($job,".exe","")
$appdata = @AppDataDir & "\" & $job
DirCreate($appdata)

FileInstall(".\sysoftek.jpg",$appdata & "\sysoftek.jpg",1)
FileInstall(".\app.jpg",$appdata & "\app.jpg",1)
FileInstall(".\console.jpg",$appdata & "\console.jpg",1)
FileInstall(".\app.lng",$appdata & "\app.lng",1)
FileInstall(".\query_on.ico",$appdata & "\query_on.ico",1)
FileInstall(".\query_off.ico",$appdata & "\query_off.ico",1)
FileInstall(".\menu_profile.ico",$appdata & "\menu_profile.ico",1)
FileInstall(".\menu_start.ico",$appdata & "\menu_start.ico",1)
FileInstall(".\menu_stop.ico",$appdata & "\menu_stop.ico",1)
FileInstall(".\menu_restart.ico",$appdata & "\menu_restart.ico",1)
FileInstall(".\menu_steamcmd.ico",$appdata & "\menu_steamcmd.ico",1)
FileInstall(".\menu_backup.ico",$appdata & "\menu_backup.ico",1)
FileInstall(".\menu_config.ico",$appdata & "\menu_config.ico",1)
FileInstall(".\menu_about.ico",$appdata & "\menu_about.ico",1)
FileInstall(".\menu_profile_load.ico",$appdata & "\menu_profile_load.ico",1)
FileInstall(".\menu_profile_add.ico",$appdata & "\menu_profile_add.ico",1)
FileInstall(".\menu_profile_del.ico",$appdata & "\menu_profile_del.ico",1)
FileInstall(".\LICENSE.txt",$appdata & "\LICENSE.txt",1)

$config = $appdata & "\config.ini"
$online = $appdata & "\online.ini"
$lng = $appdata & "\app.lng"

If $CmdLine[0] > 0 Then
	_SteamCMD_Win_()
Else
	$solo = ProcessList(@ScriptName)
	If $solo[0][0] > 1 Then Exit
EndIf

$strComputer = "."
$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & $strComputer & "\root\cimv2")

Global $list_config,$gui_cell,$edit_cell,$edit_sel,$edit_old,$edit_type,$Item = -1,$SubItem = 0
$lock = 0

$dir_profile = @ScriptDir & "\profile"
DirCreate($dir_profile)
DirCreate($dir_profile & "\default")
$dir_backup = @ScriptDir & "\backup"
DirCreate($dir_backup)
$dir_steamcmd = $appdata & "\steamcmd"
DirCreate($dir_steamcmd)

$config_game = @ScriptDir & "\enshrouded_server.json"
$profile = IniRead($config,"config","profile","default")

$online_reset = IniReadSectionNames($online)
If Not @error Then
	For $i_reset = 1 To $online_reset[0]
		IniWrite($online,$online_reset[$i_reset],"online","0")
		IniWrite($online,$online_reset[$i_reset],"session","0")
	Next
EndIf

$pid = 0
$tray_state = 0
$online_tab = 0
$online_path = ""
$online_line = 0
$url_github = "https://github.com/SYSOFTEK/SMM-Enshrouded"
$url_version = $url_github & "/releases/latest/download/version.txt"

$monitor = 0
$monitor_timer = 0
$monitor_read_start = 0
$monitor_read_end = 0
$monitor_write_start = 0
$monitor_write_end = 0

$exe = @ScriptDir & "\enshrouded_server.exe"
$exe_pid = "enshrouded_server.exe"

$url_steamcmd = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$zip_steamcmd = @TempDir & "\steamcmd.zip"
$exe_steamcmd = $dir_steamcmd & "\steamcmd.exe"
$cmd_steamcmd = '+force_install_dir "' & @ScriptDir & '" +login anonymous +app_update 2278520 validate +quit'

$guiname = $job
$gui = GUICreate($guiname,750,520)
	GUISetBkColor(0xffffff)
	GUISetOnEvent(-3,"_Exit_")

GUICtrlCreatePic($appdata & "\app.jpg",0,0,750,80,0x04000000)
GUICtrlCreateGraphic(40,80,1,440)
	GUICtrlSetBkColor(-1,0x000000)

GUICtrlCreateLabel(_LNG_("label_ban"),440,60,310,20,BitOR(0x01,0x0200))
	GUICtrlSetFont(-1,11,400,2)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,-2)

$button_query = GUICtrlCreateButton("",2,2,22,22,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\query_off.ico")
	GUICtrlSetOnEvent(-1,"_Refresh_Query_")
	GUICtrlSetTip(-1,_LNG_("tip_query"))

$label_profile = GUICtrlCreateLabel(_LNG_("label_profile") & " : ---",5,55,150,25)
	GUICtrlSetFont(-1,10,700)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,-2)

$button_lng = GUICtrlCreateButton(IniRead($config,"config","lng","EN"),718,2,30,20)
	GUICtrlSetOnEvent(-1,"_Lng_Menu_")
	$mn_lng = GUICtrlCreateContextMenu($button_lng)
		$nbr_lng = IniReadSectionNames($lng)
		For $i_lng = 1 To $nbr_lng[0]
			GUICtrlCreateMenuItem($nbr_lng[$i_lng] & " : " & IniRead($lng,$nbr_lng[$i_lng],"lng",""),$mn_lng)
				GUICtrlSetOnEvent(-1,"_Lng_Select_")
		Next

$button_online = GUICtrlCreateButton(_LNG_("button_online") & " >",650,22,98,20)
	GUICtrlSetOnEvent(-1,"_Online_Tab_")

$button_profile = GUICtrlCreateButton("",0,80,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_profile.ico")
	GUICtrlSetOnEvent(-1,"_Profile_")
	GUICtrlSetTip(-1,_LNG_("tip_profile"))

$button_start = GUICtrlCreateButton("",0,160,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_start.ico")
	GUICtrlSetOnEvent(-1,"_Start_")
	GUICtrlSetTip(-1,_LNG_("tip_start"))
$button_stop = GUICtrlCreateButton("",0,200,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_stop.ico")
	GUICtrlSetOnEvent(-1,"_Stop_")
	GUICtrlSetTip(-1,_LNG_("tip_stop"))
$button_restart = GUICtrlCreateButton("",0,240,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_restart.ico")
	GUICtrlSetOnEvent(-1,"_Restart_")
	GUICtrlSetTip(-1,_LNG_("tip_restart"))

$button_steamcmd = GUICtrlCreateButton("",0,320,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_steamcmd.ico")
	GUICtrlSetOnEvent(-1,"_SteamCMD_")
	GUICtrlSetTip(-1,_LNG_("tip_steamcmd"))
$button_backup = GUICtrlCreateButton("",0,360,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_backup.ico")
	GUICtrlSetOnEvent(-1,"_Backup_")
	GUICtrlSetTip(-1,_LNG_("tip_backup"))
$button_config = GUICtrlCreateButton("",0,400,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_config.ico")
	GUICtrlSetOnEvent(-1,"_Config_Menu_")
	GUICtrlSetTip(-1,_LNG_("tip_config"))
	$mn_config = GUICtrlCreateContextMenu($button_config)
		GUICtrlCreateMenuItem(_LNG_("tip_config_server"),$mn_config)
			GUICtrlSetOnEvent(-1,"_Config_JSON_")
		GUICtrlCreateMenuItem(_LNG_("tip_config_notif"),$mn_config)
			GUICtrlSetOnEvent(-1,"_Config_Notif_")

$button_about = GUICtrlCreateButton("",0,480,40,40,0x0040)
	_GUICtrlButton_SetImage(-1,$appdata & "\menu_about.ico")
	GUICtrlSetOnEvent(-1,"_About_")
	GUICtrlSetTip(-1,_LNG_("tip_about"))

GUICtrlCreateGroup(_LNG_("gp_perf"),45,85,230,100)
	GUICtrlCreateLabel("CPU :",50,105,50,20,0x01)
		GUICtrlSetFont(-1,12)
	$monitor_cpuv = GUICtrlCreateLabel("0%",50,125,50,16,0x01)
		GUICtrlSetFont(-1,8)
	$monitor_cpu = GUICtrlCreateProgress(100,105,170,30,BitOR(0x01,0x10))
	GUICtrlCreateLabel("RAM :",50,145,50,20,0x01)
		GUICtrlSetFont(-1,12)
	$monitor_ramv = GUICtrlCreateLabel("0mo",50,165,50,16,0x01)
		GUICtrlSetFont(-1,8)
	$monitor_ram = GUICtrlCreateProgress(100,145,170,30,BitOR(0x01,0x10))

GUICtrlCreateGroup(_LNG_("gp_disk"),280,85,230,100)
	GUICtrlCreateLabel("R I/O :",285,105,50,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_disk_r = GUICtrlCreateLabel("0.000 Mo / sec",335,105,170,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	GUICtrlCreateLabel("W I/O :",285,145,50,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_disk_w = GUICtrlCreateLabel("0.000 Mo / sec",335,145,170,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)

GUICtrlCreateGroup(_LNG_("gp_usage"),515,85,230,100)
	GUICtrlCreateLabel("saveDirectory :",520,105,130,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_save_dir = GUICtrlCreateLabel("0.000 Mo",650,105,90,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	GUICtrlCreateLabel("logDirectory :",520,145,130,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_log_dir = GUICtrlCreateLabel("0.000 Mo",650,145,90,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)

$pic_console = GUICtrlCreatePic($appdata & "\console.jpg",45,190,700,325,0x04000000)
$label_console = GUICtrlCreateLabel("",220,335,350,35,BitOR(0x01,0x0200))
	GUICtrlSetFont(-1,20,700)
	GUICtrlSetColor(-1,0xe1c48c)
	GUICtrlSetBkColor(-1,-2)
$button_download = GUICtrlCreateButton(_LNG_("button_download"),295,380,200,40)
	GUICtrlSetFont(-1,18)
	GUICtrlSetOnEvent(-1,"_SteamCMD_")

GUICtrlCreateGraphic(750,0,1,520)
	GUICtrlSetColor(-1,0x000000)

$list_online = GUICtrlCreateListView(_LNG_("list_players") & "|" & _LNG_("list_session") & "|" & _LNG_("list_total"),755,0,285,515)
	GUICtrlSendMsg($list_online,0x101E,0,125)
	GUICtrlSendMsg($list_online,0x101E,1,60)
	GUICtrlSendMsg($list_online,0x101E,2,60)
	ControlDisable($guiname,"",HWnd(_GUICtrlListView_GetHeader($list_online)))

TraySetToolTip($guiname)
	TraySetClick(8)
	TraySetOnEvent(-13,"_Tray_State_")
	$tray_show = TrayCreateItem(_LNG_("tray_hide") & " " & $job)
		TrayItemSetOnEvent(-1,"_Tray_State_")
	TrayCreateItem("")
	TrayCreateItem(_LNG_("tray_quit"))
		TrayItemSetOnEvent(-1,"_Exit_")

ControlDisable($guiname,"",$button_stop)
ControlDisable($guiname,"",$button_restart)

AdlibRegister("_Check_Version_",5000)
_Refresh_()
AdlibRegister("_Refresh_",10000)

GUIRegisterMsg($WM_NOTIFY,"WM_NOTIFY")
GUISetState()

While 1
	If $pid <> 0 Then
		If Not ProcessExists($pid) Then
			_Stop_Monitor_()
		EndIf
	EndIf
	Sleep(100)
WEnd

Func _Exit_()
	If $pid <> 0 Then
		$msgbox = MsgBox(52,"- " & _LNG_("msg_avert") & " -",_LNG_("msg_avert_desc"),0,$gui)
		If $msgbox == 6 Then
			_Stop_()
			Exit
		EndIf
	Else
		_Stop_Monitor_()
		Exit
	EndIf
EndFunc

Func _Tray_State_()
	If $tray_state == "0" Then
		ControlHide($guiname,"",$gui)
		TrayItemSetText($tray_show,_LNG_("tray_show") & " " & $job)
		$tray_state = "1"
	Else
		ControlShow($guiname,"",$gui)
		WinActivate($guiname)
		TrayItemSetText($tray_show,_LNG_("tray_show") & " " & $job)
		$tray_state = "0"
	EndIf
EndFunc

Func _Lng_Menu_()
	ControlClick($guiname,"",$button_lng,"right")
EndFunc

Func _Config_Menu_()
	ControlClick($guiname,"",$button_config,"right")
EndFunc

Func _Lng_Select_()
	$lng_select = StringSplit(StringReplace(GUICtrlRead(@GUI_CtrlId,1)," ",""),":")
	If $lng_select[1] <> GUICtrlRead($button_lng) Then
		$msgbox = MsgBox(36,IniRead($lng,$lng_select[1],"msg_lang",""),StringReplace(IniRead($lng,$lng_select[1],"msg_lang_desc",""),"[br]",@CRLF) & " " & $guiname & "!",0,$gui)
		If $msgbox == 6 Then
			IniWrite($config,"config","lng",$lng_select[1])
			Exit
		EndIf
	EndIf
EndFunc

Func _LNG_($_lng_)
	$_lng_ = IniRead($lng,IniRead($config,"config","lng","EN"),$_lng_,"<STRING_NOT_TRANSLATED>")
	$_lng_ = StringReplace($_lng_,"[br]",@CRLF)
	Return $_lng_
EndFunc

Func _Check_Version_()
	AdlibUnRegister("_Check_Version_")
	If IniRead($config,"config","update","") == 1 And FileGetVersion(@ScriptFullPath) <> BinaryToString(InetRead($url_version,1)) Then
		$msgbox = MsgBox(68,"-" & _LNG_("msg_update") & "-",_LNG_("msg_update_desc"),0,$gui)
		If $msgbox == 6 Then
			ShellExecute($url_github)
		EndIf
	EndIf
EndFunc

Func _Refresh_()
	GUICtrlSetData($label_profile,"profil : " & $profile)
	$save_usage_calc = Round((DirGetSize(_Path_Save_())/1024/1024),3)
	$log_usage_calc = Round((DirGetSize(_Path_Log_())/1024/1024),3)
	If Ceiling($save_usage_calc) == 0 Or StringInStr($save_usage_calc,"-") Then
		$save_usage_calc = "0.000 Mo"
	Else
		$save_usage_calc = $save_usage_calc & " Mo"
	EndIf
	If Ceiling($log_usage_calc) == 0 Or StringInStr($log_usage_calc,"-") Then
		$log_usage_calc = "0.000 Mo"
	Else
		$log_usage_calc = $log_usage_calc & " Mo"
	EndIf
	GUICtrlSetData($monitor_save_dir,$save_usage_calc)
	GUICtrlSetData($monitor_log_dir,$log_usage_calc)
	If Not FileExists($exe) Then
		ControlDisable($guiname,"",$button_start)
		GUICtrlSetData($label_console,_LNG_("label_console"))
	ElseIf $pid == 0 Then
		ControlEnable($guiname,"",$button_start)
		GUICtrlSetData($label_console,"")
		ControlHide($guiname,"",$button_download)
	EndIf
	If Not FileExists(_Path_Save_()) Then
		ControlDisable($guiname,"",$button_backup)
	Else
		ControlEnable($guiname,"",$button_backup)
	EndIf
EndFunc

Func _Refresh_Query_()
	If $monitor == 1 Then
		$getip = _StringBetween(BinaryToString(InetRead("http://checkip.dyndns.org",1)),": ","<")
		If Not @error Then
			$myip = $getip[0]
		Else
			$myip = "error"
		EndIf
		$query = BinaryToString(InetRead("https://steamquerytool.com/?ip=" & $myip & "&port=" & _Path_Port_(),1))
		If StringInStr($query,"not found") Then
			_GUICtrlButton_SetImage($button_query,$appdata & "\query_off.ico")
		Else
			_GUICtrlButton_SetImage($button_query,$appdata & "\query_on.ico")
		EndIf
		AdlibRegister("_Refresh_Query_",600000)
	EndIf
EndFunc

Func _Path_Save_()
	$read_usage = FileRead($config_game)
	$save_usage = _StringBetween($read_usage,'"saveDirectory": "','",')
	If Not @error Then Return $save_usage[0]
EndFunc

Func _Path_Log_()
	$read_usage = FileRead($config_game)
	$log_usage = _StringBetween($read_usage,'"logDirectory": "','",')
	If Not @error Then Return $log_usage[0]
EndFunc

Func _Path_Port_()
	$read_usage = FileRead($config_game)
	$log_usage = _StringBetween($read_usage,'"queryPort": ',',')
	If Not @error Then Return $log_usage[0]
EndFunc

Func _Online_Tab_()
	$pos = WinGetPos($guiname)
	If $online_tab == 0 Then
		ControlMove($guiname,"",$gui,$pos[0],$pos[1],1050)
		GUICtrlSetData($button_online,_LNG_("button_online") & " <")
		$online_tab = 1
	Else
		ControlMove($guiname,"",$gui,$pos[0],$pos[1],756)
		GUICtrlSetData($button_online,_LNG_("button_online") & " >")
		$online_tab = 0
	EndIf
EndFunc

Func _Online_Player_()
	$online_nbr = _FileCountLines($online_path)
	$online_last = FileReadLine($online_path,$online_nbr)
	If $online_nbr <> $online_line Then
		For $i_online = $online_line To $online_nbr
			If $online_last <> FileReadLine($online_path,$i_online) Or $online_last <> "" Then
				$online_read = FileReadLine($online_path,$i_online + 1)
				If StringInStr($online_read,"Send Character Savegame") Then
					$player = _StringBetween($online_read,"'","'")
					If Not @error Then
						If IniRead($config,"config","discord_enable","") == 1 And IniRead($config,"config","discord_player_on","") == 1 Then
							If IniRead($online,$player[0],"online","") <> 1 Then _Send_Discord_(IniRead($config,"config","discord_hook",""),"** " & _LNG_("discord_notif") & $guiname & "**" & @CRLF & _LNG_("discord_player_on") & " : " & $player[0])
						EndIf
						IniWrite($online,$player[0],"online","1")
					EndIf
				ElseIf StringInStr($online_read,"Remove Entity for Player") Then
					$player = _StringBetween($online_read,"'","'")
					If Not @error Then
						If IniRead($config,"config","discord_enable","") == 1 And IniRead($config,"config","discord_player_off","") == 1 Then
							If IniRead($online,$player[0],"online","") <> 0 Then _Send_Discord_(IniRead($config,"config","discord_hook",""),"** " & _LNG_("discord_notif") & $guiname & "**" & @CRLF & _LNG_("discord_player_off") & " : " & $player[0])
						EndIf
						IniWrite($online,$player[0],"online","0")
					EndIf
				EndIf
			EndIf
			Sleep(100)
		Next
		$online_line = $online_nbr
	EndIf
	_GUICtrlListView_DeleteAllItems($list_online)
	$online_section = IniReadSectionNames($online)
	If Not @error Then
		For $i_section = 1 To $online_section[0]
			If IniRead($online,$online_section[$i_section],"online","") == "1" Then
				$online_player = $online_section[$i_section]
				IniWrite($online,$online_player,"session",Ceiling(IniRead($online,$online_player,"session","0")) + 10)
				IniWrite($online,$online_player,"total",Ceiling(IniRead($online,$online_player,"total","0")) + 10)
				$online_session = _SecToTime_(IniRead($online,$online_section[$i_section],"session","0"))
				$online_total = _SecToTime_(IniRead($online,$online_section[$i_section],"total","0"))
				GUICtrlCreateListViewItem($online_player & "|" & $online_session & "|" & $online_total,$list_online)
			EndIf
		Next
	EndIf
EndFunc

Func _Start_()
	If Not FileExists($exe) Then
		MsgBox(16,"- " & _LNG_("msg_error") & " -",_LNG_("msg_error_desc"),0,$gui)
	Else
		If $pid == 0 Then
			$pid = ShellExecute($exe,'',@ScriptDir,"",@SW_HIDE)
			_GUI_Embed_($gui,$pid,45,190,700,325)
			ControlDisable($guiname,"",$button_lng)
			ControlDisable($guiname,"",$button_profile)
			ControlDisable($guiname,"",$button_start)
			ControlEnable($guiname,"",$button_stop)
			ControlEnable($guiname,"",$button_restart)
			ControlDisable($guiname,"",$button_steamcmd)
			ControlDisable($guiname,"",$button_backup)
			ControlHide($guiname,"",$pic_console)
			ControlHide($guiname,"",$label_console)
			$monitor = 1
			AdlibRegister("_Monitor_",1000)
			$online_path = _Path_Log_() & "\enshrouded_server.log"
			$online_line = 0
			AdlibRegister("_Online_Player_",10000)
			AdlibRegister("_Refresh_Query_",10000)
			If IniRead($config,"config","discord_enable","") == 1 And  IniRead($config,"config","discord_enable","discord_server_on") == 1 Then
				_Send_Discord_(IniRead($config,"config","discord_hook",""),"** " & _LNG_("discord_notif") & $guiname & "**" & @CRLF & _LNG_("discord_server_on"))
			EndIf
		EndIf
	EndIf
EndFunc

Func _Stop_()
	$monitor = 0
	AdlibUnRegister("_Monitor_")
	AdlibUnRegister("_Online_Player_")
	AdlibUnRegister("_Refresh_Query_")
	WinActivate($guiname)
	MouseClick("left",55,200,1,0)
	Send("!{F4}")
	_Stop_Monitor_()
	If IniRead($config,"config","discord_enable","") == 1 And  IniRead($config,"config","discord_enable","discord_server_off") == 1 Then
		_Send_Discord_(IniRead($config,"config","discord_hook",""),"** " & _LNG_("discord_notif") & $guiname & "**" & @CRLF & _LNG_("discord_server_off"))
	EndIf
EndFunc

Func _Stop_Monitor_()
	$monitor = 0
	AdlibUnRegister("_Monitor_")
	AdlibUnRegister("_Online_Player_")
	AdlibUnRegister("_Refresh_Query_")
	_GUICtrlButton_SetImage($button_query,$appdata & "\query_off.ico")
	_GUICtrlListView_DeleteAllItems($list_online)
	ControlEnable($guiname,"",$button_lng)
	ControlEnable($guiname,"",$button_profile)
	ControlEnable($guiname,"",$button_start)
	ControlDisable($guiname,"",$button_stop)
	ControlDisable($guiname,"",$button_restart)
	ControlEnable($guiname,"",$button_steamcmd)
	ControlEnable($guiname,"",$button_backup)
	ControlShow($guiname,"",$pic_console)
	ControlShow($guiname,"",$label_console)
	GUICtrlSetData($monitor_cpuv,"0%")
	GUICtrlSetData($monitor_cpu,0)
	GUICtrlSetData($monitor_ramv,"0mo")
	GUICtrlSetData($monitor_ram,0)
	GUICtrlSetData($monitor_disk_r,"0.000 Mo / sec")
	GUICtrlSetData($monitor_disk_w,"0.000 Mo / sec")
	$pid = 0
EndFunc

Func _Restart_()
	_Stop_()
	ProcessWaitClose($exe_pid)
	_Start_()
EndFunc

Func _SteamCMD_()
	AdlibUnRegister("_Refresh_")
	ControlDisable($guiname,"",$button_lng)
	ControlDisable($guiname,"",$button_profile)
	ControlDisable($guiname,"",$button_start)
	ControlDisable($guiname,"",$button_steamcmd)
	ControlDisable($guiname,"",$button_backup)
	ControlDisable($guiname,"",$button_config)
	ControlDisable($guiname,"",$button_about)
	ControlHide($guiname,"",$pic_console)
	ControlHide($guiname,"",$label_console)
	ControlHide($guiname,"",$button_download)
	If Not FileExists($exe_steamcmd) Then
		InetGet($url_steamcmd,$zip_steamcmd,1)
		_UnZip_($zip_steamcmd,$dir_steamcmd)
		While 1
			Sleep(5000)
			If FileExists($exe_steamcmd) Then ExitLoop
		WEnd
	EndIf
	$pid_steam = ShellExecute($exe_steamcmd,$cmd_steamcmd,$dir_steamcmd)
	_GUI_Embed_($gui,$pid_steam,45,190,700,325)
	Sleep(2000)
	ShellExecute(@ScriptFullPath,"-steam",@ScriptDir)
	ProcessWaitClose($pid_steam)
	ControlShow($guiname,"",$pic_console)
	ControlShow($guiname,"",$label_console)
	ControlEnable($guiname,"",$button_lng)
	ControlEnable($guiname,"",$button_steamcmd)
	ControlEnable($guiname,"",$button_config)
	ControlEnable($guiname,"",$button_about)
	_Refresh_()
	AdlibRegister("_Refresh_",10000)
EndFunc

Func _Profile_()
	ControlDisable($guiname,"",$gui)
	Global $guiname_profile = _LNG_("gui_profile")
	Global $gui_profile = GUICreate($guiname_profile,200,250,-1,-1,BitXOR(BitOR(0x00020000,0x00C00000,0x80000000,0x00080000),0x00020000),-1,$gui)
		GUISetOnEvent(-3,"_Profile_Close_")
	Global $list_profile = GUICtrlCreateListView(_LNG_("label_profile"),-2,0,203,228)
	GUICtrlCreateButton("",0,228,22,22,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_profile_load.ico")
		GUICtrlSetOnEvent(-1,"_Profile_Load_")
		GUICtrlSetTip(-1,_LNG_("tip_profile_load"))
	GUICtrlCreateButton("",156,228,22,22,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_profile_add.ico")
		GUICtrlSetOnEvent(-1,"_Profile_Add_")
		GUICtrlSetTip(-1,_LNG_("tip_profile_add"))
	GUICtrlCreateButton("",178,228,22,22,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_profile_del.ico")
		GUICtrlSetOnEvent(-1,"_Profile_Del_")
		GUICtrlSetTip(-1,_LNG_("tip_profile_del"))
	_Profile_Refresh_()
	GUISetState()
EndFunc

Func _Profile_Close_()
	GUIDelete($gui_profile)
	ControlEnable($guiname,"",$gui)
	WinActivate($guiname)
EndFunc

Func _Profile_Refresh_()
	_GUICtrlListView_DeleteAllItems($list_profile)
	$nbr_profile = _FileListToArray($dir_profile,"*",2)
	For $i_profile = 1 To $nbr_profile[0]
		If $nbr_profile[$i_profile] == $profile Then
			GUICtrlCreateListViewItem(">>" & $nbr_profile[$i_profile] & "<<",$list_profile)
		Else
			GUICtrlCreateListViewItem($nbr_profile[$i_profile],$list_profile)
		EndIf
	Next
	_GUICtrlListView_SetColumnWidth($list_profile,0,160)
	_Refresh_()
EndFunc

Func _Profile_Load_()
	$select_0 = _GUICtrlListView_GetItemText($list_profile,_GUICtrlListView_GetSelectionMark($list_profile),0)
	If $select_0 <> "" And $select_0 <> ">>" & $profile & "<<" Then
		$msgbox = MsgBox(52,"- " & _LNG_("msg_profil_load") & " -",_LNG_("msg_profil_load_desc") & " :" & @CRLF & StringUpper($profile) & " >> " & StringUpper($select_0),0,$gui_profile)
		If $msgbox == 6 Then
			FileMove(_Path_Save_() & "\*",$dir_profile & "\" & $profile & "\*",1)
			FileMove($config_game,$dir_profile & "\" & $profile & "\*",1)
			FileMove($dir_profile & "\" & $select_0 & "\enshrouded_server.json",$config_game,1)
			FileMove($dir_profile & "\" & $select_0 & "\*",_Path_Save_() & "\*",1)
			$profile = $select_0
			IniWrite($config,"config","profile",$profile)
			_Profile_Refresh_()
		EndIf
	EndIf
EndFunc

Func _Profile_Add_()
	$inputbox = InputBox("- " & _LNG_("msg_profil_new") & " -",_LNG_("msg_profil_new_desc") & " :","","",250,125,Default,Default,0,$gui_profile)
	If Not @error And $inputbox <> "" And Not FileExists($dir_profile & "\" & $inputbox) Then
		DirCreate($dir_profile & "\" & $inputbox)
		_Profile_Refresh_()
	EndIf
EndFunc

Func _Profile_Del_()
	$select_0 = _GUICtrlListView_GetItemText($list_profile,_GUICtrlListView_GetSelectionMark($list_profile),0)
	If $select_0 <> "" Then
		If $select_0 == "default" Or $select_0 == ">>default<<" Then
			MsgBox(48,"- " & _LNG_("msg_profil_del") & " -",_LNG_("msg_profil_del_default") & "!",0,$gui_profile)
		Else
			If $select_0 == ">>" & $profile & "<<" Then
				MsgBox(48,"- " & _LNG_("msg_profil_del") & " -",_LNG_("msg_profil_del_current") & "!",0,$gui_profile)
			Else
				$msgbox = MsgBox(52,"- " & _LNG_("msg_profil_del") & " -",_LNG_("msg_profil_del_confirm") & " : " & StringUpper($select_0) & " ?" & @CRLF & @CRLF & _LNG_("msg_profil_del_confirm_1") & " :" & @CRLF & "- " & _LNG_("msg_profil_del_confirm_2"),0,$gui_profile)
				If $msgbox == 6 Then
					DirRemove($dir_profile & "\" & $select_0,1)
					_Profile_Refresh_()
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

Func _Backup_()
	$msgbox= MsgBox(36,"- " & _LNG_("msg_profil_save") & " -",_LNG_("msg_profil_save_desc") & "?",0,$gui)
	If $msgbox == 6 Then
		$time_backup = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "." & @MIN & "." & @SEC
		$dest_backup = $dir_backup & "\" & $profile
		DirCreate($dest_backup)
		$dest_backup = $dir_backup & "\" & $profile & "\" & $time_backup
		DirCreate($dest_backup)
		DirCopy(_Path_Save_(),$dest_backup,1)
	EndIf
EndFunc

Func _Config_JSON_()
	If Not FileExists($config_game) Then
		MsgBox(48,"-" & _LNG_("msg_noconfig") & " -",_LNG_("msg_noconfig_desc"),0,$gui)
		Return
	EndIf
	ControlDisable($guiname,"",$gui)
	Global $guiname_config_json = _LNG_("gui_config")
	Global $gui_config_json = GUICreate($guiname_config_json,400,500,-1,-1,BitXOR(BitOR(0x00020000,0x00C00000,0x80000000,0x00080000),0x00020000),-1,$gui)
		GUISetOnEvent(-3,"_Config_JSON_Close_")
	Global $list_config = _GUICtrlListView_Create($gui_config_json,_LNG_("list_opt") & "|" & _LNG_("list_val"),-2,0,403,501,BitOR(0x0001,0x00200000,0x0004),0x00000200)
		_GUICtrlListView_SetExtendedListViewStyle($list_config,BitOR(0x00000001,0x00000020))
		_GUICtrlListView_SetColumnWidth($list_config,0,200)
		_GUICtrlListView_SetColumnWidth($list_config,1,140)
		_WinAPI_SetFont($list_config,_WinAPI_CreateFont(20,0),False)
		$json_count = 0
		$json_line = _FileCountLines($config_game)
		For $i_line = 1 To $json_line
			$read_line = FileReadLine($config_game,$i_line)
			If StringInStr($read_line,'"',0,2) Then
				$split1 = StringSplit($read_line,":")
				$key = StringReplace($split1[1],@TAB,'')
				$key = StringReplace($key,'"','')
				$value = StringReplace($split1[2],'"','')
				$value = StringReplace($value,' ','',1)
				$value = StringReplace($value,',','')
				_GUICtrlListView_AddItem($list_config,$key)
				_GUICtrlListView_AddSubItem($list_config,$json_count,$value,1)
				$json_count = $json_count + 1
			EndIf
		Next
	GUISetState()
EndFunc

Func _Config_JSON_Close_()
	If $lock == 0 Then
		GUIDelete($gui_config_json)
		ControlEnable($guiname,"",$gui)
		WinActivate($guiname)
		_Refresh_()
	EndIf
EndFunc

Func _Config_Notif_()
	ControlDisable($guiname,"",$gui)
	Global $guiname_config_notif = _LNG_("gui_notif")
	Global $gui_config_notif = GUICreate($guiname_config_notif,400,195,-1,-1,BitXOR(BitOR(0x00020000,0x00C00000,0x80000000,0x00080000),0x00020000),-1,$gui)
		GUISetBkColor(0xffffff,$gui_config_notif)
		GUISetOnEvent(-3,"_Config_Notif_Close_")
	Global $config_check_update = GUICtrlCreateCheckbox(_LNG_("notif_update"),5,5,250,25)
		GUICtrlSetFont(-1,12)
	GUICtrlCreateGroup(_LNG_("notif_discord_gp"),5,35,390,125)
		Global $config_check_discord_enable = GUICtrlCreateCheckbox(_LNG_("notif_discord"),10,50,150,25)
			GUICtrlSetFont(-1,12)
			GUICtrlSetOnEvent(-1,"_Config_Notif_Discord_")
		Global $config_check_discord_server_on = GUICtrlCreateCheckbox(_LNG_("notif_discord_server_on"),10,80,150,25)
			GUICtrlSetFont(-1,12)
		Global $config_check_discord_server_off = GUICtrlCreateCheckbox(_LNG_("notif_discord_server_off"),200,80,150,25)
			GUICtrlSetFont(-1,12)
		Global $config_check_discord_player_on = GUICtrlCreateCheckbox(_LNG_("notif_discord_player_on"),10,105,150,25)
			GUICtrlSetFont(-1,12)
		Global $config_check_discord_player_off = GUICtrlCreateCheckbox(_LNG_("notif_discord_player_off"),200,105,150,25)
			GUICtrlSetFont(-1,12)
		GUICtrlCreateLabel("URL hook :",10,130,80,20,BitOR(0x01,0x0200))
			GUICtrlSetFont(-1,12)
		Global $config_input_discord_hook = GUICtrlCreateInput(IniRead($config,"config","discord_hook",""),90,130,250,20)
		Global $config_button_discord_test = GUICtrlCreateButton("test",340,130,50,20)
			GUICtrlSetOnEvent(-1,"_Config_Notif_Discord_Test_")
		GUICtrlCreateButton(_LNG_("notif_save"),245,165,150,25)
			GUICtrlSetOnEvent(-1,"_Config_Notif_Save_")
		If IniRead($config,"config","update","") == 1 Then GUICtrlSetState($config_check_update,1)
		If IniRead($config,"config","discord_enable","") == 1 Then
			GUICtrlSetState($config_check_discord_enable,1)
		Else
			ControlDisable($guiname_config_notif,"",$config_check_discord_server_on)
			ControlDisable($guiname_config_notif,"",$config_check_discord_server_off)
			ControlDisable($guiname_config_notif,"",$config_check_discord_player_on)
			ControlDisable($guiname_config_notif,"",$config_check_discord_player_off)
			ControlDisable($guiname_config_notif,"",$config_input_discord_hook)
			ControlDisable($guiname_config_notif,"",$config_button_discord_test)
		EndIf
		If IniRead($config,"config","discord_server_on","") == 1 Then GUICtrlSetState($config_check_discord_server_on,1)
		If IniRead($config,"config","discord_server_off","") == 1 Then GUICtrlSetState($config_check_discord_server_off,1)
		If IniRead($config,"config","discord_player_on","") == 1 Then GUICtrlSetState($config_check_discord_player_on,1)
		If IniRead($config,"config","discord_player_off","") == 1 Then GUICtrlSetState($config_check_discord_player_off,1)
	GUISetState()
EndFunc

Func _Config_Notif_Close_()
	GUIDelete($gui_config_notif)
	ControlEnable($guiname,"",$gui)
	WinActivate($guiname)
EndFunc

Func _Config_Notif_Discord_()
	If GUICtrlRead($config_check_discord_enable) == 1 Then
		ControlEnable($guiname_config_notif,"",$config_check_discord_server_on)
		ControlEnable($guiname_config_notif,"",$config_check_discord_server_off)
		ControlEnable($guiname_config_notif,"",$config_check_discord_player_on)
		ControlEnable($guiname_config_notif,"",$config_check_discord_player_off)
		ControlEnable($guiname_config_notif,"",$config_input_discord_hook)
		ControlEnable($guiname_config_notif,"",$config_button_discord_test)
	Else
		ControlDisable($guiname_config_notif,"",$config_check_discord_server_on)
		ControlDisable($guiname_config_notif,"",$config_check_discord_server_off)
		ControlDisable($guiname_config_notif,"",$config_check_discord_player_on)
		ControlDisable($guiname_config_notif,"",$config_check_discord_player_off)
		ControlDisable($guiname_config_notif,"",$config_input_discord_hook)
		ControlDisable($guiname_config_notif,"",$config_button_discord_test)
	EndIf
EndFunc

Func _Config_Notif_Discord_Test_()
	_Send_Discord_(GuiCtrlRead($config_input_discord_hook),"**TEST " & $guiname & "**" & @CRLF & "test OK")
EndFunc

Func _Config_Notif_Save_()
	IniWrite($config,"config","update",GuiCtrlRead($config_check_update))
	IniWrite($config,"config","discord_enable",GuiCtrlRead($config_check_discord_enable))
	IniWrite($config,"config","discord_server_on",GuiCtrlRead($config_check_discord_server_on))
	IniWrite($config,"config","discord_server_off",GuiCtrlRead($config_check_discord_server_off))
	IniWrite($config,"config","discord_player_on",GuiCtrlRead($config_check_discord_player_on))
	IniWrite($config,"config","discord_player_off",GuiCtrlRead($config_check_discord_player_off))
	IniWrite($config,"config","discord_hook",GuiCtrlRead($config_input_discord_hook))
	_Config_Notif_Close_()
EndFunc

Func _About_()
	ControlDisable($guiname,"",$gui)
	$guiname_about = _LNG_("gui_about")
	Global $gui_about = GUICreate($guiname_about,700,350,-1,-1,-1,0x00000080,$gui)
		GUISetOnEvent(-3,"_About_Close_",$gui_about)
	GUICtrlCreateTab(20,20,660,275)
	GUICtrlCreateTabItem(_LNG_("gui_about"))
		GUICtrlCreatePic($appdata & "\sysoftek.jpg",30,50,130,130)
		GUICtrlCreateLabel("SMM-Enshrouded",170,50,500,45,0x01)
			GUICtrlSetFont(-1,25)
		GUICtrlCreateLabel(_LNG_("label_about") & ".",170,95,480,125)
			GUICtrlSetFont(-1,13)
		GUICtrlCreateLabel("(c) sysoftek@github",170,255,480,25)
			GUICtrlSetFont(-1,13)
			GUICtrlSetColor(-1,0x0066CC)
			GUICtrlSetCursor(-1,0)
			GUICtrlSetOnEvent(-1,"_About_Web_")
	GUICtrlCreateTabItem(_LNG_("label_tiers"))
		Global $about_tiers = GUICtrlCreateEdit("",25,45,650,243,BitOR(0x0800,0x00100000,0x00200000))
			GUICtrlSetFont(-1,13)
	GUICtrlCreateTabItem(_LNG_("label_license"))
		Global $about_licence = GUICtrlCreateEdit("",25,45,650,243,BitOR(0x0800,0x00100000,0x00200000))
			GUICtrlSetFont(-1,13)
	GUICtrlCreateTabItem("")
	GUICtrlCreateGraphic(10,10,680,295)
	GUICtrlSetColor(-1,0x808080)
	GUICtrlCreateButton(_LNG_("label_close"),615,315,75,25)
		GUICtrlSetOnEvent(-1,"_About_Close_")
	_About_Tiers_()
	_About_Licence_()
	GUISetState()
EndFunc

Func _About_Tiers_()
	$txt_tiers = ""
	$txt_tiers = $txt_tiers & _LNG_("label_dev") & " : AutoIt" & @CRLF
	$txt_tiers = $txt_tiers & _LNG_("label_icons") & " : Fatcow" & @CRLF
	GUICtrlSetData($about_tiers,$txt_tiers)
EndFunc

Func _About_Licence_()
	GUICtrlSetData($about_licence,StringReplace(FileRead($appdata & "\LICENSE.txt"),@LF,@CRLF))
EndFunc

Func _About_Close_()
	GUIDelete($gui_about)
	ControlEnable($guiname,"",$gui)
	WinActivate($guiname)
EndFunc

Func _About_Web_()
	ShellExecute($url_github)
EndFunc

Func _Monitor_()
	If $monitor == 1 Then
		If ProcessExists($exe_pid) Then
			$getcpu_val = _GetCPU_($pid)
			GUICtrlSetData($monitor_cpu,$getcpu_val)
			GUICtrlSetData($monitor_cpuv,$getcpu_val & "%")
			$ram_exe = ProcessGetStats($exe_pid)
			$ram_sys = MemGetStats()
			$ram_val = Ceiling($ram_exe[0] / 1024 / 1024)
			$ram_tot = Ceiling($ram_val / (($ram_sys[2] / 1024) + ($ram_sys[4] / 1024)) * 100)
			GUICtrlSetData($monitor_ram,Ceiling($ram_tot))
			GUICtrlSetData($monitor_ramv,Ceiling($ram_val) & "mo")
			If $monitor_timer == 0 Then
				$monitor_read_start = _GetIO_($pid,"r")
				$monitor_write_start = _GetIO_($pid,"w")
				$monitor_timer = 1
			Else
				$monitor_read_end = _GetIO_($pid,"r")
				$monitor_write_end = _GetIO_($pid,"w")
				$monitor_read_tot = Int(($monitor_read_end - $monitor_read_start) / 1000) / 1000
				$monitor_write_tot = Int(($monitor_write_end - $monitor_write_start) / 1000) / 1000
				GUICtrlSetData($monitor_disk_r,_Convert_($monitor_read_tot) & " Mo / sec")
				GUICtrlSetData($monitor_disk_w,_Convert_($monitor_write_tot) & " Mo / sec")
				$monitor_timer = 0
			EndIf
		EndIf
	EndIf
EndFunc

Func _GetCPU_($getcpu)
	If Not ProcessExists($getcpu) Then Return -1
	Local Static $Prev1_2, $Prev2_2
	Local $Time1_2 = _WinAPI_GetProcessTimes($getcpu)
	Local $Time2_2 = _WinAPI_GetSystemTimes()
	If Not IsArray($Time1_2) Or Not IsArray($Time2_2) Then Return -1
	$Time1_2 = $Time1_2[1] + $Time1_2[2]
	$Time2_2 = $Time2_2[1] + $Time2_2[2]
	$getcpu_tot = Round(($Time1_2 - $Prev1_2) / ($Time2_2 - $Prev2_2) * 100)
	$Prev1_2 = $Time1_2
	$Prev2_2 = $Time2_2
	Return $getcpu_tot
EndFunc

Func _GetIO_($getio_process,$getio_rw)
    If Not ProcessExists($getio_process) Then Return SetError(1,0,0)
    Local $colProcesses,$objProcess,$sngProcessTime
    $colProcesses = $objWMIService.ExecQuery("Select * from Win32_Process Where ProcessId = '" & $getio_process & "'")
		For $objProcess in $colProcesses
			If $getio_rw == "r" Then $sngProcessTime = $objProcess.ReadTransferCount
			If $getio_rw == "w" Then $sngProcessTime = $objProcess.WriteTransferCount
		Next
    Return $sngProcessTime
EndFunc

Func _Convert_($conv_nbr)
	$string_1 = _StringBetween($conv_nbr,"",".")
	If Not @error Then
		$conv_1 = $string_1[0]
	Else
		$conv_1 = 0
	EndIf
	$string_2 = _StringBetween($conv_nbr,".","")
	If @error Then
		$conv_2 = "000"
	Else
		If StringLen($string_2[0]) == 1 Then
			$conv_2 = $string_2[0] & "00"
		ElseIf StringLen($string_2[0]) == 2 Then
			$conv_2 = $string_2[0] & "0"
		Else
			$conv_2 = $string_2[0]
		EndIf
	EndIf
	Return $conv_1 & "." & $conv_2
EndFunc

Func _GUI_Embed_($embed_gui,$embed_pid,$embed_pos_x,$embed_pos_y,$embed_x,$embed_y)
	$embed_hwnd = 0
	$embed_dll = DllStructCreate("int")
	Do
		$embed_winlist = WinList()
		For $i_embed = 1 To $embed_winlist[0][0]
			If $embed_winlist[$i_embed][0] <> "" Then
				DllCall("user32.dll","int","GetWindowThreadProcessId","hwnd",$embed_winlist[$i_embed][1],"ptr",DllStructGetPtr($embed_dll))
				If DllStructGetData($embed_dll,1) = $embed_pid Then
					$embed_hwnd = $embed_winlist[$i_embed][1]
					ExitLoop
				EndIf
			EndIf
		Next
		Sleep(100)
	Until $embed_hwnd <> 0
	$embed_dll = 0
	If $embed_hwnd <> 0 Then
		$embed_style = DllCall("user32.dll","int","GetWindowLong","hwnd",$embed_hwnd,"int",-20)
		$embed_style = $embed_style[0]
		DllCall("user32.dll","int","SetWindowLong","hwnd",$embed_hwnd,"int",-16,"int",0x80880000)
		DllCall("user32.dll","int","SetParent","hwnd",$embed_hwnd,"hwnd",$embed_gui)
		WinSetState($embed_hwnd,"",@SW_SHOW)
		WinMove($embed_hwnd,"",$embed_pos_x,$embed_pos_y,$embed_x,$embed_y)
	EndIf
EndFunc

Func WM_NOTIFY($hWnd,$iMsg,$iwParam,$ilParam)
    Local $tNMHDR,$hWndFrom,$iCode
    $tNMHDR = DllStructCreate($tagNMHDR,$ilParam)
    $hWndFrom = DllStructGetData($tNMHDR,"hWndFrom")
    $iCode = DllStructGetData($tNMHDR,"Code")
    Switch $hWndFrom
        Case $list_config
            Switch $iCode
				Case $NM_DBLCLK
                    Local $aHit = _GUICtrlListView_SubItemHitTest($list_config)
					Global $enter = $aHit
					If $lock == 0 Then
						If ($aHit[0] <> -1) And ($aHit[1] == 1) Then
							HotKeySet("{ENTER}","_Cell_Validate_")
							$Item = $aHit[0]
							$SubItem = $aHit[1]
							Local $iItemText = _GUICtrlListView_GetItemText($list_config,$Item,0)
							Local $iSubItemText = _GUICtrlListView_GetItemText($list_config,$Item,$SubItem)
							Local $aRect = _GUICtrlListView_GetSubItemRect($list_config,$Item,$SubItem)
							If $iItemText <> "" Then
								$WinGetPos = WinGetPos($guiname_config_json)
								$gui_cell = GUICreate("cell",$aRect[2] - $aRect[0] - 3,20,$WinGetPos[0] + $aRect[0] + 3,$WinGetPos[1] + $aRect[1] + 27,0x80000000,0x00000200,$gui_config_json)
								If $aHit[1] == 1 Then
									_Cell_Type_($iItemText,$iSubItemText,$aRect[2] - $aRect[0])
								EndIf
								GUISetState()
								_WinAPI_SetFocus($edit_cell)
								$lock = 1
								AdlibRegister("_Cell_Save_",250)
							EndIf
						EndIf
					EndIf
            EndSwitch
    EndSwitch
EndFunc

Func _Cell_Type_($type_opt,$type_val,$type_size)
	$edit_sel = $type_opt
	$edit_old = $type_val
	$edit_type = 0
	If $type_opt == "name" Then
		$edit_cell = GUICtrlCreateInput(StringReplace($type_val,'"',''),0,0,$type_size,20)
	ElseIf $type_opt == "password" Then
		$edit_cell = GUICtrlCreateInput(StringReplace($type_val,'"',''),0,0,$type_size,20)
	ElseIf $type_opt == "saveDirectory" Then
		$edit_cell = GUICtrlCreateInput(StringReplace($type_val,'"',''),0,0,$type_size,20)
	ElseIf $type_opt == "logDirectory" Then
		$edit_cell = GUICtrlCreateInput(StringReplace($type_val,'"',''),0,0,$type_size,20)
	ElseIf $type_opt == "ip" Then
		$edit_cell = GUICtrlCreateInput(StringReplace($type_val,'"',''),0,0,$type_size,20)
	ElseIf $type_opt == "gamePort" Then
		$edit_cell = GUICtrlCreateInput($type_val,0,0,$type_size,20,0x2000)
		$edit_type = 1
	ElseIf $type_opt == "queryPort" Then
		$edit_cell = GUICtrlCreateInput($type_val,0,0,$type_size,20,0x2000)
		$edit_type = 1
	ElseIf $type_opt == "slotCount" Then
		$edit_cell = GUICtrlCreateInput($type_val,0,0,$type_size,20,0x2000)
		$edit_type = 1
	EndIf
EndFunc

Func _Cell_Save_()
	If ControlGetFocus("cell") <> "Edit1" And ControlGetFocus("cell") <> "ComboBox1" Then
		AdlibUnRegister("_Cell_Save_")
		$read_cell = GUICtrlRead($edit_cell)
		$read = FileRead($config_game)
		$open = FileOpen($config_game,2)
		If $edit_type == 0 Then
			_GUICtrlListView_SetItemText($list_config,$Item,$read_cell,$SubItem)
			FileWrite($open,StringReplace($read,'"' & $edit_sel & '": "' & $edit_old & '"','"' & $edit_sel & '": "' & $read_cell & '"'))
		ElseIf $edit_type == 1 Then
			If StringIsDigit($read_cell) Then _GUICtrlListView_SetItemText($list_config,$Item,$read_cell,$SubItem)
			FileWrite($open,StringReplace($read,'"' & $edit_sel & '": ' & $edit_old,'"' & $edit_sel & '": ' & $read_cell))
		EndIf
		FileClose($open)
		$Item = -1
		$SubItem = 0
		GUIDelete($gui_cell)
		$lock = 0
	EndIf
EndFunc

Func _Cell_Validate_()
	_GUICtrlListView_ClickItem($list_config,$enter[0])
	HotKeySet("{ENTER}")
EndFunc

Func _UnZip_($sZipFile,$sDestFolder)
	$oShell = ObjCreate("shell.application")
	$oZip = $oShell.NameSpace($sZipFile)
	$iZipFileCount = $oZip.items.Count
	For $oFile In $oZip.items
		$oShell.NameSpace($sDestFolder).copyhere($ofile)
	Next
EndFunc

Func _SteamCMD_Win_()
	Opt("TrayIconHide",1)
	ProcessWait("steamcmd.exe")
	Global $guiname_steam = "SteamCMD"
	Global $gui_steam = GUICreate($guiname_steam,500,30,-1,-1,BitXOR(BitOR(0x00020000,0x00C00000,0x80000000,0x00080000),0x00020000),BitOR(0x00000008,0x00000080))
		GUISetOnEvent(-3,"_SteamCMD_Win_Close_",$gui_steam)
	GUICtrlCreateLabel(_LNG_("label_stopsteam"),0,0,500,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,15)
	GUISetState()
	While 1
		If Not ProcessExists("steamcmd.exe") Then Exit
		Sleep(100)
	WEnd
EndFunc

Func _SteamCMD_Win_Close_()
	While 1
		ProcessClose("steamcmd.exe")
		If Not ProcessExists("steamcmd.exe") Then ExitLoop
		Sleep(100)
	WEnd
	Exit
EndFunc

Func _SecToTime_($iSecondes)
    $iHeures = Int($iSecondes / 3600)
    $iSecondesRestantes = $iSecondes - ($iHeures * 3600)
    $iMinutes = Int($iSecondesRestantes / 60)
    $sHeures = StringFormat("%02d", $iHeures)
    $sMinutes = StringFormat("%02d", $iMinutes)
    Return $sHeures & ":" & $sMinutes
EndFunc

Func _Send_Discord_($msg_url,$msg_txt)
	$msg_txt = StringReplace($msg_txt,@CRLF,"\n")
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	Local $Packet = '{"content": "' & $msg_txt & '"}'
	$oHTTP.open('POST',$msg_url)
	$oHTTP.setRequestHeader("Content-Type","application/json")
	$oHTTP.send($Packet)
EndFunc

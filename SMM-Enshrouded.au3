#Region
#AutoIt3Wrapper_Icon=app.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=EnshroudedServer GUI
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_ProductName=EnshroudedServer GUI
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=(c) sysoftek@github
#AutoIt3Wrapper_Res_Language=1036
#EndRegion


#include<GuiButton.au3>
#include<WindowsConstants.au3>
#include<GuiListView.au3>
#include<File.au3>

$solo = ProcessList(@ScriptName)
If $solo[0][0] > 1 Then Exit

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
FileInstall(".\app.jpg",$appdata & "\app.jpg",1)
FileInstall(".\app.lng",$appdata & "\app.lng",1)
FileInstall(".\menu_start.ico",$appdata & "\menu_start.ico",1)
FileInstall(".\menu_stop.ico",$appdata & "\menu_stop.ico",1)
FileInstall(".\menu_restart.ico",$appdata & "\menu_restart.ico",1)
FileInstall(".\cpuramio.exe",$appdata & "\" & $job & "-MON.exe",1)

Global $gui_cell,$edit_cell,$edit_sel,$edit_old,$edit_type,$Item = -1,$SubItem = 0
$lock = 0

$config = $appdata & "\config.ini"
$config_game = @ScriptDir & "\enshrouded_server.json"
$lng = $appdata & "\app.lng"

$config_tab = 0
$pid = 0
$tray_state = 0

$exe = @ScriptDir & "\enshrouded_server.exe"
$exe_pid = "enshrouded_server.exe"

$exe_mon = $appdata & "\" & $job & "-MON.exe"
$exe_mon_pid = $job & "-MON.exe"
$monitor = $appdata & "\monitor.txt"

$guiname = $job
$gui  = GUICreate($guiname,700,515,-1,-1,BitXOR(BitOR(0x00020000,0x00C00000,0x80000000,0x00080000),0x00020000))
	GUISetBkColor(0xffffff)
	GUISetOnEvent(-3,"_Exit_")

GUICtrlCreatePic($appdata & "\app.jpg",5,5,100,100,0x04000000)

$button_lng = GUICtrlCreateButton(IniRead($config,"config","lng","FR"),0,0,30,20)
	GUICtrlSetOnEvent(-1,"_Lng_List_")
	$mn_lng = GUICtrlCreateContextMenu($button_lng)
		$nbr_lng = IniReadSectionNames($lng)
		For $i_lng = 1 To $nbr_lng[0]
			GUICtrlCreateMenuItem($nbr_lng[$i_lng] & " : " & IniRead($lng,$nbr_lng[$i_lng],"lng",""),$mn_lng)
				GUICtrlSetOnEvent(-1,"_Lng_Select_")
		Next

GUICtrlCreateGroup(_LNG_("gp_server"),110,5,90,100) ;lng
	$button_start = GUICtrlCreateButton("",115,20,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_start.ico")
		GUICtrlSetOnEvent(-1,"_Start_")
		GUICtrlSetTip(-1,"")
	$button_stop = GUICtrlCreateButton("",155,20,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_stop.ico")
		GUICtrlSetOnEvent(-1,"_Stop_")
		GUICtrlSetTip(-1,"")
	$button_restart = GUICtrlCreateButton("",135,60,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$appdata & "\menu_restart.ico")
		GUICtrlSetOnEvent(-1,"_Restart_")
		GUICtrlSetTip(-1,"")
GUICtrlCreateGroup(_LNG_("gp_perf"),205,5,230,100) ;lang
	GUICtrlCreateLabel("CPU :",210,25,50,20,0x01)
		GUICtrlSetFont(-1,12)
	$monitor_cpuv = GUICtrlCreateLabel("0%",210,45,50,16,0x01)
		GUICtrlSetFont(-1,8)
	$monitor_cpu = GUICtrlCreateProgress(260,25,170,30,BitOR(0x01,0x10))
	GUICtrlCreateLabel("RAM :",210,65,50,20,0x01)
		GUICtrlSetFont(-1,12)
	$monitor_ramv = GUICtrlCreateLabel("0mo",210,85,50,16,0x01)
		GUICtrlSetFont(-1,8)
	$monitor_ram = GUICtrlCreateProgress(260,65,170,30,BitOR(0x01,0x10))
GUICtrlCreateGroup(_LNG_("gp_disk"),440,5,230,100) ;lang
	GUICtrlCreateLabel("R I/O :",445,25,50,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_disk_r = GUICtrlCreateLabel("0.000 Mo / sec",495,25,170,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	GUICtrlCreateLabel("W I/O :",445,65,50,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)
	$monitor_disk_w = GUICtrlCreateLabel("0.000 Mo / sec",495,65,170,30,BitOR(0x01,0x0200))
		GUICtrlSetFont(-1,12)

$button_config = GUICtrlCreateButton("C" & @CRLF & "O" & @CRLF & "N" & @CRLF & "F" & @CRLF & "I" & @CRLF & "G" & @CRLF & "->",675,10,20,95,BitOR(0,0x2000))
	GUICtrlSetFont(-1,8,400,0,"Courier New")
	GUICtrlSetOnEvent(-1,"_Config_Tab_")

$label_offline = GUICtrlCreateLabel("",5,110,690,400,BitOR(0x01,0x0200),0x00000200)
	GUICtrlSetFont(-1,20)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x000000)

GUICtrlCreateGroup(_LNG_("gp_config"),700,5,390,505) ;lng
	Global $list_config = _GUICtrlListView_Create($gui,_LNG_("list_opt") & "|" & _LNG_("list_val"),705,20,380,480,BitOR(0x0001,0x00200000,0x0004),0x00000200) ;lng
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

ControlDisable($guiname,"",$button_stop)
ControlDisable($guiname,"",$button_restart)

TraySetToolTip($guiname)
	TraySetClick(8)
	TraySetOnEvent(-13,"_Tray_State_")
	$tray_show = TrayCreateItem(_LNG_("tray_hide") & " " & $job)
		TrayItemSetOnEvent(-1,"_Tray_State_")
	TrayCreateItem("")
	TrayCreateItem(_LNG_("tray_quit"))
		TrayItemSetOnEvent(-1,"_Exit_")

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
		$msgbox = MsgBox(52,"- " & _LNG_("msg_avert") & " -",_LNG_("msg_exec"),0,$gui)
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

Func _Config_Tab_()
	$pos = WinGetPos($guiname)
	If $config_tab == 0 Then
		ControlMove($guiname,"",$gui,$pos[0],$pos[1],1100)
		GUICtrlSetData($button_config,"C" & @CRLF & "O" & @CRLF & "N" & @CRLF & "F" & @CRLF & "I" & @CRLF & "G" & @CRLF & "<-")
		$config_tab = 1
	Else
		ControlMove($guiname,"",$gui,$pos[0],$pos[1],705)
		GUICtrlSetData($button_config,"C" & @CRLF & "O" & @CRLF & "N" & @CRLF & "F" & @CRLF & "I" & @CRLF & "G" & @CRLF & "->")
		$config_tab = 0
	EndIf
EndFunc

Func _Start_()
	If Not FileExists($exe) Then
		MsgBox(16,"- " & _LNG_("msg_errorun") & " -",_LNG_("msg_missexe"),0,$gui)
	Else
		If $pid == 0 Then
			$pid = ShellExecute($exe,'',@ScriptDir,"",@SW_HIDE)
			$pid_mon = ShellExecute($exe_mon,'"' & $monitor & '" "' & $exe_pid & '"',$appdata)
			_GUI_Embed_($gui,$pid,5,110,690,400)
			ControlHide($guiname,"",$label_offline)
			ControlDisable($guiname,"",$button_start)
			ControlEnable($guiname,"",$button_stop)
			ControlEnable($guiname,"",$button_restart)
			AdlibRegister("_Monitor_",1000)
			ControlDisable($guiname,"",$button_lng)
			ControlDisable($guiname,"",$list_config)
		EndIf
	EndIf
EndFunc

Func _Stop_()
	AdlibUnRegister("_Monitor_")
	WinActivate($guiname)
	MouseClick("left",55,160,1,0)
	Send("^c")
	_Stop_Monitor_()
EndFunc

Func _Stop_Monitor_()
	AdlibUnRegister("_Monitor_")
	ControlEnable($guiname,"",$button_lng)
	ControlEnable($guiname,"",$list_config)
	While 1
		ProcessClose($exe_mon_pid)
		If Not ProcessExists($exe_mon_pid) Then ExitLoop
		Sleep(100)
	WEnd
	ControlShow($guiname,"",$label_offline)
	ControlEnable($guiname,"",$button_start)
	ControlDisable($guiname,"",$button_stop)
	ControlDisable($guiname,"",$button_restart)
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
	_Start_()
EndFunc

Func _Monitor_()
	$ram_dispo = MemGetStats()
	$ram_tot = Ceiling((FileReadLine($monitor,2) / ($ram_dispo[2] / 1024)) * 100)
	GUICtrlSetData($monitor_cpuv,FileReadLine($monitor,1) & "%")
	GUICtrlSetData($monitor_cpu,FileReadLine($monitor,1))
	GUICtrlSetData($monitor_ramv,FileReadLine($monitor,2) & "mo")
	GUICtrlSetData($monitor_ram,$ram_tot)
	GUICtrlSetData($monitor_disk_r,FileReadLine($monitor,3) & " Mo / sec")
	GUICtrlSetData($monitor_disk_w,FileReadLine($monitor,4) & " Mo / sec")
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
								$WinGetPos = WinGetPos($guiname)
								$gui_cell = GUICreate("cell",$aRect[2] - $aRect[0] - 3,20,$WinGetPos[0] + $aRect[0] + 710,$WinGetPos[1] + $aRect[1] + 47,0x80000000,0x00000200,$gui)
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

Func _Lng_List_()
	ControlClick($guiname,"",$button_lng,"right")
EndFunc

Func _Lng_Select_()
	$lng_select = StringSplit(StringReplace(GUICtrlRead(@GUI_CtrlId,1)," ",""),":")
	If $lng_select[1] <> GUICtrlRead($button_lng) Then
		$msgbox = MsgBox(36,IniRead($lng,$lng_select[1],"msg_lang",""),StringReplace(IniRead($lng,$lng_select[1],"msg_langdesc",""),"[br]",@CRLF) & " " & $guiname & "!",0,$gui)
		If $msgbox == 6 Then
			IniWrite($config,"config","lng",$lng_select[1])
			Exit
		EndIf
	EndIf
EndFunc

Func _LNG_($_lng_)
	$_lng_ = IniRead($lng,IniRead($config,"config","lng","FR"),$_lng_,"<STRING_NOT_TRANSLATED>")
	$_lng_ = StringReplace($_lng_,"[br]",@CRLF)
	Return $_lng_
EndFunc

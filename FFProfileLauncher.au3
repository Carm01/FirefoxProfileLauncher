#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Papirus-Team-Papirus-Apps-Firefox-trunk.ico
#AutoIt3Wrapper_Outfile_x64=FirefoxProfleLauncher.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Will Launch Different Firefox Profiles
#AutoIt3Wrapper_Res_Description=Will Launch Different Firefox Profiles
#AutoIt3Wrapper_Res_Fileversion=1.2.0.1
#AutoIt3Wrapper_Res_ProductName=Firefox Profiles
#AutoIt3Wrapper_Res_ProductVersion=1.2.0.1
#AutoIt3Wrapper_Res_LegalCopyright=Carm01
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <GDIPlus.au3>
#include <GuiConstants.au3>
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <debug.au3>
#include <GUIConstantsEx.au3>

Opt("TrayOnEventMode", 1) ; Use event trapping for tray menu
Opt("TrayMenuMode", 3) ; Default tray menu items will not be shown.

$hTray_Show_Item = TrayCreateItem("Hide")
TrayItemSetOnEvent(-1, "To_Tray")
TrayCreateItem("")
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "On_Exit")

If UBound(ProcessList(@ScriptName)) > 2 Then Exit
Local $q = 0, $readtweekhive, $StartPage, $StartPageCTRL1, $sHomePage1
Local $rr = 0x404040 ; https://www.w3schools.com/colors/colors_picker.asp
Local $listData, $ProfileList, $firefoxSelect, $PrivateMode, $hGUI, $listData1

$zoom = _GDIPlus_GraphicsGetDPIRatio()[0]
; Below is necessary as _GUICtrlHyperLink_Create does not properly compensate for a few links in the GUI scaling for DPI changes.
If $zoom = 1 Then
	$zm = 1
	$zm1 = 255
	$zm2 = 280
Else
	$zm = Round(1 / $zoom, 2)
	$zm1 = 260
	$zm2 = 285
EndIf

;$qw = ProcessGetStats('firefox.exe',$PROCESS_STATS_MEMORY)
;_DebugArrayDisplay($qw)
getprofile()
getversions()
menu()



Func menu()

	Local $hGUI = GUICreate("Firefox Profile Launcher", 290 * $zm, 150 * $zm, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_MINIMIZEBOX), $WS_EX_TOPMOST)

	GUISetBkColor($rr)
	GUISetState(@SW_SHOW, $hGUI)
	GUISetFont(8.5, 700)

	Local $firefoxProfilepick = GUICtrlCreateCombo('', 10 * $zm, 10 * $zm, 180 * $zm, 18 * $zm)
	GUICtrlCreateLabel('Profile', 200 * $zm, 13 * $zm, 210 * $zm, 18 * $zm)
	setfontWhite()
	Local $firefoxversion = GUICtrlCreateCombo('', 10 * $zm, 40 * $zm, 180 * $zm, 18 * $zm)
	GUICtrlCreateLabel('Firefox Edition', 200 * $zm, 43 * $zm, 210 * $zm, 18 * $zm)
	setfontWhite()
	$PrivateMode = GUICtrlCreateCheckbox("Launch in Private Prowsing", 10 * $zm, 70 * $zm, 210 * $zm, 18 * $zm)

	setfontWhite()
	GUICtrlSetData($firefoxProfilepick, $listData, 'select') ; sets data for profiles in pulldown
	GUICtrlSetData($firefoxversion, $listData1, 'select') ; sets data for versions in pulldown
	$saveSettingsAW = GUICtrlCreateButton("Launch Profile", 10 * $zm, 100 * $zm, 100 * $zm, 22 * $zm)
	$FFProfileMgr = GUICtrlCreateButton("Profile Manager", 120 * $zm, 100 * $zm, 100 * $zm, 22 * $zm)
	GUICtrlCreateLabel('Press the [X] in upper right to exit', 10 * $zm, 130 * $zm, 300 * $zm, 15 * $zm)     ; 4.2.1.0 change of wording
	setfontWhite()


	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($hGUI)
				Return
			Case $GUI_EVENT_MINIMIZE
				To_Tray()
			Case $saveSettingsAW
				$firefoxSelect = GUICtrlRead($firefoxProfilepick)
				$firefoxversionSelect = GUICtrlRead($firefoxversion)
				$FirefoxVersionPath = '"C:\Program Files\' & $firefoxversionSelect & '\firefox.exe"'
				#Region checks to see if Private browsing is selected
				If _IsChecked($PrivateMode) Then ; checks to see if Private browsing is selected
					$x = $FirefoxVersionPath & ' -no-remote -private -p ' & $firefoxSelect
				Else
					$x = $FirefoxVersionPath & ' -no-remote -p ' & $firefoxSelect
				EndIf
				#EndRegion checks to see if Private browsing is selected
				#Region Executes specific installation
				If $firefoxSelect <> "" Then
					Run('"' & @ComSpec & '" /c ' & $x, @SystemDir, @SW_HIDE)
					Sleep(5000) ; prevent multiple launches
				EndIf
				#EndRegion Executes specific installation
			Case $FFProfileMgr
				$firefoxversionSelect = GUICtrlRead($firefoxversion)
				If $firefoxversionSelect <> "" Then
					$FirefoxVersionPath = '"C:\Program Files\' & $firefoxversionSelect & '\firefox.exe"'
				Else
					MsgBox(262160, 'ID10T', 'Please Choose a Firefox version')
					ContinueCase
				EndIf
				#Region Handles the profile manager
				If ProcessExists('firefox.exe') Then
					$get = MsgBox(262193, "Danger Will Robinson !", "All instances of Firefox must be closed in order to manage your profiles" & @CRLF & @CRLF & 'Pressing "Ok" will force close all Firefox Instances and launch the default profile manager' & @CRLF & @CRLF & 'You can always choose "Cancel" and manually close Firefox')
					If $get = 1 Then
						If ProcessExists('firefox.exe') Then
							Do
								ProcessClose('firefox.exe')
								Sleep(100)
							Until Not ProcessExists('firefox.exe')
						EndIf

						ShellExecute($FirefoxVersionPath, ' -p', "", '')
						GUISetState(@SW_MINIMIZE, $hGUI)
					ElseIf $get = 2 Then
						ContinueCase
					EndIf
				Else

					ShellExecute($FirefoxVersionPath, ' -p', "", '')
					GUISetState(@SW_MINIMIZE, $hGUI)
				EndIf
				#EndRegion Handles the profile manager
		EndSwitch
	WEnd

	GUIDelete($hGUI)


EndFunc   ;==>menu


#Region gets the firefox profiles
Func getprofile()
	Local $fileProfile
	_FileReadToArray(@AppDataDir & '\Mozilla\Firefox\profiles.ini', $fileProfile)
	For $i = 1 To UBound($fileProfile) - 1
		If StringInStr($fileProfile[$i], '[Profile') >= 1 Then
			$getprofileName = StringSplit($fileProfile[$i + 1], 'Name=', 1)
			$listData &= "|" & $getprofileName[2]
		EndIf
	Next

EndFunc   ;==>getprofile
#EndRegion gets the firefox profiles

#Region Gets the specific installations
Func getversions()
	$FirefoxVersions = _FileListToArrayRec('C:\Program Files', '*Firefox*', $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
	For $i = 1 To UBound($FirefoxVersions) - 1
		$listData1 &= "|" & $FirefoxVersions[$i]
	Next

	;	_DebugArrayDisplay($FirefoxVersions)
EndFunc   ;==>getversions
#EndRegion Gets the specific installations

Func setfontWhite()
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", 0, "wstr", 0)
	GUICtrlSetColor(-1, 0xffffff)
EndFunc   ;==>setfontWhite

#Region DPI Awareness App - workaround
; #FUNCTION# ====================================================================================================================
; Name ..........: _GDIPlus_GraphicsGetDPIRatio
; Description ...: Get DPI Ratio
; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])
; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.
; Return values .: actual DPI Ratio as Array, or set @error to non zero, also @extended may be set
; Author ........: UEZ
; Modified ......: argumentum 2015.06.05 / better error return
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/166479-writing-dpi-awareness-app-workaround/
; Example .......: yes
; ===============================================================================================================================
Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	Local $aResults[2] = [1, 1]
	_GDIPlus_Startup()

	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, $aResults)

	Local $aResult
	#forcedef $__g_hGDIPDll, $ghGDIPDll
	$aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)
	If @error Then Return SetError(2, @error, $aResults)

	Local $iDPI = $aResult[2]
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResults

EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio
#EndRegion DPI Awareness App - workaround

Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func To_Tray()

	If TrayItemGetText($hTray_Show_Item) = "Hide" Then
		GUISetState(@SW_HIDE, $hGUI)
		TrayItemSetText($hTray_Show_Item, "Show")
	Else
		GUISetState(@SW_SHOW, $hGUI)
		GUISetState(@SW_RESTORE, $hGUI)
		TrayItemSetText($hTray_Show_Item, "Hide")
	EndIf

EndFunc   ;==>To_Tray

Func On_Exit()
	Exit
EndFunc   ;==>On_Exit

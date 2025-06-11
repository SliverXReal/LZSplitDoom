;LZSplitDoom v1.68 - 32 Bit
;A Launcher for Split Screen LZDoom Functionality
;2024 Sliver X
;sliverxreal@proton.me

;No tray icon!
#NoTrayIcon

;Needed Includes.
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <GUIComboBox.au3>
#include <ColorConstants.au3>

;=============================================================================================
;========================================= Initialization ====================================
;=============================================================================================

;Where is the BIN folder & INI file?
Global $BINFOLDER = (@ScriptDir & '\BIN')
Global $SystemConfig = (@ScriptDir & '\LZSplitDoom.ini')

;Recreate launcher INI if it doesn't exist.
CREATESYSTEMINI()

;Load all INI variables.
READINIVALUES()

;Setup core Player stuff.
SETUPPLAYERS()

;Kill any hanged instances of LZDoom that may be present from previous run.
KILLHANGED()

;Determine if invoked with CLI switches or not.
CLIORGUI()

;Not ran from CLI: Build GUI objects.
CREATEGUI()

;Now set state of GUI from INI values...
INITIALIZEGUI()

;Begin GUI Loop!
GUIMAINLOOP()

Exit

;=============================================================================================
;========================================= FUNCTIONS =========================================
;=============================================================================================

;=============================================================================================
;=============================== Kill Hanged LZDoom EXEs! ====================================
;=============================================================================================
;Failsafe!
Func KILLHANGED()
;Check...
If ProcessExists("lzdoom32.exe") Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "killprocess lzdoom32.exe")
EndIf
EndFunc


;=============================================================================================
;============================== Recreate Launcher INI Function ===============================
;=============================================================================================
;LZSplitDoom.ini is missing! Recreate it!
Func CREATESYSTEMINI()
If Not FileExists ($SystemConfig) Then
$sFileName = ($SystemConfig)
$hFilehandle = FileOpen($sFileName, $FO_OVERWRITE)
FileWrite($hFilehandle, '[LZSplitDoom]' & @CRLF & _
'CFGFOLDER=' & @CRLF & _
'WADFOLDER=' & @CRLF & _
'CUSTOMGAMEFOLDER=' & @CRLF & _
'GAME=freedoom1' & @CRLF & _
'WARP=E1M1' & @CRLF & _
'MODE=COOP' & @CRLF & _
'DIFFICULTY=4' & @CRLF & _
'SPLITMODE=Vertical' & @CRLF & _
'CUSTOMCL=' & @CRLF & _
'ALTDM=0' & @CRLF & _
'NOMONSTERS=0' & @CRLF & _
'FASTMONSTERS=0' & @CRLF & _
'RESPAWN=0' & @CRLF & _
'HEXCLASS1=fighter' & @CRLF & _
'HEXCLASS2=cleric' & @CRLF & _
'HEXCLASS3=mage' & @CRLF & _
'HEXCLASS4=fighter' & @CRLF & _
'LOADSAVE=0' & @CRLF & _
'LASTSAVE=none' & @CRLF & _
'MIRROR=0' & @CRLF & _
'LASTCUSTOMGAME=none')
FileClose($hFilehandle)
EndIf
EndFunc

;=============================================================================================
;================================== Read INI Values ==========================================
;=============================================================================================
Func READINIVALUES()
;Load all variables from INI file...
Global $ALTDM = IniRead($SystemConfig, "LZSplitDoom", "ALTDM", "")
Global $CUSTOMCL = IniRead($SystemConfig, "LZSplitDoom", "CUSTOMCL", "")
Global $DIFFICULTY = IniRead($SystemConfig, "LZSplitDoom", "DIFFICULTY", "")
Global $FASTMONSTERS = IniRead($SystemConfig, "LZSplitDoom", "FASTMONSTERS", "")
Global $HEXCLASS1 = IniRead($SystemConfig, "LZSplitDoom", "HEXCLASS1", "")
Global $HEXCLASS2 = IniRead($SystemConfig, "LZSplitDoom", "HEXCLASS2", "")
Global $HEXCLASS3 = IniRead($SystemConfig, "LZSplitDoom", "HEXCLASS3", "")
Global $HEXCLASS4 = IniRead($SystemConfig, "LZSplitDoom", "HEXCLASS4", "")
Global $NOMONSTERS = IniRead($SystemConfig, "LZSplitDoom", "NOMONSTERS", "")
Global $RESPAWN = IniRead($SystemConfig, "LZSplitDoom", "RESPAWN", "")
Global $MODE = IniRead($SystemConfig, "LZSplitDoom", "MODE", "")
Global $SPLITMODE = IniRead($SystemConfig, "LZSplitDoom", "SPLITMODE", "")
Global $GAME = IniRead($SystemConfig, "LZSplitDoom", "GAME", "")
Global $WARP = IniRead($SystemConfig, "LZSplitDoom", "WARP", "")
Global $LASTSAVE = IniRead($SystemConfig, "LZSplitDoom", "LASTSAVE", "")
Global $LOADSAVE = IniRead($SystemConfig, "LZSplitDoom", "LOADSAVE", "")
Global $LASTCUSTOMGAME = IniRead($SystemConfig, "LZSplitDoom", "LASTCUSTOMGAME", "")
Global $MIRROR = IniRead($SystemConfig, "LZSplitDoom", "MIRROR", "")
Global $CFGFOLDER = IniRead($SystemConfig, "LZSplitDoom", "CFGFOLDER", "")
Global $WADFOLDER = IniRead($SystemConfig, "LZSplitDoom", "WADFOLDER", "")
Global $GAMEFOLDER = IniRead($SystemConfig, "LZSplitDoom", "CUSTOMGAMEFOLDER", "")

;Config Folder.
If $CFGFOLDER = "" Then
Global $CFGFOLDER = (@ScriptDir & '\CFG')
Else
Global $CFGFOLDER = $CFGFOLDER
EndIf

;WAD Folder.
If $WADFOLDER = "" Then
Global $WADFOLDER = (@ScriptDir & '\DATA')
Else
Global $WADFOLDER = $WADFOLDER
EndIf

;Custom Game Template Folder.
If $GAMEFOLDER = "" Then
Global $GAMEFOLDER = (@ScriptDir & '\CUSTOM_GAMES')
Else
Global $GAMEFOLDER = $GAMEFOLDER
EndIf

EndFunc


;=============================================================================================
;===============================  Set Core Player Values ====================================
;=============================================================================================
;Core Variables.
Func SETUPPLAYERS()

;Player Directory Variables.
Global $Player1Config = ($CFGFOLDER & '\player1\player1.ini')
Global $Player2Config = ($CFGFOLDER & '\player2\player2.ini')
Global $Player3Config = ($CFGFOLDER & '\player3\player3.ini')
Global $Player4Config = ($CFGFOLDER & '\player4\player4.ini')
Global $SAVEPATHP1 = ($CFGFOLDER & "\player1\SAV\")
Global $SAVEPATHP2 = ($CFGFOLDER & "\player2\SAV\")
Global $SAVEPATHP3 = ($CFGFOLDER & "\player3\SAV\")
Global $SAVEPATHP4 = ($CFGFOLDER & "\player4\SAV\")

;Create Save folders for P1-P4
For $PLAYERID = 1 To 4

If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\doom") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\doom")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\doom2") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\doom2")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\tnt") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\tnt")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\plutonia") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\plutonia")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\heretic") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\heretic")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hexen") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hexen")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hexdd") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hexdd")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\freedoom1") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\freedoom1")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\freedoom2") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\freedoom2")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\chex") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\chex")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hacx") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\hacx")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\strife") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\strife")
EndIf
If Not FileExists ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\custom") Then
DirCreate ($CFGFOLDER & "\player" & $PLAYERID & "\SAV\custom")
EndIf
If $PLAYERID = 4 Then ExitLoop
Next

EndFunc


;=============================================================================================
;================================ CLI OR GUI MODE? ===========================================
;=============================================================================================
Func CLIORGUI()
;Determine if we're running in Command Line Mode or if the GUI needs created/ran...
If Not $CmdLine[0]=0 Then
CLIMODE()
EndIf
EndFunc

;=============================================================================================
;================================ White Font/Black BG ========================================
;=============================================================================================
Func BLACKANDWHITE()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x000000)
EndFunc

;=============================================================================================
;================================ SET MAP COMBOBOX ===========================================
;=============================================================================================
Func SETMAPSELECT()
Global $WARP = IniRead($SystemConfig, "LZSplitDoom", "WARP", "")
_GUICtrlComboBox_SetCurSel($Combo1, 0)
_GUICtrlComboBox_SelectString($Combo1, $WARP)
EndFunc

;=============================================================================================
;================================ SET MAP AND MODE COMBOBOX STATUS ===========================
;=============================================================================================
Func WARPANDMODE()

;Level and Mode controls enabled unless Custom.
GUICtrlSetstate($Combo1,$GUI_ENABLE)
GUICtrlSetstate($Combo2,$GUI_ENABLE)

Global $GAME = IniRead($SystemConfig, "LZSplitDoom", "GAME", "")

EndFunc

;=============================================================================================
;================================ Save Game Functions ========================================
;=============================================================================================
;Save Game Load Checkbox: Disable Map Select, Etc!
Func SAVEDATAHANDLER()

;Enable Load Save Game checkbox.
GUICtrlSetstate($CheckBox5,$GUI_Enable)

;Determine if checkbox is checked.
Global $LOADSAVE = IniRead($SystemConfig, "LZSplitDoom", "LOADSAVE", "")

;It is. Disable Map Select box and enable Save Selector box. If not, do the opposite.
If $LOADSAVE = "1" Then
GUICtrlSetState($CheckBox5, $GUI_CHECKED)
GUICtrlSetstate($Combo9,$GUI_Enable)
GUICtrlSetstate($Label2,$GUI_Disable)
GUICtrlSetstate($Combo1,$GUI_Disable)
IniWrite($SystemConfig, "LZSplitDoom", "WARP", "")
Else
GUICtrlSetState($CheckBox5, $GUI_UNCHECKED)
GUICtrlSetstate($Combo9,$GUI_Disable)
GUICtrlSetstate($Label2,$GUI_Enable)
GUICtrlSetstate($Combo1,$GUI_Enable)
SETMAPSELECT()
IniWrite($SystemConfig, "LZSplitDoom", "LASTSAVE", "none")
EndIf

 ;Determine if saves exist for current game and also set save path in player1.ini to reflect game...
Global $GAME = IniRead($SystemConfig, "LZSplitDoom", "GAME", "")

;Check if we have a custom game template loaded!
Global $GAMENAME = IniRead($GAMEFOLDER & "\" & $LASTCUSTOMGAME, "LZSplitDoomCustomGame", "GAMENAME", "")
If $GAME = "custom" And $GAMENAME <> "" Then

For $PLAYERID = 1 To 4

If Not FileExists ($CFGFOLDER  & "\player" & $PLAYERID & "\SAV\" & $GAMENAME) Then
DirCreate ($CFGFOLDER  & "\player" & $PLAYERID & "\SAV\" & $GAMENAME)
EndIf
If Not FileExists ($WADFOLDER & "\" & $GAMENAME) Then
DirCreate ($WADFOLDER & "\" & $GAMENAME)
EndIf

If $PLAYERID = 4 Then ExitLoop
Next
Global $GAME = ($GAMENAME)
EndIf

Global $SAVEPATHP1 = ($CFGFOLDER  & "\player1\SAV\" & $GAME & '\')
Global $SAVEPATHP2 = ($CFGFOLDER  & "\player2\SAV\" & $GAME & '\')
Global $SAVEPATHP3 = ($CFGFOLDER  & "\player3\SAV\" & $GAME & '\')
Global $SAVEPATHP4 = ($CFGFOLDER  & "\player4\SAV\" & $GAME & '\')
SAVEERRATA()
EndFunc

;=============================================================================================
;============================ Hexen Classes Control States ===================================
;=============================================================================================
Func HEXENCLASSESCHECK()
Global $GAME = IniRead($SystemConfig, "LZSplitDoom", "GAME", "")

GUICtrlSetstate($Combo5,$GUI_DISABLE)
GUICtrlSetstate($Combo6,$GUI_DISABLE)
GUICtrlSetstate($Combo7,$GUI_DISABLE)
GUICtrlSetstate($Combo8,$GUI_DISABLE)
GUICtrlSetstate($Label7,$GUI_DISABLE)
GUICtrlSetstate($Label8,$GUI_DISABLE)
GUICtrlSetstate($Label9,$GUI_DISABLE)
GUICtrlSetstate($Label10,$GUI_DISABLE)
GUICtrlSetstate($Label11,$GUI_DISABLE)

;Check if Hexen or Hexen - Death Kings radio button is checked: If so, enable Hexen Class comboboxes...
If $GAME = "hexen" OR $GAME = "hexdd" Then
GUICtrlSetstate($Label7,$GUI_ENABLE)

;Set control box status for two players by default...
GUICtrlSetstate($Combo5,$GUI_ENABLE)
GUICtrlSetstate($Combo6,$GUI_ENABLE)
GUICtrlSetstate($Combo7,$GUI_DISABLE)
GUICtrlSetstate($Combo8,$GUI_DISABLE)
GUICtrlSetstate($Label8,$GUI_ENABLE)
GUICtrlSetstate($Label9,$GUI_ENABLE)
GUICtrlSetstate($Label10,$GUI_DISABLE)
GUICtrlSetstate($Label11,$GUI_DISABLE)

;Enable three if Tri split is set.
If $SPLITMODE = "TriH" OR $SPLITMODE = "TriV" Then
GUICtrlSetstate($Combo5,$GUI_ENABLE)
GUICtrlSetstate($Combo6,$GUI_ENABLE)
GUICtrlSetstate($Combo7,$GUI_ENABLE)
GUICtrlSetstate($Combo8,$GUI_DISABLE)
GUICtrlSetstate($Label8,$GUI_ENABLE)
GUICtrlSetstate($Label9,$GUI_ENABLE)
GUICtrlSetstate($Label10,$GUI_ENABLE)
GUICtrlSetstate($Label11,$GUI_DISABLE)
EndIf

;Enable all four if Quad split is set.
If $SPLITMODE = "Quad" Then
GUICtrlSetstate($Combo5,$GUI_ENABLE)
GUICtrlSetstate($Combo6,$GUI_ENABLE)
GUICtrlSetstate($Combo7,$GUI_ENABLE)
GUICtrlSetstate($Combo8,$GUI_ENABLE)
GUICtrlSetstate($Label8,$GUI_ENABLE)
GUICtrlSetstate($Label9,$GUI_ENABLE)
GUICtrlSetstate($Label10,$GUI_ENABLE)
GUICtrlSetstate($Label11,$GUI_ENABLE)
EndIf

EndIf

EndFunc

;=============================================================================================
;=========================== Player INI File Prep Function ===================================
;=============================================================================================
Func INISETUP()

;Check if player1.ini exists: If not, copy over defaults template...
If Not FileExists ($Player1Config) Then
RECREATEDEFAULTS()
EndIf

;Set .\DATA as WAD path in player1.ini if it doesn't exist.
Global $WADPATH = (IniRead($Player1Config, "IWADSearch.Directories", "Path", ""))
If $WADPATH <> $WADFOLDER Then
IniWrite($Player1Config, "IWADSearch.Directories", "Path", $WADFOLDER)
EndIf

;Set .\DATA as FILE path in player1.ini if it doesn't exist.
Global $FILEPATH = (IniRead($Player1Config, "FileSearch.Directories", "Path", ""))
If $FILEPATH <> $WADFOLDER Then
IniWrite($Player1Config, "FileSearch.Directories", "Path", $WADFOLDER)
EndIf

;Save path for P1: Alter this for P2-P4's INIs...
IniWrite($Player1Config, "GlobalSettings", "save_dir", $SAVEPATHP1)

;Copy player 1's config for player 2...
FileCopy ($Player1Config, $Player2Config, 9 )

;Create P3 config files if Tri Split defined.
If ($SPLITMODE="TriH" OR $SPLITMODE="TriV") Then
FileCopy ($Player1Config, $Player3Config, 9 )
EndIf

;Create P3 and P4 config files if Quad Split defined.
If ($SPLITMODE="Quad") Then
FileCopy ($Player1Config, $Player3Config, 9 )
FileCopy ($Player1Config, $Player4Config, 9 )
EndIf

;Edit player 2's config to set controls for XInput Device #2, etc.
Global $sDirFile = $Player2Config
$sDir = FileRead($sDirFile)
$res = StringRegExpReplace($sDir, '((?m)^(?i)dpad)', 'dpad2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad_)', 'pad2_', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lshoulder)', 'lshoulder2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rshoulder)', 'rshoulder2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)ltrigger)', 'ltrigger2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rtrigger)', 'rtrigger2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lthumb)', 'lthumb2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rthumb)', 'rthumb2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lstick)', 'lstick2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rstick)', 'rstick2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad2_back.*)', 'pad2_back=', "")
$res = StringRegExpReplace($res, '((?m)^snd_musicvolume.*)', 'snd_musicvolume=0', "")
$res = StringRegExpReplace($res, '((?m)XI:0)', 'XI:X', "")
$res = StringRegExpReplace($res, '((?m)XI:1)', 'XI:0', "")
$res = StringRegExpReplace($res, '((?m)XI:X)', 'XI:1', "")
$res = StringRegExpReplace($res, '((?m)^(?i)name=.*)', 'name=Player_2', "")
$res = StringRegExpReplace($res, '((?m)^(?i)colorset.*)', 'colorset=1', "")
$file = FileOpen($sDirFile, 2)
FileWrite($file, $res)
FileClose($file)
;Set Save Path...
IniWrite($Player2Config, "GlobalSettings", "save_dir", $SAVEPATHP2)

;If using Tri split, edit P3's config.
If ($SPLITMODE="TriH" OR $SPLITMODE="TriV") Then
Global $sDirFile = $Player3Config
$sDir = FileRead($sDirFile)
$res = StringRegExpReplace($sDir, '((?m)^(?i)dpad)', 'dpad3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad_)', 'pad3_', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lshoulder)', 'lshoulder3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rshoulder)', 'rshoulder3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)ltrigger)', 'ltrigger3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rtrigger)', 'rtrigger3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lthumb)', 'lthumb3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rthumb)', 'rthumb3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lstick)', 'lstick3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rstick)', 'rstick3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad3_back.*)', 'pad3_back=', "")
$res = StringRegExpReplace($res, '((?m)^snd_musicvolume.*)', 'snd_musicvolume=0', "")
$res = StringRegExpReplace($res, '((?m)XI:0)', 'XI:X', "")
$res = StringRegExpReplace($res, '((?m)XI:2)', 'XI:0', "")
$res = StringRegExpReplace($res, '((?m)XI:X)', 'XI:2', "")
$res = StringRegExpReplace($res, '((?m)^name=.*)', 'name=Player_3', "")
$res = StringRegExpReplace($res, '((?m)^colorset.*)', 'colorset=2', "")
$file = FileOpen($sDirFile, 2)
FileWrite($file, $res)
FileClose($file)
;Set Save Path...
IniWrite($Player3Config, "GlobalSettings", "save_dir", $SAVEPATHP3)
EndIf

;If using Quad split, edit P3 and P4's config.
If ($SPLITMODE="Quad") Then
Global $sDirFile = $Player3Config
$sDir = FileRead($sDirFile)
$res = StringRegExpReplace($sDir, '((?m)^(?i)dpad)', 'dpad3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad_)', 'pad3_', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lshoulder)', 'lshoulder3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rshoulder)', 'rshoulder3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)ltrigger)', 'ltrigger3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rtrigger)', 'rtrigger3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lthumb)', 'lthumb3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rthumb)', 'rthumb3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lstick)', 'lstick3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rstick)', 'rstick3', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad3_back.*)', 'pad3_back=', "")
$res = StringRegExpReplace($res, '((?m)^snd_musicvolume.*)', 'snd_musicvolume=0', "")
$res = StringRegExpReplace($res, '((?m)XI:0)', 'XI:X', "")
$res = StringRegExpReplace($res, '((?m)XI:2)', 'XI:0', "")
$res = StringRegExpReplace($res, '((?m)XI:X)', 'XI:2', "")
$res = StringRegExpReplace($res, '((?m)^name=.*)', 'name=Player_3', "")
$res = StringRegExpReplace($res, '((?m)^colorset.*)', 'colorset=2', "")
$file = FileOpen($sDirFile, 2)
FileWrite($file, $res)
FileClose($file)
;Set Save Path...
IniWrite($Player3Config, "GlobalSettings", "save_dir", $SAVEPATHP3)

Global $sDirFile = $Player4Config
$sDir = FileRead($sDirFile)
$res = StringRegExpReplace($sDir, '((?m)^(?i)dpad)', 'dpad4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad_)', 'pad4_', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lshoulder)', 'lshoulder4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rshoulder)', 'rshoulder4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)ltrigger)', 'ltrigger4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rtrigger)', 'rtrigger4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lthumb)', 'lthumb4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rthumb)', 'rthumb4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)lstick)', 'lstick4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)rstick)', 'rstick4', "")
$res = StringRegExpReplace($res, '((?m)^(?i)pad4_back.*)', 'pad4_back=', "")
$res = StringRegExpReplace($res, '((?m)^snd_musicvolume.*)', 'snd_musicvolume=0', "")
$res = StringRegExpReplace($res, '((?m)XI:0)', 'XI:X', "")
$res = StringRegExpReplace($res, '((?m)XI:3)', 'XI:0', "")
$res = StringRegExpReplace($res, '((?m)XI:X)', 'XI:3', "")
$res = StringRegExpReplace($res, '((?m)^name=.*)', 'name=Player_4', "")
$res = StringRegExpReplace($res, '((?m)^colorset.*)', 'colorset=3', "")
$file = FileOpen($sDirFile, 2)
FileWrite($file, $res)
FileClose($file)
;Set Save Path...
IniWrite($Player4Config, "GlobalSettings", "save_dir", $SAVEPATHP4)
EndIf
EndFunc

;=============================================================================================
;========================================= COMMAND LINE MODE =================================
;=============================================================================================
Func CLIMODE()
;Command line parameters were passed! Now parse the flags we care about...
For $i = 1 To $CmdLine[0]
Select

;Rebuild Configs/INI!
Case $CmdLine[$i] == "-resetconfig"
FileDelete ($CFGFOLDER & "\player1\player1.ini")
FileDelete ($CFGFOLDER & "\player2\player2.ini")
FileDelete ($CFGFOLDER & "\player3\player3.ini")
FileDelete ($CFGFOLDER & "\player4\player4.ini")
FileDelete ($SystemConfig)
If Not FileExists ($CFGFOLDER & "\player1\player1.ini") And Not FileExists ($SystemConfig) And Not FileExists ($CFGFOLDER & "\player2\player2.ini") And Not FileExists ($CFGFOLDER & "\player3\player3.ini") And Not FileExists ($CFGFOLDER & "\player4\player4.ini") Then
ConsoleWrite ("Configuration data cleared. Run LZSplitDoom to generate new configs." & @CRLF)
Exit
Else
ConsoleWrite ("Configuration data not cleared. Check permissions?" & @CRLF)
Exit
EndIf

;Split Mirror Mode!
Case $CmdLine[$i] == "-mirror=1"
Global $MIRROR = "1"
IniWrite ($SystemConfig, "LZSplitDoom", "MIRROR", "1")

Case $CmdLine[$i] == "-mirror=0"
Global $MIRROR = "0"
IniWrite ($SystemConfig, "LZSplitDoom", "MIRROR", "0")

;Hexen Classes
Case $CmdLine[$i] == "-p1class=fighter"
Global $HEXCLASS1 = "fighter"
Case $CmdLine[$i] == "-p1class=cleric"
Global $HEXCLASS1 = "cleric"
Case $CmdLine[$i] == "-p1class=mage"
Global $HEXCLASS1 = "mage"

Case $CmdLine[$i] == "-p2class=fighter"
Global $HEXCLASS2 = "fighter"
Case $CmdLine[$i] == "-p2class=cleric"
Global $HEXCLASS2 = "cleric"
Case $CmdLine[$i] == "-p2class=mage"
Global $HEXCLASS2 = "mage"

Case $CmdLine[$i] == "-p3class=fighter"
Global $HEXCLASS3 = "fighter"
Case $CmdLine[$i] == "-p3class=cleric"
Global $HEXCLASS3 = "cleric"
Case $CmdLine[$i] == "-p3class=mage"
Global $HEXCLASS3 = "mage"

Case $CmdLine[$i] == "-p4class=fighter"
Global $HEXCLASS4 = "fighter"
Case $CmdLine[$i] == "-p4class=cleric"
Global $HEXCLASS4 = "cleric"
Case $CmdLine[$i] == "-p4class=mage"
Global $HEXCLASS4 = "mage"

;Help Screen
Case $CmdLine[$i] == "-help"
ConsoleWrite(@CRLF & "LZSplitDoom v1.68 (32 Bit)Command Line Options" & @crlf & @crlf & "[ Split Screen Type (Required) ]" & @crlf & @crlf & "-split={FLAG}" & @crlf & @crlf & "{FLAG} values: vertical | horizontal | trih | triv | quad" & @crlf & @crlf & "Split the screen in two (vertically or horizontally), into thirds or fourths." & @crlf & @crlf & "-mirror={BOOL}" & @crlf & @crlf & "{BOOL} values: 1 | 0"  & @crlf & @crlf & "Invert Splitscreen Layout" & @crlf & @crlf & "[ Hexen Class Type ]" & @crlf & @crlf & "-p1class={FLAG}" & @crlf & "-p2class={FLAG}" & @crlf & "-p3class={FLAG}" & @crlf & "-p4class={FLAG}" & @crlf & @crlf & "{FLAG} values: fighter | cleric | mage" & @crlf & @crlf & "Set Player Classes. Values are ignored by LZDoom if not a Hexen based game."  & @crlf & @crlf & "[ Reset Config ]" & @crlf & @crlf & "-resetconfig"  & @crlf & @crlf & "Wipe Player/Launcher configs to be rebuilt at next run." & @crlf & @crlf & "[ Example Usage ]" & @crlf & @crlf & "[ 2 Player Hexen Deathmatch ]" & @crlf & "lzsplitdoom32.exe -split=vertical -p1class=mage -p2class=cleric -iwad hexen.wad -deathmatch -nomonsters" & @crlf & @crlf & "[ 4 Player Doom 2 + Brutal Doom Coop ]" & @crlf & "lzsplitdoom32.exe -split=quad -mirror=0 -iwad doom2.wad -file brutaldoom.pk3" & @crlf)
Exit
EndSelect
Next

;Set 2 Players by default, change if Tri/Quad enabled!
Global $HOSTESS=2

;Split Screen Mode: This one is required!
For $i = 1 To $CmdLine[0]
Select
Case $CmdLine[$i] == "-split=vertical"
Global $SPLITMODE = "Vertical"
CLIMODELAUNCH()
Case $CmdLine[$i] == "-split=horizontal"
Global $SPLITMODE = "Horizontal"
CLIMODELAUNCH()
Case $CmdLine[$i] == "-split=trih"
Global $SPLITMODE = "TriH"
Global $HOSTESS=3
CLIMODELAUNCH()
Case $CmdLine[$i] == "-split=triv"
Global $SPLITMODE = "TriV"
Global $HOSTESS=3
CLIMODELAUNCH()
Case $CmdLine[$i] == "-split=quad"
Global $SPLITMODE = "Quad"
Global $HOSTESS=4
CLIMODELAUNCH()

Case Else
;User didn't define split screen mode. Scold them and fail!
If Not StringRegExp ($CmdLineRaw, '(^|\s)-split=horizontal($|\s)') And Not StringRegExp ($CmdLineRaw, '(^|\s)-split=vertical($|\s)') And Not StringRegExp ($CmdLineRaw, '(^|\s)-split=trih($|\s)') And Not StringRegExp ($CmdLineRaw, '(^|\s)-split=triv($|\s)') And Not StringRegExp ($CmdLineRaw, '(^|\s)-split=quad($|\s)') Then
ConsoleWrite(@crlf & "LZSplitDoom - Error"  & @crlf & @crlf & "Split switch must be defined!" & @crlf & @crlf & "[ Examples ]" & @crlf & @crlf & "-split=horizontal" & @crlf & "-split=vertical" & @crlf & "-split=trih" & @crlf & "-split=triv" & @crlf & "-split=quad" & @crlf & @crlf & "Type lzsplitdoom32.exe -help for more information." & @crlf)
Exit
EndIf

EndSelect
Next
EndFunc

;=============================================================================================
;=================================== CLI Mode Run Function ===================================
;=============================================================================================
;Set up stuff for CLI mode and call execution function!
Func CLIMODELAUNCH()

;Set flag indicating we ran from a CLI...
Global $RANFROMCLI=1

;User didn't define iwad. Scold them and fail!
If Not StringInStr ($CmdLineRaw, "-iwad") Then
ConsoleWrite(@crlf & "LZSplitDoom - Error" & @crlf & @crlf & "IWAD switch must be defined!" & @crlf & @crlf & "[ Example ]" & @crlf & @crlf & "-iwad heretic.wad" & @crlf & @crlf & "Type lzsplitdoom32.exe -help for more information." & @crlf)
Exit
EndIf

;Configure player INI files.
INISETUP()

;Set P1-P4 LZDoom parameters.
Global $PLAYER1CLI=("-config " & '"' & $Player1Config & '"' & " " & $CmdLineRaw & " +fullscreen 0 -host " & $HOSTESS & " +playerclass " & $HEXCLASS1)
Global $PLAYER2CLI=("-config " & '"' & $Player2Config & '"' & " " & $CmdLineRaw & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS2)
Global $PLAYER3CLI=("-config " & '"' & $Player3Config & '"' & " " & $CmdLineRaw & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS3)
Global $PLAYER4CLI=("-config " & '"' & $Player4Config & '"' & " " & $CmdLineRaw & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS4)

;Execute Game!
EXECUTIONETTE()
EndFunc

;============================================================================================
;========================================= Create GUI ========================================
;============================================================================================
Func CREATEGUI()
;Define GUI/Objects.
#Region ### START Koda GUI section ### Form=LZSplitDoom.kxf
Global $width = 580 ; Width of the GUI
Global $height = 452 ; Height of the GUI
Global $Form1_1 = GUICreate("LZSplitDoom v1.68 (32 Bit)", $width, $height, (@DesktopWidth / 2) - ($width / 2), (@DesktopHeight / 2) - ($height / 2))

;Set theme/colors of GUI...
DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", 0)
GUISetBkColor($COLOR_BLACK)

;Screen Layout Legend
If $MIRROR = "0" Then
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32.gif", 304, 64, 250, 181)
Else
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32m.gif", 304, 64, 250, 181)
EndIf

;Game Type Radiobox - Doom
Global $Radio1 = GUICtrlCreateRadio("Doom", 24, 38, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Doom 2
Global $Radio2 = GUICtrlCreateRadio("Doom 2", 24, 64, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Final Doom: Evilution
Global $Radio3 = GUICtrlCreateRadio("Final Doom - Evilution", 24, 90, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Final Doom: The Plutonia Experiment
Global $Radio4 = GUICtrlCreateRadio("Final Doom - Plutonia", 24, 116, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Heretic
Global $Radio5 = GUICtrlCreateRadio("Heretic", 24, 140, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Hexen
Global $Radio6 = GUICtrlCreateRadio("Hexen", 24, 168, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Hexen Death Kings
Global $Radio7 = GUICtrlCreateRadio("Hexen - Death Kings", 24, 194, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Strife
Global $Radio8 = GUICtrlCreateRadio("Strife", 24, 220, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Hacx v1.4
Global $Radio9 = GUICtrlCreateRadio("Hacx", 24, 246, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Chex Quest 3
Global $Radio10 = GUICtrlCreateRadio("Chex Quest", 24, 270, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Freedoom
Global $Radio11 = GUICtrlCreateRadio("Freedoom Phase 1", 24, 298, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Freedoom 2
Global $Radio12 = GUICtrlCreateRadio("Freedoom Phase 2", 24, 324, 130, 16)
BLACKANDWHITE()

;Game Type Radiobox - Custom Game
Global $Radio15 = GUICtrlCreateRadio("Custom", 24, 350, 130, 16)
BLACKANDWHITE()

;Combobox - Level Select
Global $Combo1 = GUICtrlCreateCombo("", 192, 32, 98, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL)
BLACKANDWHITE()

;Combobox - Game Type
Global $Combo2 = GUICtrlCreateCombo("", 192, 88, 98, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Difficulty Level
Global $Combo3 = GUICtrlCreateCombo("", 192, 144, 98, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Split Screen Type
Global $Combo4 = GUICtrlCreateCombo("", 192, 200, 98, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Save Game Load
Global $Combo9 = GUICtrlCreateCombo("none", 305, 32, 54, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL)
BLACKANDWHITE()

;Button - Delete Save
Global $Button2 = GUICtrlCreateButton("Delete", 364, 30, 40, 25, $SS_CENTER)
BLACKANDWHITE()

;Combobox - Custom Game Template List
Global $Combo10 = GUICtrlCreateCombo("none", 418, 32, 136, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL)
BLACKANDWHITE()

;Editbox - Custom Command Line
Global $Edit1 = GUICtrlCreateEdit("", 192, 256, 361, 28, $ES_AUTOHSCROLL)
BLACKANDWHITE()

;Checkbox - Deathmatch Type
Global $Checkbox1 = GUICtrlCreateCheckbox("AltDM", 192, 297, 80, 16)
BLACKANDWHITE()

;Checkbox - Monsters On/Off
Global $Checkbox2 = GUICtrlCreateCheckbox("NoMonsters", 287, 297, 80, 16)
BLACKANDWHITE()

;Checkbox - Fast Monsters On/Off
Global $Checkbox3 = GUICtrlCreateCheckbox("FastMonsters", 380, 297, 84, 16)
BLACKANDWHITE()

;Checkbox - Monsters Respawn On/Off
Global $Checkbox4 = GUICtrlCreateCheckbox("Respawn", 473, 297, 80, 16)
BLACKANDWHITE()

;Checkbox - Save Game Load Enable
Global $Checkbox5 = GUICtrlCreateCheckbox("Load Save", 305, 7, 80, 16)
BLACKANDWHITE()

;Checkbox - Layout Flipper
Global $Checkbox6 = GUICtrlCreateCheckbox("Mirror", 243, 175, 48, 16)
BLACKANDWHITE()

;Red outline for Launch Button.
Global $LaunchBorder = GUICtrlCreateLabel("", 24, 390, 532, 54)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x1B0303)

;"Button" - Launch Game
Global $Button1 = GUICtrlCreateButton("Launch", 26, 392, 528, 50, $SS_CENTER)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x1a2278)

;Combobox - Hexen Player 1 Class
Global $Combo5 = GUICtrlCreateCombo("", 208, 347, 64, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Hexen Player 2 Class
Global $Combo6 = GUICtrlCreateCombo("", 302, 347, 64, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Hexen Player 3 Class
Global $Combo7 = GUICtrlCreateCombo("", 396, 347, 64, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Combobox - Hexen Player 4 Class
Global $Combo8 = GUICtrlCreateCombo("", 489, 347, 64, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
BLACKANDWHITE()

;Labels!
Global $Label1 = GUICtrlCreateLabel("Game", 24, 8, 36, 16)
BLACKANDWHITE()

Global $Label2 = GUICtrlCreateLabel("Level", 192, 8, 64, 16)
BLACKANDWHITE()

Global $Label3 = GUICtrlCreateLabel("Mode", 192, 64, 64, 16)
BLACKANDWHITE()

Global $Label4 = GUICtrlCreateLabel("Difficulty", 192, 120, 64, 16)
BLACKANDWHITE()

Global $Label5 = GUICtrlCreateLabel("Split", 192, 176, 32, 16)
BLACKANDWHITE()

Global $Label6 = GUICtrlCreateLabel("Command Line", 192, 232, 110, 16)
BLACKANDWHITE()

Global $Label7 = GUICtrlCreateLabel("Hexen Classes", 192, 323, 140, 16)
BLACKANDWHITE()

Global $Label8 = GUICtrlCreateLabel("P1", 192, 346, 16, 25)
BLACKANDWHITE()

Global $Label9 = GUICtrlCreateLabel("P2", 287, 346, 16, 25)
BLACKANDWHITE()

Global $Label10 = GUICtrlCreateLabel("P3", 380, 346, 16, 25)
BLACKANDWHITE()

Global $Label11 = GUICtrlCreateLabel("P4", 473, 346, 16, 25)
BLACKANDWHITE()

Global $Label12 = GUICtrlCreateLabel("Custom Game Template", 418, 8, 128, 16)
BLACKANDWHITE()

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
EndFunc

;=============================================================================================
;========================================= Initialize GUI State =============================
;=============================================================================================
Func INITIALIZEGUI()
;Disable launch "button" outline label so it doesn't conflict with launch label.
GUICtrlSetstate($LaunchBorder,$GUI_DISABLE)

_GUICtrlComboBox_SetMinVisible ($Combo1, 24)

;Load Save Game Checkbox: determine checked/unchecked state!
If $LOADSAVE = "1" Then
GUICtrlSetState($CheckBox5, $GUI_CHECKED)
GUICtrlSetstate($Combo9,$GUI_Enable)
GUICtrlSetstate($Button2,$GUI_Enable)
GUICtrlSetstate($Label2,$GUI_Disable)
GUICtrlSetstate($Combo1,$GUI_Disable)
Else
GUICtrlSetState($CheckBox5, $GUI_UNCHECKED)
GUICtrlSetstate($Combo9,$GUI_Disable)
GUICtrlSetstate($Button2,$GUI_Disable)
EndIf

;Game Type
GUICtrlSetData($Combo2, "COOP|DEATHMATCH", "")
_GUICtrlComboBox_SelectString($Combo2, $MODE)

;Difficulty mode selector.
GUICtrlSetData($Combo3, "1|2|3|4|5", "")
_GUICtrlComboBox_SelectString($Combo3, $DIFFICULTY)

;Split mode selector.
GUICtrlSetData($Combo4, "Horizontal|Vertical|TriH|TriV|Quad", "")
_GUICtrlComboBox_SelectString($Combo4, $SPLITMODE)

;Mirror Mode Flipper
If $MIRROR = "1" Then
GUICtrlSetState($CheckBox6, $GUI_CHECKED)
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32m.gif", 304, 64, 250, 181)
Else
GUICtrlSetState($CheckBox6, $GUI_UNCHECKED)
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32.gif", 304, 64, 250, 181)
EndIf


;DM Checkboxes.
If $ALTDM = "1" Then
GUICtrlSetState($CheckBox1, $GUI_CHECKED)
Else
GUICtrlSetState($CheckBox1, $GUI_UNCHECKED)
EndIf
If $NOMONSTERS = "1" Then
GUICtrlSetState($CheckBox2, $GUI_CHECKED)
Else
GUICtrlSetState($CheckBox2, $GUI_UNCHECKED)
EndIf
If $FASTMONSTERS = "1" Then
GUICtrlSetState($CheckBox3, $GUI_CHECKED)
Else
GUICtrlSetState($CheckBox3, $GUI_UNCHECKED)
EndIf
If $RESPAWN = "1" Then
GUICtrlSetState($CheckBox4, $GUI_CHECKED)
Else
GUICtrlSetState($CheckBox4, $GUI_UNCHECKED)
EndIf

;Hexen P1 Class.
GUICtrlSetData($Combo5, "fighter|cleric|mage", "")
_GUICtrlComboBox_SelectString($Combo5, $HEXCLASS1)

;Hexen P2 Class.
GUICtrlSetData($Combo6, "fighter|cleric|mage", "")
_GUICtrlComboBox_SelectString($Combo6, $HEXCLASS2)

;Hexen P3 Class.
GUICtrlSetData($Combo7, "fighter|cleric|mage", "")
_GUICtrlComboBox_SelectString($Combo7, $HEXCLASS3)

;Hexen P4 Class.
GUICtrlSetData($Combo8, "fighter|cleric|mage", "")
_GUICtrlComboBox_SelectString($Combo8, $HEXCLASS4)

;Disable Custom Game Template if not Custom...
GUICtrlSetState($Combo10, $GUI_DISABLE)

;Load last ran Custom Command Line data.
GUICtrlSetData($Edit1, $CUSTOMCL, "")

;Determine if Hexen class section should be active...
HEXENCLASSESCHECK()

;Set IWAD variable to what is hopefully a bullshit value: If "Launch" button is clicked and $IWAD hasn't been set to change
;this (Though that shouldn't be possible), just return to GUI loop...
Global $IWAD = "null.fakewad"

;=============
;Game Setup
;=============

;Doom
If Not FileExists ($WADFOLDER & "\doom.wad") Then
GUICtrlSetstate($Radio1,$GUI_Disable)
Else
If $GAME = "doom" Then
GUICtrlSetState($Radio1, $GUI_CHECKED)
DOOM()
Endif
EndIf

;Doom 2
If Not FileExists ($WADFOLDER & "\doom2.wad") Then
GUICtrlSetstate($Radio2,$GUI_Disable)
Else
If $GAME = "doom2" Then
GUICtrlSetState($Radio2, $GUI_CHECKED)
DOOM2()
Endif
EndIf

;Evilution
If Not FileExists ($WADFOLDER & "\tnt.wad") Then
GUICtrlSetstate($Radio3,$GUI_Disable)
Else
If $GAME = "tnt" Then
GUICtrlSetState($Radio3, $GUI_CHECKED)
TNT()
Endif
EndIf

;Plutonia Experiment
If Not FileExists ($WADFOLDER & "\plutonia.wad") Then
GUICtrlSetstate($Radio4,$GUI_Disable)
Else
If $GAME = "plutonia" Then
GUICtrlSetState($Radio4, $GUI_CHECKED)
PLUTONIA()
Endif
EndIf

;Heretic
If Not FileExists ($WADFOLDER & "\heretic.wad") Then
GUICtrlSetstate($Radio5,$GUI_Disable)
Else
If $GAME = "heretic" Then
GUICtrlSetState($Radio5, $GUI_CHECKED)
HERETIC()
Endif
EndIf

;Hexen
If Not FileExists ($WADFOLDER & "\hexen.wad") Then
GUICtrlSetstate($Radio6,$GUI_Disable)
Else
If $GAME = "hexen" Then
GUICtrlSetState($Radio6, $GUI_CHECKED)
HEXEN()
Endif
EndIf

;Hexen - Death Kings
If Not FileExists ($WADFOLDER & "\hexdd.wad") Then
GUICtrlSetstate($Radio7,$GUI_Disable)
Else
If $GAME = "hexdd" Then
GUICtrlSetState($Radio7, $GUI_CHECKED)
HEXDD()
Endif
EndIf

;Strife - Quest for The Sigil
If Not FileExists ($WADFOLDER & "\strife1.wad") Then
GUICtrlSetstate($Radio8,$GUI_Disable)
Else
If $GAME = "strife" Then
GUICtrlSetState($Radio8, $GUI_CHECKED)
STRIFE()
Endif
EndIf

;Hacx
If Not FileExists ($WADFOLDER & "\hacx.wad") Then
GUICtrlSetstate($Radio9,$GUI_Disable)
Else
If $GAME = "hacx" Then
GUICtrlSetState($Radio9, $GUI_CHECKED)
HACX()
Endif
EndIf

;Chex Quest 3
If Not FileExists ($WADFOLDER & "\chex.wad") Then
GUICtrlSetstate($Radio10,$GUI_Disable)
Else
If $GAME = "chex" Then
GUICtrlSetState($Radio10, $GUI_CHECKED)
CHEX()
Endif
EndIf

;Freedoom
If Not FileExists ($WADFOLDER & "\freedoom1.wad") Then
GUICtrlSetstate($Radio11,$GUI_Disable)
Else
If $GAME = "freedoom1" Then
GUICtrlSetState($Radio11, $GUI_CHECKED)
FREEDOOM1()
Endif
EndIf

;Freedoom 2
If Not FileExists ($WADFOLDER & "\freedoom2.wad") Then
GUICtrlSetstate($Radio12,$GUI_Disable)
Else
If $GAME = "freedoom2" Then
GUICtrlSetState($Radio12, $GUI_CHECKED)
FREEDOOM2()
Endif
EndIf

;Custom Game
If $GAME = "custom" Then
GUICtrlSetState($Radio15, $GUI_CHECKED)
CUSTOMGAME()
EndIf
EndFunc

;=============================================================================================
;=================================== GUI Mode Run Function ===================================
;=============================================================================================
;Set up stuff for GUI mode and call execution function!
Func GUIMODELAUNCH()

;Set flag indicating we did not run from a CLI...
Global $RANFROMCLI=0

Global $CUSTOMCL = GUICtrlRead($Edit1)
IniWrite ($SystemConfig, "LZSplitDoom", "CUSTOMCL", $CUSTOMCL)

;Get final state of system INI for runtime parameters...
READINIVALUES()

;Prepare INI files for each player.
INISETUP()

;Hide GUI.
GUISetState(@SW_HIDE, $Form1_1)

;Check if set to CoOp or Deathmatch!
If ($MODE="COOP") Then
Global $GAMETYPE = ("")
EndIf

If ($MODE = "DEATHMATCH") And ($ALTDM = "0") Then
Global $GAMETYPE = (" -deathmatch")
EndIf

If ($MODE = "DEATHMATCH") And ($ALTDM = "1") Then
Global $GAMETYPE = (" -altdeath")
EndIf

; Intialize data based on NOMONSTERS value in INI file.
If ($NOMONSTERS = "1") Then
Global $MONSTERSTATUS = (" -nomonsters")
Else
Global $MONSTERSTATUS = ("")
EndIf

; Intialize data based on FASTMONSTERS value in INI file.
If ($FASTMONSTERS = "1") Then
Global $FASTMONSTERSTATUS = (" -fast")
Else
Global $FASTMONSTERSTATUS = ("")
EndIf

; Intialize data based on RESPAWN value in INI file.
If ($RESPAWN = "1") Then
Global $RESPAWNSTATUS = (" -respawn")
Else
Global $RESPAWNSTATUS = ("")
EndIf

;Somehow $IWAD wasn't set to anything??? Do nothing when button is clicked.
If $IWAD = "null.fakewad" Then
Sleep (100)
EndIf

;Set number of players based on screen split mode.
Global $HOSTESS=(2)

If $SPLITMODE="TriH" OR $SPLITMODE="TriV" Then
Global $HOSTESS=(3)
EndIf

If $SPLITMODE="Quad" Then
Global $HOSTESS=(4)
EndIf

;Set save game load parameter based on LASTSAVE value in INI file.
If $LASTSAVE="none" Then
Global $LOADSAVEGAMEP1=("")
Global $LOADSAVEGAMEP2=("")
Global $LOADSAVEGAMEP3=("")
Global $LOADSAVEGAMEP4=("")
Else
Global $LOADSAVEGAMEP1=(" -loadgame " & '"' & $SAVEPATHP1 & $LASTSAVE & '"')
Global $LOADSAVEGAMEP2=(" -loadgame " & '"' & $SAVEPATHP2 & $LASTSAVE & '"')
Global $LOADSAVEGAMEP3=(" -loadgame " & '"' & $SAVEPATHP3 & $LASTSAVE & '"')
Global $LOADSAVEGAMEP4=(" -loadgame " & '"' & $SAVEPATHP4 & $LASTSAVE & '"')
EndIf

;Custom Radio Button Is Checked!
If ($GAME="custom" And $LASTCUSTOMGAME="none") Then

;Set P1-P4 LZDoom parameters.
Global $PLAYER1CLI=("-config " & '"' & $Player1Config & '"' & " " & $CUSTOMCL & " +fullscreen 0 -host " & $HOSTESS & " -skill " & $DIFFICULTY & $GAMETYPE & $MONSTERSTATUS & $FASTMONSTERSTATUS & $RESPAWNSTATUS & $LOADSAVEGAMEP1)
Global $PLAYER2CLI=("-config " & '"' & $Player2Config & '"' & " " & $CUSTOMCL & " +fullscreen 0 -join 127.0.0.1" & $LOADSAVEGAMEP2)
Global $PLAYER3CLI=("-config " & '"' & $Player3Config & '"' & " " & $CUSTOMCL & " +fullscreen 0 -join 127.0.0.1" & $LOADSAVEGAMEP3)
Global $PLAYER4CLI=("-config " & '"' & $Player4Config & '"' & " " & $CUSTOMCL & " +fullscreen 0 -join 127.0.0.1" & $LOADSAVEGAMEP4)

;Execute Game!
EXECUTIONETTE()
EndIf

;Hexen or HexenDD Radio Button Is Checked!
If ($GAME="hexen" OR $GAME = "hexdd") Then

;Set P1-P4 LZDoom parameters.
Global $PLAYER1CLI=("-config " & '"' & $Player1Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -host " & $HOSTESS & " -skill " & $DIFFICULTY & " +map " & $WARP & $GAMETYPE & " +playerclass " & $HEXCLASS1 & " " & $MONSTERSTATUS & $FASTMONSTERSTATUS & $RESPAWNSTATUS & $LOADSAVEGAMEP1)
Global $PLAYER2CLI=("-config " & '"' & $Player2Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS2 &  $LOADSAVEGAMEP2)
Global $PLAYER3CLI=("-config " & '"' & $Player3Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS3 & $LOADSAVEGAMEP3)
Global $PLAYER4CLI=("-config " & '"' & $Player4Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $HEXCLASS4 & $LOADSAVEGAMEP4)

;Execute Game!
EXECUTIONETTE()
EndIf

;Any other game is selected!
If ($GAME <> "hexen" And $GAME <> "hexdd") Then

;This is a failsafe in case a game is ran but the WAD doesn't exist: This can happen if the game
;selected has its WAD deleted. If so, set game to Custom and respawn interface.

If Not IsDeclared("AUTOLOADDIR") Then
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "custom")
ShellExecute(@ScriptName)
Exit
EndIf

;Set P1-P4 LZDoom parameters.
Global $PLAYER1CLI=("-config " & '"' & $Player1Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -host " & $HOSTESS & " -skill " & $DIFFICULTY & " +map " & $WARP & $GAMETYPE & " " & $MONSTERSTATUS & $FASTMONSTERSTATUS & $RESPAWNSTATUS & $LOADSAVEGAMEP1)
Global $PLAYER2CLI=("-config " & '"' & $Player2Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $LOADSAVEGAMEP2)
Global $PLAYER3CLI=("-config " & '"' & $Player3Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $LOADSAVEGAMEP3)
Global $PLAYER4CLI=("-config " & '"' & $Player4Config & '"' & " -iwad " & '"' & $IWAD & '"' & " " & $AUXFILES & " " & $CUSTOMCL & " -file " & '"' & $WADFOLDER & "\" & $AUTOLOADDIR & "\*" & '"' & " +fullscreen 0 -join 127.0.0.1" & " +playerclass " & $LOADSAVEGAMEP4)

;Execute Game!
EXECUTIONETTE()
EndIf
EndFunc

;=============================================================================================
;=================================== Game Run Function =======================================
;=============================================================================================
Func EXECUTIONETTE()

;If ran from a CLI, skip the following...
If $RANFROMCLI = 1 Then

;We did run from a CLI. Continue!
Else

;If $IWAD is undefined, abort!
If $GAME = "custom" And Not FileExists ($WADFOLDER & "\" & $IWAD) And $LASTCUSTOMGAME <> "none" Then
MsgBox (0, "LZSplitDoom - Error", "IWAD does not exist!", 10)
ShellExecute(@ScriptName)
Exit
EndIf

EndIf

;For Debugging...
;MsgBox(0, "Pass This To LZSplitDoom!", $PLAYER1CLI)
;MsgBox(0, "Pass This To LZSplitDoom!", $WADFOLDERVALUE & $CFGFOLDERVALUE & $GAMEFOLDERVALUE & $BINFOLDER & $SAVEPATHP1)

;Determine what kind of HighDPI mode to use based on OS version.
Global $OSBUILD = (@OSBuild)

;Windows 10 1709 and up.
If $OSBuild >= 16299 Then
Global $DPIMODE = (DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext" , "HWND", "DPI_AWARENESS_CONTEXT" -4))
EndIf

;Windows 8.1/Server 2012 R2/Windows 10 Pre-1709/Server 2016
If $OSBUILD >= 9600 And $OSBuild < 16299 Then
Global $DPIMODE = (DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext" , "HWND", "DPI_AWARENESS_CONTEXT" -3))
EndIf

;Windows Vista/Server 2008/Windows 7/Server 2008 R2/Windows 8/Server 2012
If $OSBUILD >= 6000 And $OSBUILD <= 9200 Then
Global $DPIMODE = (DllCall("User32.dll","bool","SetProcessDPIAware"))
EndIf

;Get Screen Dimensions for window positioning/resizing.
Global $FullWidth = (_WinAPI_GetSystemMetrics(0))
Global $FullHeight = (_WinAPI_GetSystemMetrics(1))
Global $HalfWidth = ($FullWidth / 2)
Global $HalfHeight = ($FullHeight / 2)
Global $VertOffsetWidth = ($FullWidth / 2)
Global $VertOffsetHeight = ($FullHeight / 2)
Global $HorOffsetWidth = ($FullWidth / 2)
Global $HorOffsetHeight = ($FullHeight / 2)

;Disable DPI scaling for LZDoom itself.
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", $BINFOLDER & "\lzdoom32.exe", "REG_SZ", "HIDPIAWARE")

;Failsafe...
If ProcessExists("lzdoom32.exe") Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "killprocess lzdoom32.exe")
EndIf

;Launch 2, 3 or 4 instances of LZDoom.

If ($SPLITMODE="Quad") Then

;4P Trying to load 2P or 3P Save...
If $LOADSAVE = 1 And Not FileExists ($SAVEPATHP4 & $LASTSAVE) And FileExists ($SAVEPATHP3 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Tri Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

;4P Trying to load 2P or 3P Save...
If $LOADSAVE = 1 And Not FileExists ($SAVEPATHP4 & $LASTSAVE) And Not FileExists ($SAVEPATHP3 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Vertical/Horizonal Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

;Player_1
Global $CLIENT1 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER1CLI)
Global $hWnd = WinWait("LZDoom ", "Waiting")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 1")

;Player_2
Global $CLIENT2 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER2CLI)
Global $hWnd = WinWait("LZDoom ", "Contacting")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 2")

;Player_3
Global $CLIENT3 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER3CLI)
Global $hWnd = WinWait("LZDoom ", "Contacting")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 3")

;Player_4
Global $CLIENT4 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER4CLI)
Global $hWnd = WinWait("LZDoom ", "Contacting")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 4")

;Wait until loading windows are done before manipulating game windows!
WinWaitClose( "LZSplitDoom - Player 1" )
WinWaitClose( "LZSplitDoom - Player 2" )
WinWaitClose( "LZSplitDoom - Player 3" )
WinWaitClose( "LZSplitDoom - Player 4" )
EndIf


If ($SPLITMODE="TriH" OR $SPLITMODE="TriV") Then

;3P Trying to load 2P or 4P Save...
If $LOADSAVE = 1 And Not FileExists ($SAVEPATHP3 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Vertical/Horizonal Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

If $LOADSAVE = 1 And FileExists ($SAVEPATHP4 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Quad Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

;Player_1
Global $CLIENT1 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER1CLI)
Global $hWnd = WinWait("LZDoom ", "Abort")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 1")

;Player_2
Global $CLIENT2 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER2CLI)
Global $hWnd = WinWait("LZDoom ", "Abort")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 2")

;Player_3
Global $CLIENT3 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER3CLI)
Global $hWnd = WinWait("LZDoom ", "Abort")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 3")

;Wait until loading windows are done before manipulating game windows!
WinWaitClose( "LZSplitDoom - Player 1" )
WinWaitClose( "LZSplitDoom - Player 2" )
WinWaitClose( "LZSplitDoom - Player 3" )
EndIf

;Only 2 players defined.
If $SPLITMODE="VERTICAL" Or $SPLITMODE="HORIZONTAL" Then

;Save/Split Player Count Mistmatch Checks...
If $LOADSAVE = 1 And FileExists ($SAVEPATHP4 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Quad Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

If $LOADSAVE = 1 And FileExists ($SAVEPATHP3 & $LASTSAVE) Then
MsgBox (0, "LZSplitDoom - Error", "Save Requires Tri Split", 10)
ShellExecute(@ScriptName)
Exit
EndIf

;Player_1
Global $CLIENT1 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER1CLI)
Global $hWnd = WinWait("LZDoom ", "Abort")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 1")

;Player_2
Global $CLIENT2 = Run('"' & $BINFOLDER & "\lzdoom32.exe" & '" ' & $PLAYER2CLI)
Global $hWnd = WinWait("LZDoom ", "Abort")
WinSetTitle($hWnd, "", "LZSplitDoom - Player 2")

;Wait until loading windows are done before manipulating game windows!
WinWaitClose( "LZSplitDoom - Player 1" )
WinWaitClose( "LZSplitDoom - Player 2" )
EndIf

;Hide Taskbar...
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win hide class Shell_TrayWnd")

;Strip window borders of LZDoom instances.
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win -style process lzdoom32.exe 0x00C40000")

;Set vertical or horizontal split screen for 2 players or quad split for 4 players.
If ($SPLITMODE="Quad" And $MIRROR=0) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " " & $VertOffsetWidth & " 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " 0 " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT4 & " " & $HorOffsetWidth & " " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="Quad" And $MIRROR=1) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " " & $VertOffsetWidth & " 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " " & $HorOffsetWidth & " " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT4 & " 0 " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="TriH" And $MIRROR=0) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 0 " & $FullWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 " & $HorOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " " & $HorOffsetWidth & " " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="TriH" And $MIRROR=1) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 " & $VertOffsetHeight & " " & $FullWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 0 " & " " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " " & $HorOffsetWidth & " 0 " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="TriV" And $MIRROR=0) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 0 " & $HalfWidth & " " & $FullHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " " & $VertOffsetWidth & " 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " " & $HorOffsetWidth & " " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="TriV" And $MIRROR=1) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " " & $HorOffsetWidth & " 0 " & $HalfWidth & " " & $FullHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 0 " & $HalfWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT3 & " 0 " & $VertOffsetHeight & " " & $HalfWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="VERTICAL" And $MIRROR=0) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 0 " & $HalfWidth & " " & $FullHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " " & $VertOffsetWidth & " 0 " & $HalfWidth & " " & $FullHeight)
EndIf

If ($SPLITMODE="VERTICAL" And $MIRROR=1) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " " & $VertOffsetWidth & " 0 " & $HalfWidth & " " & $FullHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 0 " & $HalfWidth & " " & $FullHeight)
EndIf

If ($SPLITMODE="HORIZONTAL" And $MIRROR=0) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 0 " & $FullWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 " & $HorOffsetHeight & " " & $FullWidth & " " & $HalfHeight)
EndIf

If ($SPLITMODE="HORIZONTAL" And $MIRROR=1) Then
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT1 & " 0 " & $HorOffsetHeight & " " & $FullWidth & " " & $HalfHeight)
ShellExecuteWait( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win setsize process /" & $CLIENT2 & " 0 0 " & $FullWidth & " " & $HalfHeight)

EndIf

;Move mouse cursor out of the way.
MouseMove(7096, 7096, 0)

;Wait for host instance to close.
ShellExecute( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win activate process /" & $CLIENT1)
ProcessWaitClose($CLIENT1)

;Kill client instance(s).
ProcessClose($CLIENT2)

If ($SPLITMODE="TriH" OR $SPLITMODE="TriV") Then
ProcessClose($CLIENT3)
EndIf

If ($SPLITMODE="Quad") Then
ProcessClose($CLIENT3)
ProcessClose($CLIENT4)
EndIf

;Restore Taskbar
ShellExecute( '"' & $BINFOLDER & "\nircmd32.exe" & '"', "win show class Shell_TrayWnd")

;Determine if we ran from the CLI or GUI: Exit if the former, restart interface if the latter...
If $RANFROMCLI=1 Then
Exit
Else
ShellExecute(@ScriptName)
Exit
EndIf
EndFunc

;=============================================================================================
;=========================================== GAMES ===========================================
;=============================================================================================
Func DOOM()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "doom")
_GUICtrlComboBox_ResetContent($Combo1)
;Sigil detection: Adjust Map List accordingly.
If Not FileExists ($WADFOLDER & "\sigil.wad") And Not FileExists ($WADFOLDER & "\doom\sigil.wad") And Not FileExists ($WADFOLDER & "\sigil2.wad") And Not FileExists ($WADFOLDER & "\doom\sigil2.wad") Then
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9", "")
Global $IWAD = "doom.wad"
Global $AUXFILES = ""
Else
If FileExists ($WADFOLDER & "\sigil.wad") Or FileExists ($WADFOLDER & "\doom\sigil.wad") And Not FileExists ($WADFOLDER & "\sigil2.wad") And Not FileExists ($WADFOLDER & "\doom\sigil2.wad") Then
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9|e5m1|e5m2|e5m3|e5m4|e5m5|e5m6|e5m7|e5m8|e5m9", "")
Global $IWAD = "doom.wad"
Global $AUXFILES = " -file sigil.wad"
Else
If FileExists ($WADFOLDER & "\sigil2.wad") Or FileExists ($WADFOLDER & "\doom\sigil2.wad") And Not FileExists ($WADFOLDER & "\sigil.wad") And Not FileExists ($WADFOLDER & "\doom\sigil.wad") Then
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9|e6m1|e6m2|e6m3|e6m4|e6m5|e6m6|e6m7|e6m8|e6m9", "")
Global $IWAD = "doom.wad"
Global $AUXFILES = " -file sigil2.wad"
Else
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9|e5m1|e5m2|e5m3|e5m4|e5m5|e5m6|e5m7|e5m8|e5m9|e6m1|e6m2|e6m3|e6m4|e6m5|e6m6|e6m7|e6m8|e6m9", "")
Global $IWAD = "doom.wad"
Global $AUXFILES = " -file sigil.wad -file sigil2.wad"
EndIf
EndIf
EndIf
Global $AUTOLOADDIR = "doom"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func DOOM2()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "doom2")
_GUICtrlComboBox_ResetContent($Combo1)
;NRFTL detection: Adjust Map List accordingly.
If Not FileExists ($WADFOLDER & "\nerve.wad") And Not FileExists ($WADFOLDER & "\doom2\nerve.wad") Then
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31|map32", "")
Global $IWAD = "doom2.wad"
Global $AUXFILES = ""
Else
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31|map32|LEVEL01|LEVEL02|LEVEL03|LEVEL04|LEVEL05|LEVEL06|LEVEL07|LEVEL08|LEVEL09", "")
Global $IWAD = "doom2.wad"
Global $AUXFILES = " -file nerve.wad"
EndIf
Global $AUTOLOADDIR = "doom2"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func TNT()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "tnt")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31|map32", "")
Global $IWAD = "tnt.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "tnt"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func PLUTONIA()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "plutonia")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31|map32", "")
Global $IWAD = "plutonia.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "plutonia"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func HERETIC()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "heretic")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9|e5m1|e5m2|e5m3|e5m4|e5m5|e5m6|e5m7|e5m8|e5m9", "")
Global $IWAD = "heretic.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "heretic"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func HEXEN()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "hexen")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31", "")
Global $IWAD = "hexen.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "hexen"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func HEXDD()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "hexdd")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map41|map42|map43|map44|map45|map46|map47|map48|map49|map50|map51|map52|map53|map54|map55|map56|map57|map58|map59|map60|map33|map34|map35|map36|map37|map38", "")
Global $IWAD = "hexdd.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "hexdd"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func STRIFE()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "strife")
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31", "")
Global $IWAD = "strife1.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "strife"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func HACX()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "hacx")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20", "")
Global $IWAD = "hacx.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "hacx"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func CHEX()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "chex")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e2m1|e2m2|e2m3|e2m4|e2m5|e3m1|e3m2|e3m3|e3m4|e3m5", "")
Global $IWAD = "chex.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "chex"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func FREEDOOM1()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "freedoom1")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "e1m1|e1m2|e1m3|e1m4|e1m5|e1m6|e1m7|e1m8|e1m9|e2m1|e2m2|e2m3|e2m4|e2m5|e2m6|e2m7|e2m8|e2m9|e3m1|e3m2|e3m3|e3m4|e3m5|e3m6|e3m7|e3m8|e3m9|e4m1|e4m2|e4m3|e4m4|e4m5|e4m6|e4m7|e4m8|e4m9", "")
Global $IWAD = "freedoom1.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "freedoom1"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func FREEDOOM2()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "freedoom2")
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, "map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13|map14|map15|map16|map17|map18|map19|map20|map21|map22|map23|map24|map25|map26|map27|map28|map29|map30|map31|map32", "")
Global $IWAD = "freedoom2.wad"
Global $AUXFILES = ""
Global $AUTOLOADDIR = "freedoom2"
SETMAPSELECT()
WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()
GUICtrlSetstate($Label12,$GUI_Disable)
GUICtrlSetstate($Combo10,$GUI_Disable)
EndFunc
;=============================================================================================
Func CUSTOMGAME()
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "custom")
GUICtrlSetstate($Label12,$GUI_Enable)
GUICtrlSetstate($Combo10,$GUI_Enable)
Global $LASTCUSTOMGAME = IniRead($SystemConfig, "LZSplitDoom", "LASTCUSTOMGAME", "")

;Enable Level Select control, populate with values from Game INI.
GUICtrlSetstate($Combo1,$GUI_Enable)
_GUICtrlComboBox_ResetContent($Combo1)
_GUICtrlComboBox_ResetContent($Combo10)
Global $CustomGameFiles=_FileListToArray($GAMEFOLDER & "\","*.ini", 1)
Global $CustomGameList=(_ArrayToString($CustomGameFiles, "|",1))
GuiCtrlSetData($Combo10, "none|" & $CustomGameList)
_GUICtrlComboBox_SelectString($Combo10, $LASTCUSTOMGAME)

;Custom game defined, but not Custom Game Template. Set dummy values for a couple of variables.
If ($GAME="custom" And $LASTCUSTOMGAME="none") Then
Global $IWAD = ("")
Global $AUXFILES = ("")
Global $AUTOLOADDIR = ("DOESNOTEXIST")
Else

;Custom game defined with Custom Game Template.
Global $CustomGameSelected = GUICtrlRead($Combo10)
Global $GAMENAME = IniRead($GAMEFOLDER & "\" & $LASTCUSTOMGAME, "LZSplitDoomCustomGame", "GAMENAME", "")
Global $IWAD = IniRead($GAMEFOLDER & "\" & $LASTCUSTOMGAME, "LZSplitDoomCustomGame", "IWAD", "")
Global $AUXFILES = ("")
Global $MAPLIST = IniRead($GAMEFOLDER & "\" & $LASTCUSTOMGAME, "LZSplitDoomCustomGame", "MAPLIST", "")
Global $CUSTOMCL = IniRead($GAMEFOLDER & "\" & $LASTCUSTOMGAME, "LZSplitDoomCustomGame", "CUSTOMCL", "")

;CUSTOMCL value in Game Template is null. Leave Command Line editbox alone!
If $CUSTOMCL <> "" Then
IniWrite ($SystemConfig, "LZSplitDoom", "CUSTOMCL", $CUSTOMCL)
GUICtrlSetData($Edit1, $CUSTOMCL, "")
EndIf

;Set Autoload directory to
Global $AUTOLOADDIR = ($GAMENAME)

;Set Custom Game Template maplist data to Level combobox.
_GUICtrlComboBox_ResetContent($Combo1)
GUICtrlSetData($Combo1, $MAPLIST, "")

EndIf

SETMAPSELECT()
Global $WARP = GUICtrlRead($Combo1)
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", $WARP)

WARPANDMODE()
HEXENCLASSESCHECK()
SAVEDATAHANDLER()

EndFunc
;=============================================================================================
Func DELETESAVE()

If MsgBox(68, "Warning!", "Really Delete?") = 6 Then
Global $SAVETOKILL = GUICtrlRead($Combo9)

FileDelete ($CFGFOLDER  & "\player1\SAV\" & $GAME & '\' & $SAVETOKILL)
FileDelete ($CFGFOLDER  & "\player2\SAV\" & $GAME & '\' & $SAVETOKILL)
FileDelete ($CFGFOLDER  & "\player3\SAV\" & $GAME & '\' & $SAVETOKILL)
FileDelete ($CFGFOLDER  & "\player4\SAV\" & $GAME & '\' & $SAVETOKILL)

SAVEERRATA()

EndIf

EndFunc
;=============================================================================================
Func SAVEERRATA()

Global $LOADSAVE = IniRead($SystemConfig, "LZSplitDoom", "LOADSAVE", "")

;Determine what to do with Load Save settings...
Global $SaveFiles=_FileListToArray($SAVEPATHP1,"*.zds", 1)

;Saves exist for current game!
If @Error=0 Then
Global $SAVEFILELIST=(_ArrayToString($SaveFiles, "|",1))
GUICtrlSetState($CheckBox5, $GUI_Enable)
Else
;No saves exist for game. :(
Global $SAVEFILELIST="none"
GUICtrlSetState($CheckBox5, $GUI_Disable)
EndIf

;Select Save combobox option and write to INI...
_GUICtrlComboBox_ResetContent($Combo9)
GuiCtrlSetData($Combo9, $SAVEFILELIST)
_GUICtrlComboBox_SetCurSel($Combo9, 0)
_GUICtrlComboBox_SelectString($Combo9, $LASTSAVE)
If $LOADSAVE = "1" Then
Global $SAVESET = GUICtrlRead($Combo9)
Else
Global $SAVESET = "none"
EndIf
IniWrite($SystemConfig, "LZSplitDoom", "LASTSAVE", $SAVESET)

If $SAVESET = "none" Then
GUICtrlSetState($CheckBox5, $GUI_UNCHECKED)
GUICtrlSetstate($Combo9,$GUI_Disable)
GUICtrlSetstate($Button2,$GUI_Disable)
GUICtrlSetstate($Label2,$GUI_Enable)
GUICtrlSetstate($Combo1,$GUI_Enable)
IniWrite($SystemConfig, "LZSplitDoom", "LOADSAVE", 0)
Global $WARPSET = GUICtrlRead($Combo1)
IniWrite($SystemConfig, "LZSplitDoom", "WARP", $WARPSET)
EndIf

EndFunc

;=============================================================================================
;========================================= GUI Run Loop ======================================
;=============================================================================================
;Main GUI Loop!
Func GUIMAINLOOP()
While 1
$nMsg = GUIGetMsg()
Switch $nMsg
Case $GUI_EVENT_CLOSE
Exit
Case $Form1_1

;===============
;Control Actions
;===============

;Doom Radio Button
Case $Radio1
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "e1m1")
DOOM()

;Doom 2 Radio Button
Case $Radio2
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
DOOM2()

;Evilution Radio Button
Case $Radio3
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
TNT()

;Plutonia Radio Button
Case $Radio4
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
PLUTONIA()

;Heretic Radio Button
Case $Radio5
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "e1m1")
HERETIC()

;Hexen Radio Button
Case $Radio6
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
HEXEN()

;Hexen - Death Kings Radio Button
Case $Radio7
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map41")
HEXDD()

;Strife
Case $Radio8
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map02")
STRIFE()

;Hacx Radio Button
Case $Radio9
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
HACX()

;Chex Quest 3 Radio Button
Case $Radio10
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "e1m1")
CHEX()

;Freedoom Radio Button
Case $Radio11
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "e1m1")
FREEDOOM1()

;Freedoom 2 Radio Button
Case $Radio12
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", "map01")
FREEDOOM2()

;Custom Game Radio Button
Case $Radio15
IniWrite ($SystemConfig, "LZSplitDoom", "GAME", "custom")
CUSTOMGAME()

;Level Select Combobox
Case $Combo1
Global $WARP = GUICtrlRead($Combo1)
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", $WARP)

;Game Mode Combobox
Case $Combo2
Global $MODE = GUICtrlRead($Combo2)
IniWrite ($SystemConfig, "LZSplitDoom", "MODE", $MODE)
Global $MODESTATUS = IniRead($SystemConfig, "LZSplitDoom", "MODE", "")
If $MODE = "COOP" Then
GUICtrlSetstate($CheckBox1,$GUI_DISABLE)
Else
GUICtrlSetstate($CheckBox1,$GUI_ENABLE)
EndIf

;Difficulty Level Combobox
Case $Combo3
Global $DIFFICULTY = GUICtrlRead($Combo3)
IniWrite ($SystemConfig, "LZSplitDoom", "DIFFICULTY", $DIFFICULTY)

;Screen Split Mode Combobox
Case $Combo4
Global $SPLITMODE = GUICtrlRead($Combo4)
IniWrite ($SystemConfig, "LZSplitDoom", "SPLITMODE", $SPLITMODE)
;Change GUI image to reflect screen layout...
Global $MODE = IniRead($SystemConfig, "LZSplitDoom", "SPLITMODE", "")
Global $GAME = IniRead($SystemConfig, "LZSplitDoom", "GAME", "")
Global $MIRROR = IniRead($SystemConfig, "LZSplitDoom", "MIRROR", "")

If $MIRROR = "1" Then
GUICtrlSetImage ($Graphic1, $BINFOLDER & "\" & $MODE & "32m.gif")
Else
GUICtrlSetImage ($Graphic1, $BINFOLDER & "\" & $MODE & "32.gif")
EndIf

;Determine if Hexen Player Class boxes need to be active...
HEXENCLASSESCHECK()

;Set values for Hexen Class comboboxes...
Case $Combo5
Global $HEXCLASS1 = GUICtrlRead($Combo5)
IniWrite ($SystemConfig, "LZSplitDoom", "HEXCLASS1", $HEXCLASS1)
Case $Combo6
Global $HEXCLASS2 = GUICtrlRead($Combo6)
IniWrite ($SystemConfig, "LZSplitDoom", "HEXCLASS2", $HEXCLASS2)
Case $Combo7
Global $HEXCLASS3 = GUICtrlRead($Combo7)
IniWrite ($SystemConfig, "LZSplitDoom", "HEXCLASS3", $HEXCLASS3)
Case $Combo8
Global $HEXCLASS4 = GUICtrlRead($Combo8)
IniWrite ($SystemConfig, "LZSplitDoom", "HEXCLASS4", $HEXCLASS4)

Case $Combo9
Global $LastSave = GUICtrlRead($Combo9)
IniWrite ($SystemConfig, "LZSplitDoom", "LASTSAVE", $LastSave)

Case $Combo10
Global $LastCustomGame = GUICtrlRead($Combo10)
IniWrite ($SystemConfig, "LZSplitDoom", "LASTCUSTOMGAME", $LastCustomGame)
GUICtrlSetstate($Combo10,$GUI_ENABLE)
CUSTOMGAME()

;Custom Command Line Editbox.
Case $Edit1
Global $CUSTOMCL = GUICtrlRead($Edit1)
IniWrite ($SystemConfig, "LZSplitDoom", "CUSTOMCL", $CUSTOMCL)

;Deathmatch Mode checkbox.
Case $CheckBox1
If GUICtrlRead ($CheckBox1) = 1 Then
IniWrite ($SystemConfig, "LZSplitDoom", "ALTDM", "1")
Else
IniWrite ($SystemConfig, "LZSplitDoom", "ALTDM", "0")
EndIf

;No Monsters checkbox.
Case $CheckBox2
If GUICtrlRead ($CheckBox2) = 1 Then
IniWrite ($SystemConfig, "LZSplitDoom", "NOMONSTERS", "1")
Else
IniWrite ($SystemConfig, "LZSplitDoom", "NOMONSTERS", "0")
EndIf

;Fast Monsters checkbox.
Case $CheckBox3
If GUICtrlRead ($CheckBox3) = 1 Then
IniWrite ($SystemConfig, "LZSplitDoom", "FASTMONSTERS", "1")
Else
IniWrite ($SystemConfig, "LZSplitDoom", "FASTMONSTERS", "0")
EndIf

;Respawning Monsters checkbox.
Case $CheckBox4
If GUICtrlRead ($CheckBox4) = 1 Then
IniWrite ($SystemConfig, "LZSplitDoom", "RESPAWN", "1")
Else
IniWrite ($SystemConfig, "LZSplitDoom", "RESPAWN", "0")
EndIf

;Save Game Checkbox
Case $CheckBox5
If GUICtrlRead ($CheckBox5) = 1 Then
Global $SAVESET = GUICtrlRead($Combo9)
IniWrite($SystemConfig, "LZSplitDoom", "LASTSAVE", $SAVESET)
IniWrite ($SystemConfig, "LZSplitDoom", "LOADSAVE", "1")
IniWrite ($SystemConfig, "LZSplitDoom", "LASTSAVE", $SAVESET)
IniWrite($SystemConfig, "LZSplitDoom", "WARP", "")
GUICtrlSetstate($Combo9,$GUI_Enable)
GUICtrlSetstate($Button2,$GUI_Enable)
GUICtrlSetstate($Combo1,$GUI_DISABLE)
GUICtrlSetstate($Label2,$GUI_Disable)
Else
Global $WARPSET = GUICtrlRead($Combo1)
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", $WARPSET)
IniWrite ($SystemConfig, "LZSplitDoom", "LOADSAVE", "0")
IniWrite ($SystemConfig, "LZSplitDoom", "LASTSAVE", "none")
GUICtrlSetstate($Combo9,$GUI_Disable)
GUICtrlSetstate($Button2,$GUI_Disable)
GUICtrlSetstate($Combo1,$GUI_Enable)
GUICtrlSetstate($Label2,$GUI_Enable)
EndIf
If $SAVESET = "none" Then
GUICtrlSetState($CheckBox5, $GUI_UNCHECKED)
GUICtrlSetstate($Combo9,$GUI_Disable)
GUICtrlSetstate($Label2,$GUI_Enable)
GUICtrlSetstate($Combo1,$GUI_Enable)
IniWrite ($SystemConfig, "LZSplitDoom", "LOADSAVE", "0")
Global $WARPSET = GUICtrlRead($Combo1)
IniWrite ($SystemConfig, "LZSplitDoom", "WARP", $WARPSET)
EndIf

;Delete Save Button
Case $Button2
DELETESAVE()


;Screen Flip Checkbox
Case $CheckBox6
If GUICtrlRead ($CheckBox6) = 1 Then
IniWrite ($SystemConfig, "LZSplitDoom", "MIRROR", "1")
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32m.gif", 304, 64, 250, 181)
Else
IniWrite ($SystemConfig, "LZSplitDoom", "MIRROR", "0")
Global $Graphic1 = GUICtrlCreatePic ($BINFOLDER & "\" & $SPLITMODE & "32.gif", 304, 64, 250, 181)
EndIf


;The Launch button.
Case $Button1
GUIMODELAUNCH()
EndSwitch
WEnd
EndFunc

;=============================================================================================
;================================Recreate Player INI Function ================================
;=============================================================================================
;player1.ini is missing! Recreate skeletal config with settings we want!
Func RECREATEDEFAULTS()

$sFileName = ($Player1Config)
$hFilehandle = FileOpen($sFileName, $FO_OVERWRITE)
FileWrite($hFilehandle, '[IWADSearch.Directories]' & @CRLF & _
'[IWADSearch.Directories]' & @CRLF & _
'Path=<REPLACEME>' & @CRLF & _
'Path=.' & @CRLF & _
'Path=$DOOMWADDIR' & @CRLF & _
'Path=$HOME' & @CRLF & _
'Path=$PROGDIR' & @CRLF & _
'[FileSearch.Directories]' & @CRLF & _
'Path=<REPLACEME>' & @CRLF & _
'Path=$PROGDIR' & @CRLF & _
'Path=$DOOMWADDIR' & @CRLF & _
'[SoundfontSearch.Directories]' & @CRLF & _
'Path=$PROGDIR/soundfonts' & @CRLF & _
'Path=$PROGDIR/fm_banks' & @CRLF & _
'[Doom.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Heretic.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Hexen.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Strife.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Chex.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Global.Autoload]' & @CRLF & _
'[doom.Autoload]' & @CRLF & _
'[doom.id.Autoload]' & @CRLF & _
'[doom.id.doom2.Autoload]' & @CRLF & _
'[doom.id.doom2.nerve.Autoload]' & @CRLF & _
'[doom.id.doom2.commercial.Autoload]' & @CRLF & _
'[doom.id.doom2.commercial.french.Autoload]' & @CRLF & _
'[doom.id.doom2.commercial.xbox.Autoload]' & @CRLF & _
'[doom.id.doom2.unity.Autoload]' & @CRLF & _
'[doom.id.doom2.bfg.Autoload]' & @CRLF & _
'[doom.id.doom1.Autoload]' & @CRLF & _
'[doom.id.doom1.sigil2.Autoload]' & @CRLF & _
'[doom.id.doom1.sigil.Autoload]' & @CRLF & _
'[doom.id.doom2.plutonia.Autoload]' & @CRLF & _
'[doom.id.doom2.plutonia.unity.Autoload]' & @CRLF & _
'[doom.id.doom2.tnt.Autoload]' & @CRLF & _
'[doom.id.doom2.tnt.unity.Autoload]' & @CRLF & _
'[doom.id.doom1.registered.Autoload]' & @CRLF & _
'[doom.id.doom1.ultimate.Autoload]' & @CRLF & _
'[doom.id.doom1.ultimate.xbox.Autoload]' & @CRLF & _
'[doom.id.wadsmoosh.Autoload]' & @CRLF & _
'[doom.id.doom1.unity.Autoload]' & @CRLF & _
'[doom.id.doom1.bfg.Autoload]' & @CRLF & _
'[doom.freedoom.Autoload]' & @CRLF & _
'[doom.freedoom.demo.Autoload]' & @CRLF & _
'[doom.freedoom.phase1.Autoload]' & @CRLF & _
'[doom.freedoom.phase2.Autoload]' & @CRLF & _
'[doom.freedoom.freedm.Autoload]' & @CRLF & _
'[heretic.Autoload]' & @CRLF & _
'[heretic.heretic.Autoload]' & @CRLF & _
'[heretic.shadow.Autoload]' & @CRLF & _
'[blasphemer.Autoload]' & @CRLF & _
'[hexen.Autoload]' & @CRLF & _
'[hexen.deathkings.Autoload]' & @CRLF & _
'[hexen.hexen.Autoload]' & @CRLF & _
'[strife.Autoload]' & @CRLF & _
'[strife.strife.Autoload]' & @CRLF & _
'[strife.veteran.Autoload]' & @CRLF & _
'[chex.Autoload]' & @CRLF & _
'[chex.chex1.Autoload]' & @CRLF & _
'[chex.chex3.Autoload]' & @CRLF & _
'[urbanbrawl.Autoload]' & @CRLF & _
'[hacx.Autoload]' & @CRLF & _
'[hacx.hacx1.Autoload]' & @CRLF & _
'[hacx.hacx2.Autoload]' & @CRLF & _
'[harmony.Autoload]' & @CRLF & _
'[square.Autoload]' & @CRLF & _
'[square.squareware.Autoload]' & @CRLF & _
'[square.square.Autoload]' & @CRLF & _
'[delaweare.Autoload]' & @CRLF & _
'[woolball.Autoload]' & @CRLF & _
'[woolball.rotwb.Autoload]' & @CRLF & _
'[LastRun]' & @CRLF & _
'Version=223' & @CRLF & _
'[GlobalSettings]' & @CRLF & _
'I_FriendlyWindowTitle=0' & @CRLF & _
'adl_chips_count=6' & @CRLF & _
'adl_emulator_id=0' & @CRLF & _
'adl_fullpan=true' & @CRLF & _
'adl_run_at_pcm_rate=false' & @CRLF & _
'adl_volume_model=0' & @CRLF & _
'autoloadbrightmaps=false' & @CRLF & _
'autoloadconpics=true' & @CRLF & _
'autoloadlights=false' & @CRLF & _
'autoloadwidescreen=true' & @CRLF & _
'autosavecount=0' & @CRLF & _
'autosavenum=0' & @CRLF & _
'chase_dist=90' & @CRLF & _
'chase_height=-8' & @CRLF & _
'chat_self=false' & @CRLF & _
'cl_capfps=false' & @CRLF & _
'cl_defaultconfiguration=0' & @CRLF & _
'cl_noprediction=false' & @CRLF & _
'cl_oldfreelooklimit=false' & @CRLF & _
'cl_predict_lerpscale=0.05000000074505806' & @CRLF & _
'cl_predict_lerpthreshold=2' & @CRLF & _
'cl_predict_specials=true' & @CRLF & _
'cl_run=true' & @CRLF & _
'cl_scaleweaponfov=1' & @CRLF & _
'cl_waitforsave=true' & @CRLF & _
'con_buffersize=-1' & @CRLF & _
'con_ctrl_d=' & @CRLF & _
'con_notifylines=4' & @CRLF & _
'defaultiwad=' & @CRLF & _
'demo_compress=true' & @CRLF & _
'developer=0' & @CRLF & _
'disableautoload=true' & @CRLF & _
'disableautosave=1' & @CRLF & _
'disablecrashlog=true' & @CRLF & _
'enablescriptscreenshot=false' & @CRLF & _
'fluid_chorus=false' & @CRLF & _
'fluid_chorus_depth=8' & @CRLF & _
'fluid_chorus_level=1' & @CRLF & _
'fluid_chorus_speed=0.30000001192092896' & @CRLF & _
'fluid_chorus_type=0' & @CRLF & _
'fluid_chorus_voices=3' & @CRLF & _
'fluid_gain=0.5' & @CRLF & _
'fluid_interp=1' & @CRLF & _
'fluid_lib=' & @CRLF & _
'fluid_patchset=lzdoom' & @CRLF & _
'fluid_reverb=false' & @CRLF & _
'fluid_reverb_damping=0.23000000417232513' & @CRLF & _
'fluid_reverb_level=0.5699999928474426' & @CRLF & _
'fluid_reverb_roomsize=0.6100000143051147' & @CRLF & _
'fluid_reverb_width=0.7599999904632568' & @CRLF & _
'fluid_samplerate=0' & @CRLF & _
'fluid_threads=1' & @CRLF & _
'fluid_voices=128' & @CRLF & _
'freelook=true' & @CRLF & _
'gl_billboard_faces_camera=false' & @CRLF & _
'gl_billboard_mode=0' & @CRLF & _
'gl_billboard_particles=true' & @CRLF & _
'gl_cachenodes=true' & @CRLF & _
'gl_cachetime=0.6000000238418579' & @CRLF & _
'gl_control_tear=true' & @CRLF & _
'gl_debug=false' & @CRLF & _
'gl_debug_breakpoint=false' & @CRLF & _
'gl_debug_level=0' & @CRLF & _
'gl_distfog=70' & @CRLF & _
'gl_dither_bpc=0' & @CRLF & _
'gl_enhanced_nv_stealth=3' & @CRLF & _
'gl_finishbeforeswap=false' & @CRLF & _
'gl_fxaa=0' & @CRLF & _
'gl_lens=false' & @CRLF & _
'gl_lens_chromatic=1.1200000047683716' & @CRLF & _
'gl_lens_k=-0.11999999731779099' & @CRLF & _
'gl_lens_kcube=0.10000000149011612' & @CRLF & _
'gl_light_particles=true' & @CRLF & _
'gl_light_shadowmap=false' & @CRLF & _
'gl_light_sprites=true' & @CRLF & _
'gl_lights=true' & @CRLF & _
'gl_mask_sprite_threshold=0.5' & @CRLF & _
'gl_mask_threshold=0.5' & @CRLF & _
'gl_mirror_envmap=true' & @CRLF & _
'gl_multisample=1' & @CRLF & _
'gl_multithread=true' & @CRLF & _
'gl_no_skyclear=false' & @CRLF & _
'gl_particles_style=2' & @CRLF & _
'gl_pipeline_depth=0' & @CRLF & _
'gl_plane_reflection=true' & @CRLF & _
'gl_satformula=1' & @CRLF & _
'gl_seamless=false' & @CRLF & _
'gl_shadowmap_filter=1' & @CRLF & _
'gl_shadowmap_quality=512' & @CRLF & _
'gl_sort_textures=false' & @CRLF & _
'gl_sprite_blend=false' & @CRLF & _
'gl_ssao=0' & @CRLF & _
'gl_ssao_portals=1' & @CRLF & _
'gl_ssao_strength=0.699999988079071' & @CRLF & _
'gl_texture_filter=0' & @CRLF & _
'gl_texture_filter_anisotropic=8' & @CRLF & _
'gl_texture_hqresize_maxinputsize=512' & @CRLF & _
'gl_texture_hqresize_mt_height=4' & @CRLF & _
'gl_texture_hqresize_mt_width=16' & @CRLF & _
'gl_texture_hqresize_multithread=true' & @CRLF & _
'gl_texture_hqresize_targets=15' & @CRLF & _
'gl_texture_hqresizemode=0' & @CRLF & _
'gl_texture_hqresizemult=1' & @CRLF & _
'gl_usecolorblending=true' & @CRLF & _
'gme_stereodepth=0' & @CRLF & _
'gus_memsize=0' & @CRLF & _
'gus_patchdir=' & @CRLF & _
'i_discordrpc=false' & @CRLF & _
'i_pauseinbackground=false' & @CRLF & _
'i_soundinbackground=true' & @CRLF & _
'in_mouse=0' & @CRLF & _
'inter_subtitles=false' & @CRLF & _
'invertmouse=false' & @CRLF & _
'invertmousex=false' & @CRLF & _
'joy_dinput=false' & @CRLF & _
'joy_ps2raw=false' & @CRLF & _
'joy_xinput=true' & @CRLF & _
'k_allowfullscreentoggle=false' & @CRLF & _
'k_mergekeys=true' & @CRLF & _
'language=auto' & @CRLF & _
'longsavemessages=true' & @CRLF & _
'lookstrafe=false' & @CRLF & _
'm_blockcontrollers=false' & @CRLF & _
'm_cleanscale=false' & @CRLF & _
'm_forward=1' & @CRLF & _
'm_pitch=1' & @CRLF & _
'm_sensitivity_x=2' & @CRLF & _
'm_sensitivity_y=1' & @CRLF & _
'm_show_backbutton=0' & @CRLF & _
'm_showinputgrid=0' & @CRLF & _
'm_side=2' & @CRLF & _
'm_simpleoptions=false' & @CRLF & _
'm_swapbuttons=false' & @CRLF & _
'm_use_mouse=2' & @CRLF & _
'm_yaw=1' & @CRLF & _
'map_point_coordinates=true' & @CRLF & _
'midi_config=' & @CRLF & _
'midi_dmxgus=false' & @CRLF & _
'midi_voices=32' & @CRLF & _
'mod_autochip=false' & @CRLF & _
'mod_autochip_scan_threshold=12' & @CRLF & _
'mod_autochip_size_force=100' & @CRLF & _
'mod_autochip_size_scan=500' & @CRLF & _
'mod_dumb_mastervolume=1' & @CRLF & _
'mod_interp=2' & @CRLF & _
'mod_samplerate=0' & @CRLF & _
'mod_volramp=2' & @CRLF & _
'mouse_capturemode=1' & @CRLF & _
'mus_calcgain=true' & @CRLF & _
'mus_enabled=true' & @CRLF & _
'mus_gainoffset=0' & @CRLF & _
'mus_usereplaygain=false' & @CRLF & _
'netcompat=false' & @CRLF & _
'nointerscrollabort=false' & @CRLF & _
'nomonsterinterpolation=false' & @CRLF & _
'oldsaveorder=false' & @CRLF & _
'opl_core=0' & @CRLF & _
'opl_fullpan=true' & @CRLF & _
'opl_numchips=2' & @CRLF & _
'opn_chips_count=8' & @CRLF & _
'opn_emulator_id=0' & @CRLF & _
'opn_fullpan=true' & @CRLF & _
'opn_run_at_pcm_rate=false' & @CRLF & _
'os_isanyof=true' & @CRLF & _
'pistolstart=false' & @CRLF & _
'png_gamma=0' & @CRLF & _
'png_level=5' & @CRLF & _
'queryiwad=true' & @CRLF & _
'queryiwad_key=shift' & @CRLF & _
'quicksavenum=-1' & @CRLF & _
'quicksaverotation=false' & @CRLF & _
'quicksaverotationcount=4' & @CRLF & _
'r_actorspriteshadow=1' & @CRLF & _
'r_actorspriteshadowdist=1500' & @CRLF & _
'r_blendmethod=false' & @CRLF & _
'r_dynlights=true' & @CRLF & _
'r_fakecontrast=1' & @CRLF & _
'r_fullbrightignoresectorcolor=true' & @CRLF & _
'r_fuzzscale=true' & @CRLF & _
'r_line_distance_cull=8000' & @CRLF & _
'r_linearsky=false' & @CRLF & _
'r_magfilter=false' & @CRLF & _
'r_minfilter=true' & @CRLF & _
'r_mipmap=true' & @CRLF & _
'r_mirror_recursions=4' & @CRLF & _
'r_models=true' & @CRLF & _
'r_multithreaded=0' & @CRLF & _
'r_noaccel=false' & @CRLF & _
'r_quakeintensity=1' & @CRLF & _
'r_skipmats=false' & @CRLF & _
'r_sprite_distance_cull=4000' & @CRLF & _
'r_spriteadjust=2' & @CRLF & _
'r_ticstability=true' & @CRLF & _
'save_dir=<REPLACEME>' & @CRLF & _
'save_formatted=false' & @CRLF & _
'saveloadconfirmation=true' & @CRLF & _
'savestatistics=0' & @CRLF & _
'screenshot_dir=' & @CRLF & _
'screenshot_quiet=false' & @CRLF & _
'screenshot_type=png' & @CRLF & _
'show_messages=true' & @CRLF & _
'showendoom=0' & @CRLF & _
'snd_aldevice=Default' & @CRLF & _
'snd_alresampler=Default' & @CRLF & _
'snd_backend=openal' & @CRLF & _
'snd_buffersize=0' & @CRLF & _
'snd_channels=128' & @CRLF & _
'snd_efx=false' & @CRLF & _
'snd_enabled=true' & @CRLF & _
'snd_hrtf=0' & @CRLF & _
'snd_mastervolume=0.5' & @CRLF & _
'snd_mididevice=-2' & @CRLF & _
'snd_midiprecache=false' & @CRLF & _
'snd_musicvolume=1' & @CRLF & _
'snd_samplerate=0' & @CRLF & _
'snd_sfxvolume=1' & @CRLF & _
'snd_streambuffersize=64' & @CRLF & _
'snd_waterreverb=true' & @CRLF & _
'statfile=zdoomstat.txt' & @CRLF & _
'storesavepic=true' & @CRLF & _
'strictdecorate=false' & @CRLF & _
'telezoom=true' & @CRLF & _
'timidity_channel_pressure=false' & @CRLF & _
'timidity_chorus=0' & @CRLF & _
'timidity_config=lzdoom' & @CRLF & _
'timidity_drum_effect=false' & @CRLF & _
'timidity_drum_power=1' & @CRLF & _
'timidity_key_adjust=0' & @CRLF & _
'timidity_lpf_def=1' & @CRLF & _
'timidity_min_sustain_time=5000' & @CRLF & _
'timidity_modulation_envelope=true' & @CRLF & _
'timidity_modulation_wheel=true' & @CRLF & _
'timidity_overlap_voice_allow=true' & @CRLF & _
'timidity_pan_delay=false' & @CRLF & _
'timidity_portamento=true' & @CRLF & _
'timidity_reverb=0' & @CRLF & _
'timidity_reverb_level=0' & @CRLF & _
'timidity_surround_chorus=false' & @CRLF & _
'timidity_temper_control=true' & @CRLF & _
'timidity_tempo_adjust=1' & @CRLF & _
'turnspeedsprintfast=1280' & @CRLF & _
'turnspeedsprintslow=320' & @CRLF & _
'turnspeedwalkfast=640' & @CRLF & _
'turnspeedwalkslow=320' & @CRLF & _
'use_joystick=true' & @CRLF & _
'use_mouse=false' & @CRLF & _
'vid_activeinbackground=true' & @CRLF & _
'vid_adapter=0' & @CRLF & _
'vid_aspect=0' & @CRLF & _
'vid_brightness=0' & @CRLF & _
'vid_contrast=1' & @CRLF & _
'vid_cropaspect=false' & @CRLF & _
'vid_defheight=480' & @CRLF & _
'vid_defwidth=640' & @CRLF & _
'vid_forcegdi=false' & @CRLF & _
'vid_fullscreen=false' & @CRLF & _
'vid_gamma=1' & @CRLF & _
'vid_gpuswitch=0' & @CRLF & _
'vid_hdr=false' & @CRLF & _
'vid_maxfps=60' & @CRLF & _
'vid_preferbackend=0' & @CRLF & _
'vid_rendermode=4' & @CRLF & _
'vid_saturation=1' & @CRLF & _
'vid_scale_customheight=400' & @CRLF & _
'vid_scale_custompixelaspect=1' & @CRLF & _
'vid_scale_customwidth=640' & @CRLF & _
'vid_scale_linear=false' & @CRLF & _
'vid_scalefactor=1' & @CRLF & _
'vid_scalemode=0' & @CRLF & _
'vid_vsync=false' & @CRLF & _
'vk_debug=false' & @CRLF & _
'vk_debug_callstack=true' & @CRLF & _
'vk_device=0' & @CRLF & _
'vk_hdr=false' & @CRLF & _
'vr_enable_quadbuffered=false' & @CRLF & _
'vr_hunits_per_meter=41' & @CRLF & _
'vr_ipd=0.06199999898672104' & @CRLF & _
'vr_mode=0' & @CRLF & _
'vr_screendist=0.800000011920929' & @CRLF & _
'vr_swap_eyes=false' & @CRLF & _
'wildmidi_config=' & @CRLF & _
'wildmidi_enhanced_resampling=true' & @CRLF & _
'wildmidi_reverb=false' & @CRLF & _
'win_h=864' & @CRLF & _
'win_maximized=false' & @CRLF & _
'win_w=1536' & @CRLF & _
'win_x=-1' & @CRLF & _
'win_y=-1' & @CRLF & _
'xbrz_centerdirectionbias=4' & @CRLF & _
'xbrz_colorformat=0' & @CRLF & _
'xbrz_dominantdirectionthreshold=3.5999999046325684' & @CRLF & _
'xbrz_equalcolortolerance=30' & @CRLF & _
'xbrz_luminanceweight=1' & @CRLF & _
'xbrz_steepdirectionthreshold=2.200000047683716' & @CRLF & _
'[GlobalSettings.Unknown]' & @CRLF & _
'[Joy:XI:0]' & @CRLF & _
'Sensitivity=0.9' & @CRLF & _
'Axis0deadzone=0.2' & @CRLF & _
'Axis1deadzone=0.2' & @CRLF & _
'Axis2deadzone=0.2' & @CRLF & _
'Axis3deadzone=0.2' & @CRLF & _
'Axis3scale=0.200002' & @CRLF & _
'Axis4deadzone=0.2' & @CRLF & _
'Axis4scale=1' & @CRLF & _
'Axis5deadzone=0.2' & @CRLF & _
'Axis5scale=1' & @CRLF & _
'[Joy:XI:1]' & @CRLF & _
'Sensitivity=0.9' & @CRLF & _
'Axis0deadzone=0.35' & @CRLF & _
'Axis0scale=3.9' & @CRLF & _
'Axis0map=-1' & @CRLF & _
'Axis1deadzone=0.35' & @CRLF & _
'Axis1scale=3.9' & @CRLF & _
'Axis1map=-1' & @CRLF & _
'Axis2deadzone=0.25' & @CRLF & _
'Axis2scale=1.1' & @CRLF & _
'Axis2map=-1' & @CRLF & _
'Axis3deadzone=0.35' & @CRLF & _
'Axis3scale=4' & @CRLF & _
'Axis3map=-1' & @CRLF & _
'[Joy:XI:2]' & @CRLF & _
'Sensitivity=0.9' & @CRLF & _
'Axis0deadzone=0.35' & @CRLF & _
'Axis0scale=3.9' & @CRLF & _
'Axis0map=-1' & @CRLF & _
'Axis1deadzone=0.35' & @CRLF & _
'Axis1scale=3.9' & @CRLF & _
'Axis1map=-1' & @CRLF & _
'Axis2deadzone=0.25' & @CRLF & _
'Axis2scale=1.1' & @CRLF & _
'Axis2map=-1' & @CRLF & _
'Axis3deadzone=0.35' & @CRLF & _
'Axis3scale=4' & @CRLF & _
'Axis3map=-1' & @CRLF & _
'[Joy:XI:3]' & @CRLF & _
'Sensitivity=0.9' & @CRLF & _
'Axis0deadzone=0.35' & @CRLF & _
'Axis0scale=3.9' & @CRLF & _
'Axis0map=-1' & @CRLF & _
'Axis1deadzone=0.35' & @CRLF & _
'Axis1scale=3.9' & @CRLF & _
'Axis1map=-1' & @CRLF & _
'Axis2deadzone=0.25' & @CRLF & _
'Axis2scale=1.1' & @CRLF & _
'Axis2map=-1' & @CRLF & _
'Axis3deadzone=0.35' & @CRLF & _
'Axis3scale=4' & @CRLF & _
'Axis3map=-1' & @CRLF & _
'[Doom.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Doom.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=1' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ff 00 00' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=0' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=1' & @CRLF & _
'[Doom.LocalServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Doom.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Doom.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'pause=pause' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_x=+reload' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'lshoulder=weapprev' & @CRLF & _
'LThumb=toggle cl_run' & @CRLF & _
'[Doom.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Heretic.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=3f 60 40' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Heretic.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=73 43 23' & @CRLF & _
'am_colorset=3' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=d0 b0 85' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=54 3b 17' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=true' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=e4 e4 e4' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=0' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=9' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=9' & @CRLF & _
'msgmidcolor2=10' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=true' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=false' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=0' & @CRLF & _
'[Heretic.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Heretic.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Heretic.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'backspace=use ArtiTomeOfPower' & @CRLF & _
'pause=pause' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'lthumb=toggle cl_run' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_x=invprev' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'LShoulder=weapprev' & @CRLF & _
'Pad_Start=invuse' & @CRLF & _
'Pad_A=invnext' & @CRLF & _
'[Heretic.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'Pad_A=am_setmark' & @CRLF & _
'Pad_B=am_clearmarks' & @CRLF & _
'[Hexen.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Hexen.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=73 43 23' & @CRLF & _
'am_colorset=3' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=d0 b0 85' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=54 3b 17' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=true' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ac b5 a6' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=0' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=9' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=9' & @CRLF & _
'msgmidcolor2=10' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=true' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=false' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=0' & @CRLF & _
'[Hexen.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Hexen.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Hexen.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'pause=pause' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'lthumb=toggle cl_run' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'lshoulder=weapprev' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'ltrigger=+jump' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_a=invnext' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'Pad_Start=invuse' & @CRLF & _
'Pad_X=invprev' & @CRLF & _
'[Hexen.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Strife.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Strife.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=2' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ff 00 00' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=2' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=10' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=3' & @CRLF & _
'[Strife.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Strife.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Strife.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'pause=pause' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'lthumb=toggle cl_run' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_x=showpop 1' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'LShoulder=weapprev' & @CRLF & _
'LTrigger=+jump' & @CRLF & _
'Pad_Start=invuse' & @CRLF & _
'Pad_A=invnext' & @CRLF & _
'F=use BetterStrifePlayerFlashlight' & @CRLF & _
'H=netevent EV_UseHealth' & @CRLF & _
'[Strife.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Hacx.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Hacx.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=0' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ff 00 00' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=0' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=1' & @CRLF & _
'[Hacx.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Hacx.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Hacx.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'pause=pause' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'lshoulder=weapprev' & @CRLF & _
'LThumb=toggle cl_run' & @CRLF & _
'[Hacx.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Chex.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Chex.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=2' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ef ef ef' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=0' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=1' & @CRLF & _
'[Chex.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Chex.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Chex.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'pause=pause' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'pad_b=+use' & @CRLF & _
'LShoulder=weapprev' & @CRLF & _
'LThumb=toggle cl_run' & @CRLF & _
'RThumb=centerview' & @CRLF & _
'[Chex.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[square.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[square.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=0' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ff 00 00' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=2' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=10' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=1' & @CRLF & _
'[square.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[square.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[square.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'pause=pause' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'lshoulder=weapprev' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'ltrigger=+jump' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_a=+altattack' & @CRLF & _
'pad_b=+use' & @CRLF & _
'pad_x=+crouch' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'CapsLock=alwaysrun' & @CRLF & _
'LThumb=toggle cl_run' & @CRLF & _
'[square.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Harmony.Player]' & @CRLF & _
'autoaim=35' & @CRLF & _
'classicflight=false' & @CRLF & _
'color=40 cf 00' & @CRLF & _
'colorset=0' & @CRLF & _
'fov=90' & @CRLF & _
'gender=male' & @CRLF & _
'movebob=0.25' & @CRLF & _
'name=Player_1' & @CRLF & _
'neverswitchonpickup=false' & @CRLF & _
'playerclass=Fighter' & @CRLF & _
'skin=base' & @CRLF & _
'stillbob=0' & @CRLF & _
'team=255' & @CRLF & _
'vertspread=false' & @CRLF & _
'wbobfire=0' & @CRLF & _
'wbobspeed=1' & @CRLF & _
'wi_noautostartmap=false' & @CRLF & _
'[Harmony.ConsoleVariables]' & @CRLF & _
'addrocketexplosion=false' & @CRLF & _
'adl_bank=14' & @CRLF & _
'adl_custom_bank=' & @CRLF & _
'adl_use_custom_bank=false' & @CRLF & _
'allcheats=false' & @CRLF & _
'am_backcolor=6c 54 40' & @CRLF & _
'am_cdwallcolor=4c 38 20' & @CRLF & _
'am_colorset=2' & @CRLF & _
'am_customcolors=true' & @CRLF & _
'am_drawmapback=1' & @CRLF & _
'am_efwallcolor=66 55 55' & @CRLF & _
'am_emptyspacemargin=0' & @CRLF & _
'am_fdwallcolor=88 70 58' & @CRLF & _
'am_followplayer=true' & @CRLF & _
'am_gridcolor=8b 5a 2b' & @CRLF & _
'am_interlevelcolor=ff 00 00' & @CRLF & _
'am_intralevelcolor=00 00 ff' & @CRLF & _
'am_linealpha=1' & @CRLF & _
'am_linethickness=1' & @CRLF & _
'am_lockedcolor=00 78 00' & @CRLF & _
'am_map_secrets=1' & @CRLF & _
'am_markcolor=2' & @CRLF & _
'am_markfont=AMMNUMx' & @CRLF & _
'am_notseencolor=6c 6c 6c' & @CRLF & _
'am_ovcdwallcolor=00 88 44' & @CRLF & _
'am_ovefwallcolor=00 88 44' & @CRLF & _
'am_overlay=0' & @CRLF & _
'am_ovfdwallcolor=00 88 44' & @CRLF & _
'am_ovinterlevelcolor=ff ff 00' & @CRLF & _
'am_ovlockedcolor=00 88 44' & @CRLF & _
'am_ovotherwallscolor=00 88 44' & @CRLF & _
'am_ovportalcolor=00 40 22' & @CRLF & _
'am_ovsecretsectorcolor=00 ff ff' & @CRLF & _
'am_ovsecretwallcolor=00 88 44' & @CRLF & _
'am_ovspecialwallcolor=ff ff ff' & @CRLF & _
'am_ovtelecolor=ff ff 00' & @CRLF & _
'am_ovthingcolor=e8 88 00' & @CRLF & _
'am_ovthingcolor_citem=e8 88 00' & @CRLF & _
'am_ovthingcolor_friend=e8 88 00' & @CRLF & _
'am_ovthingcolor_item=e8 88 00' & @CRLF & _
'am_ovthingcolor_monster=e8 88 00' & @CRLF & _
'am_ovthingcolor_ncmonster=e8 88 00' & @CRLF & _
'am_ovunexploredsecretcolor=00 ff ff' & @CRLF & _
'am_ovunseencolor=00 22 6e' & @CRLF & _
'am_ovwallcolor=00 ff 00' & @CRLF & _
'am_ovyourcolor=fc e8 d8' & @CRLF & _
'am_portalcolor=40 40 40' & @CRLF & _
'am_portaloverlay=true' & @CRLF & _
'am_rotate=0' & @CRLF & _
'am_secretsectorcolor=ff 00 ff' & @CRLF & _
'am_secretwallcolor=00 00 00' & @CRLF & _
'am_showgrid=false' & @CRLF & _
'am_showitems=false' & @CRLF & _
'am_showkeys=true' & @CRLF & _
'am_showkeys_always=false' & @CRLF & _
'am_showmaplabel=2' & @CRLF & _
'am_showmonsters=true' & @CRLF & _
'am_showsecrets=true' & @CRLF & _
'am_showthingsprites=0' & @CRLF & _
'am_showtime=true' & @CRLF & _
'am_showtotaltime=false' & @CRLF & _
'am_showtriggerlines=0' & @CRLF & _
'am_specialwallcolor=ff ff ff' & @CRLF & _
'am_textured=true' & @CRLF & _
'am_thingcolor=fc fc fc' & @CRLF & _
'am_thingcolor_citem=fc fc fc' & @CRLF & _
'am_thingcolor_friend=fc fc fc' & @CRLF & _
'am_thingcolor_item=fc fc fc' & @CRLF & _
'am_thingcolor_monster=fc fc fc' & @CRLF & _
'am_thingcolor_ncmonster=fc fc fc' & @CRLF & _
'am_thingrenderstyles=true' & @CRLF & _
'am_tswallcolor=88 88 88' & @CRLF & _
'am_unexploredsecretcolor=ff 00 ff' & @CRLF & _
'am_wallcolor=2c 18 08' & @CRLF & _
'am_xhaircolor=80 80 80' & @CRLF & _
'am_yourcolor=fc e8 d8' & @CRLF & _
'am_zoomdir=0' & @CRLF & _
'blood_fade_scalar=1' & @CRLF & _
'chat_substitution=false' & @CRLF & _
'chatmacro0=No' & @CRLF & _
'chatmacro1=I am ready to kick butt!' & @CRLF & _
'chatmacro2=I am OK.' & @CRLF & _
'chatmacro3=I am not looking too good!' & @CRLF & _
'chatmacro4=Help!' & @CRLF & _
'chatmacro5=You suck!' & @CRLF & _
'chatmacro6=Next time, scumbag...' & @CRLF & _
'chatmacro7=Come here!' & @CRLF & _
'chatmacro8=I will take care of it.' & @CRLF & _
'chatmacro9=Yes' & @CRLF & _
'cl_bbannounce=false' & @CRLF & _
'cl_bloodsplats=true' & @CRLF & _
'cl_bloodtype=0' & @CRLF & _
'cl_custominvulmapcolor1=00 00 1a' & @CRLF & _
'cl_custominvulmapcolor2=a6 a6 7a' & @CRLF & _
'cl_customizeinvulmap=false' & @CRLF & _
'cl_doautoaim=false' & @CRLF & _
'cl_gfxlocalization=3' & @CRLF & _
'cl_maxdecals=1024' & @CRLF & _
'cl_missiledecals=true' & @CRLF & _
'cl_nointros=false' & @CRLF & _
'cl_pufftype=0' & @CRLF & _
'cl_rockettrails=1' & @CRLF & _
'cl_showmultikills=true' & @CRLF & _
'cl_showsecretmessage=true' & @CRLF & _
'cl_showsprees=true' & @CRLF & _
'cl_spreaddecals=true' & @CRLF & _
'classic_scaling_factor=1' & @CRLF & _
'classic_scaling_pixelaspect=1.2000000476837158' & @CRLF & _
'compatmode=0' & @CRLF & _
'con_alpha=0.75' & @CRLF & _
'con_centernotify=false' & @CRLF & _
'con_midtime=3' & @CRLF & _
'con_notablist=false' & @CRLF & _
'con_notifytime=3' & @CRLF & _
'con_pulsetext=false' & @CRLF & _
'con_scale=0' & @CRLF & _
'con_scaletext=0' & @CRLF & _
'crosshair=2' & @CRLF & _
'crosshaircolor=ff 00 00' & @CRLF & _
'crosshairforce=false' & @CRLF & _
'crosshairgrow=false' & @CRLF & _
'crosshairhealth=2' & @CRLF & _
'crosshairon=true' & @CRLF & _
'crosshairscale=0.2' & @CRLF & _
'dehload=0' & @CRLF & _
'dimamount=-1' & @CRLF & _
'dimcolor=ff d7 00' & @CRLF & _
'displaynametags=0' & @CRLF & _
'dlg_musicvolume=1' & @CRLF & _
'dlg_vgafont=false' & @CRLF & _
'gl_aalines=false' & @CRLF & _
'gl_bandedswlight=false' & @CRLF & _
'gl_bloom=false' & @CRLF & _
'gl_bloom_amount=1.399999976158142' & @CRLF & _
'gl_brightfog=false' & @CRLF & _
'gl_enhanced_nightvision=false' & @CRLF & _
'gl_exposure_base=0.3499999940395355' & @CRLF & _
'gl_exposure_min=0.3499999940395355' & @CRLF & _
'gl_exposure_scale=1.2999999523162842' & @CRLF & _
'gl_exposure_speed=0.05000000074505806' & @CRLF & _
'gl_fogmode=2' & @CRLF & _
'gl_fuzztype=0' & @CRLF & _
'gl_interpolate_model_frames=true' & @CRLF & _
'gl_light_models=true' & @CRLF & _
'gl_lightadditivesurfaces=false' & @CRLF & _
'gl_lightmode=8' & @CRLF & _
'gl_menu_blur=-1' & @CRLF & _
'gl_paltonemap_powtable=2' & @CRLF & _
'gl_paltonemap_reverselookup=true' & @CRLF & _
'gl_precache=false' & @CRLF & _
'gl_scale_viewport=true' & @CRLF & _
'gl_sclipfactor=1.7999999523162842' & @CRLF & _
'gl_sclipthreshold=10' & @CRLF & _
'gl_spriteclip=1' & @CRLF & _
'gl_tonemap=0' & @CRLF & _
'gl_weaponlight=8' & @CRLF & _
'hud_althud=false' & @CRLF & _
'hud_althud_forceinternal=false' & @CRLF & _
'hud_althudscale=0' & @CRLF & _
'hud_ammo_order=0' & @CRLF & _
'hud_ammo_red=25' & @CRLF & _
'hud_ammo_yellow=50' & @CRLF & _
'hud_armor_green=100' & @CRLF & _
'hud_armor_red=25' & @CRLF & _
'hud_armor_yellow=50' & @CRLF & _
'hud_aspectscale=false' & @CRLF & _
'hud_berserk_health=true' & @CRLF & _
'hud_health_green=100' & @CRLF & _
'hud_health_red=25' & @CRLF & _
'hud_health_yellow=50' & @CRLF & _
'hud_oldscale=true' & @CRLF & _
'hud_scale=0' & @CRLF & _
'hud_scalefactor=1' & @CRLF & _
'hud_showammo=2' & @CRLF & _
'hud_showangles=false' & @CRLF & _
'hud_showitems=false' & @CRLF & _
'hud_showlag=0' & @CRLF & _
'hud_showmonsters=true' & @CRLF & _
'hud_showscore=false' & @CRLF & _
'hud_showsecrets=true' & @CRLF & _
'hud_showstats=false' & @CRLF & _
'hud_showtime=0' & @CRLF & _
'hud_showtimestat=0' & @CRLF & _
'hud_showweapons=true' & @CRLF & _
'hud_timecolor=5' & @CRLF & _
'hudcolor_ltim=8' & @CRLF & _
'hudcolor_statnames=6' & @CRLF & _
'hudcolor_stats=3' & @CRLF & _
'hudcolor_time=6' & @CRLF & _
'hudcolor_titl=10' & @CRLF & _
'hudcolor_ttim=5' & @CRLF & _
'hudcolor_xyco=3' & @CRLF & _
'inter_classic_scaling=true' & @CRLF & _
'log_vgafont=false' & @CRLF & _
'lookspring=true' & @CRLF & _
'm_quickexit=false' & @CRLF & _
'msg=0' & @CRLF & _
'msg0color=11' & @CRLF & _
'msg1color=5' & @CRLF & _
'msg2color=2' & @CRLF & _
'msg3color=3' & @CRLF & _
'msg4color=3' & @CRLF & _
'msgmidcolor=11' & @CRLF & _
'msgmidcolor2=4' & @CRLF & _
'nametagcolor=5' & @CRLF & _
'nocheats=false' & @CRLF & _
'opn_custom_bank=' & @CRLF & _
'opn_use_custom_bank=false' & @CRLF & _
'paletteflash=0' & @CRLF & _
'pickup_fade_scalar=1' & @CRLF & _
'r_deathcamera=false' & @CRLF & _
'r_drawfuzz=1' & @CRLF & _
'r_maxparticles=4000' & @CRLF & _
'r_portal_recursions=4' & @CRLF & _
'r_rail_smartspiral=false' & @CRLF & _
'r_rail_spiralsparsity=1' & @CRLF & _
'r_rail_trailsparsity=1' & @CRLF & _
'r_skymode=2' & @CRLF & _
'r_vanillatrans=0' & @CRLF & _
'sb_cooperative_enable=true' & @CRLF & _
'sb_cooperative_headingcolor=6' & @CRLF & _
'sb_cooperative_otherplayercolor=2' & @CRLF & _
'sb_cooperative_yourplayercolor=3' & @CRLF & _
'sb_deathmatch_enable=true' & @CRLF & _
'sb_deathmatch_headingcolor=6' & @CRLF & _
'sb_deathmatch_otherplayercolor=2' & @CRLF & _
'sb_deathmatch_yourplayercolor=3' & @CRLF & _
'sb_teamdeathmatch_enable=true' & @CRLF & _
'sb_teamdeathmatch_headingcolor=6' & @CRLF & _
'screenblocks=11' & @CRLF & _
'setslotstrict=true' & @CRLF & _
'show_obituaries=true' & @CRLF & _
'snd_menuvolume=0.6000000238418579' & @CRLF & _
'snd_pitched=false' & @CRLF & _
'st_oldouch=false' & @CRLF & _
'st_scale=0' & @CRLF & _
'transsouls=0.75' & @CRLF & _
'ui_classic=true' & @CRLF & _
'ui_screenborder_classic_scaling=true' & @CRLF & _
'uiscale=3' & @CRLF & _
'underwater_fade_scalar=1' & @CRLF & _
'vid_allowtrueultrawide=1' & @CRLF & _
'vid_cursor=None' & @CRLF & _
'vid_nopalsubstitutions=false' & @CRLF & _
'wi_cleantextscale=false' & @CRLF & _
'wi_percents=true' & @CRLF & _
'wi_showtotaltime=true' & @CRLF & _
'wipetype=1' & @CRLF & _
'[Harmony.LocalServerInfo]' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'[Harmony.NetServerInfo]' & @CRLF & _
'compatflags=0' & @CRLF & _
'compatflags2=0' & @CRLF & _
'forcewater=false' & @CRLF & _
'maxviewpitch=35' & @CRLF & _
'sv_alwaystally=0' & @CRLF & _
'sv_corpsequeuesize=64' & @CRLF & _
'sv_disableautohealth=false' & @CRLF & _
'sv_dropstyle=0' & @CRLF & _
'sv_portal_recursions=4' & @CRLF & _
'sv_smartaim=0' & @CRLF & _
'sv_stricterdoommode=false' & @CRLF & _
'[Harmony.Bindings]' & @CRLF & _
'-=sizedown' & @CRLF & _
'Equals=sizeup' & @CRLF & _
'pause=pause' & @CRLF & _
'pad_back=menu_main' & @CRLF & _
'`=toggleconsole' & @CRLF & _
'dpadup=+forward' & @CRLF & _
'dpaddown=+back' & @CRLF & _
'dpadleft=+moveleft' & @CRLF & _
'dpadright=+moveright' & @CRLF & _
'rthumb=centerview' & @CRLF & _
'rtrigger=+attack' & @CRLF & _
'pad_x=+reload' & @CRLF & _
'pad_y=togglemap' & @CRLF & _
'rshoulder=weapnext' & @CRLF & _
'lshoulder=weapprev' & @CRLF & _
'LThumb=toggle cl_run' & @CRLF & _
'Pad_B=+use' & @CRLF & _
'[Harmony.AutomapBindings]' & @CRLF & _
'LStickRight=+am_panright' & @CRLF & _
'LStickLeft=+am_panleft' & @CRLF & _
'LStickDown=+am_pandown' & @CRLF & _
'LStickUp=+am_panup' & @CRLF & _
'RStickDown=+am_zoomout' & @CRLF & _
'RStickUp=+am_zoomin' & @CRLF & _
'LThumb=am_togglefollow' & @CRLF & _
'RThumb=am_gobig' & @CRLF & _
'[Heretic.ConfigOnlyVariables]' & @CRLF & _
'[Heretic.UnknownConsoleVariables]' & @CRLF & _
'[Heretic.ConsoleAliases]' & @CRLF & _
'[Heretic.DoubleBindings]' & @CRLF & _
'[Doom.ConfigOnlyVariables]' & @CRLF & _
'[Doom.UnknownConsoleVariables]' & @CRLF & _
'[Doom.ConsoleAliases]' & @CRLF & _
'[Doom.DoubleBindings]' & @CRLF & _
'[Hexen.ConfigOnlyVariables]' & @CRLF & _
'[Hexen.UnknownConsoleVariables]' & @CRLF & _
'[Hexen.ConsoleAliases]' & @CRLF & _
'[Hexen.DoubleBindings]' & @CRLF & _
'[Strife.ConfigOnlyVariables]' & @CRLF & _
'[Strife.UnknownConsoleVariables]' & @CRLF & _
'[Strife.ConsoleAliases]' & @CRLF & _
'[Strife.DoubleBindings]' & @CRLF & _
'[Strife.Player.Mod]' & @CRLF & _
'betterstrife_alwaysshowexitmarkers=false' & @CRLF & _
'betterstrife_exitmarkers=1' & @CRLF & _
'betterstrife_flashlight=true' & @CRLF & _
'betterstrife_objectivepopupexitmarkers=true' & @CRLF & _
'betterstrife_questmarkers=1' & @CRLF & _
'nashhpbar_enable=true' & @CRLF & _
'strifecoop_chatbubble=true' & @CRLF & _
'strifecoop_debug=0' & @CRLF & _
'[Strife.NetServerInfo.Mod]' & @CRLF & _
'strifecoop_badending=false' & @CRLF & _
'strifecoop_disguise=false' & @CRLF & _
'strifecoop_enemiesdropgold=false' & @CRLF & _
'strifecoop_extraammo=false' & @CRLF & _
'strifecoop_gatherparty=true' & @CRLF & _
'strifecoop_scaleenemies=false' & @CRLF & _
'strifecoop_simulateplayercount=0' & @CRLF & _
'strifecoop_uberentity=false' & @CRLF & _
'[Strife.ConfigOnlyVariables.Mod]' & @CRLF & _
'[Chex.ConfigOnlyVariables]' & @CRLF & _
'[Chex.UnknownConsoleVariables]' & @CRLF & _
'[Chex.ConsoleAliases]' & @CRLF & _
'[Chex.DoubleBindings]' & @CRLF & _
'[Hacx.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Hacx.ConfigOnlyVariables]' & @CRLF & _
'[Hacx.UnknownConsoleVariables]' & @CRLF & _
'[Hacx.ConsoleAliases]' & @CRLF & _
'[Hacx.DoubleBindings]' & @CRLF & _
'[Harmony.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Harmony.ConfigOnlyVariables]' & @CRLF & _
'[Harmony.UnknownConsoleVariables]' & @CRLF & _
'[Harmony.ConsoleAliases]' & @CRLF & _
'[Harmony.DoubleBindings]' & @CRLF & _
'[Square.AutoExec]' & @CRLF & _
'Path=$PROGDIR/autoexec.cfg' & @CRLF & _
'[Square.Player.Mod]' & @CRLF & _
'square_jabber_chance=15' & @CRLF & _
'square_subtitles=false' & @CRLF & _
'[Square.NetServerInfo.Mod]' & @CRLF & _
'square_hints=true' & @CRLF & _
'[Square.ConfigOnlyVariables]' & @CRLF & _
'[Square.ConfigOnlyVariables.Mod]' & @CRLF & _
'[Square.UnknownConsoleVariables]' & @CRLF & _
'[Square.ConsoleAliases]' & @CRLF & _
'[Square.DoubleBindings]' & @CRLF & _
'[Doom.Player.Mod]' & @CRLF & _
'[Doom.NetServerInfo.Mod]' & @CRLF & _
'cheello_monsterfaceskiller=true' & @CRLF & _
'cheello_monsterpitchtotarget=false' & @CRLF & _
'cheello_noprecache=false' & @CRLF & _
'cheello_smoothmonsterrotation=false' & @CRLF & _
'cheello_spinningpickups=1' & @CRLF & _
'[Doom.ConfigOnlyVariables.Mod]')

FileClose($hFilehandle)

EndFunc

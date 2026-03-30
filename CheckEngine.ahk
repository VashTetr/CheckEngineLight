#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; Include all modules
#Include lib\ConfigManager.ahk
#Include lib\SoundManager.ahk
#Include lib\TrayManager.ahk
#Include lib\checks\DiskSpaceCheck.ahk
#Include lib\checks\ChipsetDriverCheck.ahk
#Include lib\checks\GPUDriverCheck.ahk
#Include lib\checks\RAMCheck.ahk
#Include lib\checks\NetworkCheck.ahk
#Include lib\checks\WindowsUpdateCheck.ahk
#Include lib\gui\ThemeManager.ahk
#Include lib\gui\ScrollManager.ahk
#Include lib\gui\tabs\StatusTab.ahk
#Include lib\gui\tabs\DrivesTab.ahk
#Include lib\gui\tabs\ChipsetTab.ahk
#Include lib\gui\tabs\GPUTab.ahk
#Include lib\gui\tabs\RAMTab.ahk
#Include lib\gui\tabs\NetworkTab.ahk
#Include lib\gui\tabs\WindowsUpdateTab.ahk
#Include lib\gui\tabs\SettingsTab.ahk
#Include lib\gui\MainWindow.ahk
#Include lib\EngineCore.ahk

; Resolve paths
scriptDir := A_ScriptDir
configPath := scriptDir "\config.ini"
iconDir := scriptDir "\icon_from_original_img"
imgDir := scriptDir "\img_original"

; Boot up
config := ConfigManager(configPath)
tray := TrayManager(iconDir)
sound := SoundManager()
engine := CheckEngine(config, tray, sound)

; Create GUI
mainWin := MainWindow(imgDir, config)
tray.SetMainWindow(mainWin)
engine.SetMainWindow(mainWin)

; Register checks
engine.RegisterCheck(DiskSpaceCheck(config))
engine.RegisterCheck(ChipsetDriverCheck(config))
engine.RegisterCheck(GPUDriverCheck(config))
engine.RegisterFastCheck(RAMCheck(config))
engine.RegisterFastCheck(NetworkCheck(config))
engine.RegisterVerySlowCheck(WindowsUpdateCheck(config))

; Start the engine
engine.Start()

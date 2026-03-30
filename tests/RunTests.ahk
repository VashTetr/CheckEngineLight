#Requires AutoHotkey v2.0
#SingleInstance Force

; Include the modules we're testing
#Include ..\lib\ConfigManager.ahk
#Include ..\lib\SoundManager.ahk
#Include ..\lib\TrayManager.ahk
#Include ..\lib\checks\DiskSpaceCheck.ahk
#Include ..\lib\checks\ChipsetDriverCheck.ahk
#Include ..\lib\checks\GPUDriverCheck.ahk
#Include ..\lib\checks\RAMCheck.ahk
#Include ..\lib\checks\RAMCheck.ahk
#Include ..\lib\checks\NetworkCheck.ahk
#Include ..\lib\checks\WindowsUpdateCheck.ahk
#Include ..\lib\gui\ThemeManager.ahk
#Include ..\lib\gui\ScrollManager.ahk
#Include ..\lib\gui\tabs\StatusTab.ahk
#Include ..\lib\gui\tabs\DrivesTab.ahk
#Include ..\lib\gui\tabs\ChipsetTab.ahk
#Include ..\lib\gui\tabs\GPUTab.ahk
#Include ..\lib\gui\tabs\RAMTab.ahk
#Include ..\lib\gui\tabs\NetworkTab.ahk
#Include ..\lib\gui\tabs\WindowsUpdateTab.ahk
#Include ..\lib\gui\tabs\SettingsTab.ahk
#Include ..\lib\gui\MainWindow.ahk
#Include ..\lib\EngineCore.ahk

; Include test framework and tests
#Include TestRunner.ahk
#Include TestConfigManager.ahk
#Include TestDiskSpaceCheck.ahk
#Include TestChipsetDriverCheck.ahk
#Include TestGPUDriverCheck.ahk
#Include TestRAMCheck.ahk
#Include TestNetworkCheck.ahk
#Include TestWindowsUpdateCheck.ahk
#Include TestTrayManager.ahk
#Include TestSoundManager.ahk

; Build and run
runner := TestRunner()
TestConfigManager.Register(runner)
TestDiskSpaceCheck.Register(runner)
TestChipsetDriverCheck.Register(runner)
TestGPUDriverCheck.Register(runner)
TestRAMCheck.Register(runner)
TestNetworkCheck.Register(runner)
TestWindowsUpdateCheck.Register(runner)
TestTrayManager.Register(runner)
TestSoundManager.Register(runner)

results := runner.RunAll()
summary := runner.GetSummary()

; Show results in a proper GUI
resultGui := Gui("+AlwaysOnTop", "Check Engine — Test Results")
resultGui.SetFont("s10", "Consolas")
resultGui.Add("Edit", "w600 h400 ReadOnly -WantReturn", summary)
resultGui.Add("Button", "w600 Default", "Close").OnEvent("Click", (*) => ExitApp())
resultGui.Show()

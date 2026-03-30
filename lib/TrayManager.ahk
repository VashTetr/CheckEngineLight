class TrayManager {
    iconDir := ""
    currentState := "IDLE"
    maxDrivesInTooltip := 5
    mainWindow := ""

    __New(iconDir) {
        this.iconDir := iconDir
        this._SetupTray()
        this.SetState("IDLE", [])
    }

    SetMainWindow(window) {
        this.mainWindow := window
    }

    _SetupTray() {
        A_TrayMenu.Delete()
        A_TrayMenu.Add("Scan Now", (*) => this._OnScanNow())
        A_TrayMenu.Add()
        A_TrayMenu.Add("Exit", (*) => ExitApp())
        A_IconTip := "Check Engine - Idle"

        ; Double-click tray icon to open GUI
        A_TrayMenu.Default := "Scan Now"  ; placeholder for double-click
        OnMessage(0x404, ObjBindMethod(this, "_OnTrayClick"))
    }

    SetState(state, results) {
        this.currentState := state
        this._UpdateIcon(state)
        this._UpdateTooltip(results)
    }

    _UpdateIcon(state) {
        iconFile := ""
        switch state {
            case "IDLE":    iconFile := "black_mkl.ico"
            case "OK":      iconFile := "green_mkl.ico"
            case "WARNING": iconFile := "yellow_mkl.ico"
            case "CRITICAL": iconFile := "red_mkl.ico"
            default:        iconFile := "black_mkl.ico"
        }
        iconPath := this.iconDir "\" iconFile
        if FileExist(iconPath)
            TraySetIcon(iconPath)
    }

    _UpdateTooltip(results) {
        if (results.Length == 0) {
            A_IconTip := "Check Engine - Idle"
            return
        }

        ; Only show warnings and criticals
        issues := []
        for result in results {
            if (result["status"] != "WARNING" && result["status"] != "CRITICAL")
                continue

            prefix := result["status"] == "CRITICAL" ? "🔴 " : "⚠ "
            resultType := result.Has("type") ? result["type"] : "disk"

            if (resultType == "chipset")
                issues.Push(prefix "Chipset: " result["message"])
            else if (resultType == "gpu")
                issues.Push(prefix "GPU: " result["message"])
            else if (resultType == "ram")
                issues.Push(prefix "RAM: " result["message"])
            else if (resultType == "network")
                issues.Push(prefix "Network: " result["message"])
            else if (resultType == "winupdate")
                issues.Push(prefix "Updates: " result["message"])
            else {
                freeGB := Round(result["freeSpace"] / 1024, 1)
                issues.Push(prefix result["drive"] " " result["freePercent"] "% free (" freeGB " GB)")
            }
        }

        if (issues.Length == 0) {
            A_IconTip := "Check Engine - All OK"
            return
        }

        ; Build tooltip from issues only
        tooltip := ""
        maxLines := this.maxDrivesInTooltip
        showCount := Min(issues.Length, maxLines)

        Loop showCount {
            if (A_Index > 1)
                tooltip .= "`n"
            tooltip .= issues[A_Index]
        }

        if (issues.Length > maxLines)
            tooltip .= "`n... Double-click for details"

        if (StrLen(tooltip) > 127)
            tooltip := SubStr(tooltip, 1, 124) "..."

        A_IconTip := tooltip
    }

    _OnScanNow() {
        this.SetState("IDLE", [])
        ; The main engine will pick this up via callback
        if this.HasOwnProp("scanCallback") && this.scanCallback
            this.scanCallback.Call()
    }

    _OnRunTests() {
        testScript := A_ScriptDir "\tests\RunTests.ahk"
        if FileExist(testScript)
            Run('"' A_AhkPath '" "' testScript '"')
        else
            MsgBox("Test script not found at:`n" testScript, "Check Engine", "Icon!")
    }

    OnScanRequested(callback) {
        this.scanCallback := callback
    }

    _OnTrayClick(wParam, lParam, msg, hwnd) {
        ; lParam 0x203 = WM_LBUTTONDBLCLK (double-click)
        if (lParam == 0x203) {
            if (this.mainWindow)
                this.mainWindow.Toggle()
        }
    }
}

class TestTrayManager {
    static Register(runner) {
        runner.Register("Tray: icon changes to black (IDLE)", ObjBindMethod(this, "TestIconIdle"))
        runner.Register("Tray: icon changes to green (OK)", ObjBindMethod(this, "TestIconOK"))
        runner.Register("Tray: icon changes to yellow (WARNING)", ObjBindMethod(this, "TestIconWarning"))
        runner.Register("Tray: icon changes to red (CRITICAL)", ObjBindMethod(this, "TestIconCritical"))
        runner.Register("Tray: tooltip shows drive info", ObjBindMethod(this, "TestTooltipContent"))
        runner.Register("Tray: tooltip truncates at 5+ drives", ObjBindMethod(this, "TestTooltipTruncation"))
    }

    static _GetIconDir() {
        return A_ScriptDir "\..\icon_from_original_img"
    }

    static _MakeFakeDrive(drive, freePercent, status) {
        return Map(
            "drive", drive,
            "freeSpace", 50000,
            "totalSize", 500000,
            "freePercent", freePercent,
            "status", status
        )
    }

    static TestIconIdle() {
        tm := TrayManager(this._GetIconDir())
        tm.SetState("IDLE", [])
        ; If no error thrown, icon file was found and set
        Assert(tm.currentState == "IDLE", "State should be IDLE")
    }

    static TestIconOK() {
        tm := TrayManager(this._GetIconDir())
        tm.SetState("OK", [this._MakeFakeDrive("C:", 50, "OK")])
        Assert(tm.currentState == "OK", "State should be OK")
    }

    static TestIconWarning() {
        tm := TrayManager(this._GetIconDir())
        tm.SetState("WARNING", [this._MakeFakeDrive("C:", 8, "WARNING")])
        Assert(tm.currentState == "WARNING", "State should be WARNING")
    }

    static TestIconCritical() {
        tm := TrayManager(this._GetIconDir())
        tm.SetState("CRITICAL", [this._MakeFakeDrive("C:", 3, "CRITICAL")])
        Assert(tm.currentState == "CRITICAL", "State should be CRITICAL")
    }

    static TestTooltipContent() {
        tm := TrayManager(this._GetIconDir())
        ; All OK drives should show "All OK" message
        drives := [this._MakeFakeDrive("C:", 50, "OK")]
        tm.SetState("OK", drives)
        Assert(InStr(A_IconTip, "All OK"), "Tooltip should say All OK for healthy drives, got: " A_IconTip)

        ; WARNING drives should show drive info
        drives := [this._MakeFakeDrive("C:", 8, "WARNING")]
        tm.SetState("WARNING", drives)
        Assert(InStr(A_IconTip, "C:"), "Tooltip should contain 'C:' for warning drive, got: " A_IconTip)
    }

    static TestTooltipTruncation() {
        tm := TrayManager(this._GetIconDir())
        drives := []
        Loop 6 {
            letter := Chr(66 + A_Index) ":"
            drives.Push(this._MakeFakeDrive(letter, 3, "CRITICAL"))
        }
        tm.SetState("CRITICAL", drives)
        Assert(InStr(A_IconTip, "..."), "Tooltip should contain '...' for 6 warning drives, got: " A_IconTip)
    }
}

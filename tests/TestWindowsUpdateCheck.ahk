class TestWindowsUpdateCheck {
    static Register(runner) {
        runner.Register("WinUpdate: returns results array", ObjBindMethod(this, "TestReturnsArray"))
        runner.Register("WinUpdate: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("WinUpdate: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("WinUpdate: disabled returns empty", ObjBindMethod(this, "TestDisabled"))
        runner.Register("WinUpdate: result type is winupdate", ObjBindMethod(this, "TestResultType"))
        runner.Register("WinUpdate: [INFO] update status", ObjBindMethod(this, "TestShowInfo"))
    }

    static _MakeConfig() {
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsArray() {
        check := WindowsUpdateCheck(this._MakeConfig())
        results := check.Run()
        Assert(Type(results) == "Array", "Expected Array, got " Type(results))
    }

    static TestResultFields() {
        check := WindowsUpdateCheck(this._MakeConfig())
        results := check.Run()
        Assert(results.Length > 0, "Expected at least one result")
        r := results[1]
        Assert(r.Has("type"), "Missing 'type'")
        Assert(r.Has("status"), "Missing 'status'")
        Assert(r.Has("message"), "Missing 'message'")
        Assert(r.Has("updateCount"), "Missing 'updateCount'")
    }

    static TestValidStatus() {
        check := WindowsUpdateCheck(this._MakeConfig())
        results := check.Run()
        for r in results {
            s := r["status"]
            Assert(s == "OK" || s == "WARNING" || s == "CRITICAL", "Invalid status: " s)
        }
    }

    static TestDisabled() {
        tempPath := A_Temp "\checkengine_test_wu.ini"
        tempConfig := "[WindowsUpdate]`nEnabled=0`nCheckIntervalHours=8`n"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(tempConfig, tempPath)
        cfg := ConfigManager(tempPath)
        check := WindowsUpdateCheck(cfg)
        results := check.Run()
        Assert(results.Length == 0, "Disabled should return empty")
        FileDelete(tempPath)
    }

    static TestResultType() {
        check := WindowsUpdateCheck(this._MakeConfig())
        results := check.Run()
        for r in results
            Assert(r["type"] == "winupdate", "Expected 'winupdate', got '" r["type"] "'")
    }

    static TestShowInfo() {
        check := WindowsUpdateCheck(this._MakeConfig())
        results := check.Run()
        r := results[1]
        info := r["message"]
        if (r["updateCount"] > 0)
            info .= " (critical: " r["criticalCount"] ")"
        return info
    }
}

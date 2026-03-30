class TestRAMCheck {
    static Register(runner) {
        runner.Register("RAM: returns results array", ObjBindMethod(this, "TestReturnsArray"))
        runner.Register("RAM: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("RAM: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("RAM: disabled returns empty", ObjBindMethod(this, "TestDisabled"))
        runner.Register("RAM: result type is ram", ObjBindMethod(this, "TestResultType"))
        runner.Register("RAM: usage percent is reasonable", ObjBindMethod(this, "TestUsageRange"))
        runner.Register("RAM: [INFO] current memory usage", ObjBindMethod(this, "TestShowInfo"))
    }

    static _MakeConfig() {
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsArray() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        Assert(Type(results) == "Array", "Expected Array, got " Type(results))
    }

    static TestResultFields() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        Assert(results.Length > 0, "Expected at least one result")
        r := results[1]
        Assert(r.Has("type"), "Missing 'type' field")
        Assert(r.Has("label"), "Missing 'label' field")
        Assert(r.Has("status"), "Missing 'status' field")
        Assert(r.Has("message"), "Missing 'message' field")
    }

    static TestValidStatus() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        validStatuses := ["OK", "WARNING", "CRITICAL"]
        for r in results {
            found := false
            for s in validStatuses {
                if (r["status"] == s)
                    found := true
            }
            Assert(found, "Invalid status: " r["status"])
        }
    }

    static TestDisabled() {
        tempPath := A_Temp "\checkengine_test_ram.ini"
        tempConfig := "[General]`nCheckIntervalMinutes=10`n`n[DiskSpace]`nWarningPercent=10`nCriticalPercent=5`n`n[ChipsetDriver]`nEnabled=1`nMaxDriverAgeMonths=9`n`n[GPUDriver]`nEnabled=1`nMaxDriverAgeMonths=6`n`n[RAM]`nEnabled=0`nWarningPercent=85`nCriticalPercent=95`n"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(tempConfig, tempPath)
        cfg := ConfigManager(tempPath)
        check := RAMCheck(cfg)
        results := check.Run()
        Assert(results.Length == 0, "Disabled check should return empty, got " results.Length)
        FileDelete(tempPath)
    }

    static TestResultType() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        for r in results
            Assert(r["type"] == "ram", "Expected type 'ram', got '" r["type"] "'")
    }

    static TestUsageRange() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        r := results[1]
        pct := r["usedPercent"]
        Assert(pct >= 0 && pct <= 100, "Usage percent out of range: " pct)
    }

    static TestShowInfo() {
        check := RAMCheck(this._MakeConfig())
        results := check.Run()
        r := results[1]
        return r["message"]
    }
}

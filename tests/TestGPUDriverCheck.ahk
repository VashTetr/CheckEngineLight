class TestGPUDriverCheck {
    static Register(runner) {
        runner.Register("GPU: returns results array", ObjBindMethod(this, "TestReturnsArray"))
        runner.Register("GPU: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("GPU: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("GPU: disabled returns empty", ObjBindMethod(this, "TestDisabled"))
        runner.Register("GPU: result type is gpu", ObjBindMethod(this, "TestResultType"))
        runner.Register("GPU: [INFO] detected driver details", ObjBindMethod(this, "TestShowDriverInfo"))
    }

    static _MakeConfig() {
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsArray() {
        check := GPUDriverCheck(this._MakeConfig())
        results := check.Run()
        Assert(Type(results) == "Array", "Expected Array, got " Type(results))
    }

    static TestResultFields() {
        check := GPUDriverCheck(this._MakeConfig())
        results := check.Run()
        Assert(results.Length > 0, "Expected at least one result")
        r := results[1]
        Assert(r.Has("type"), "Missing 'type' field")
        Assert(r.Has("label"), "Missing 'label' field")
        Assert(r.Has("status"), "Missing 'status' field")
        Assert(r.Has("message"), "Missing 'message' field")
        Assert(!InStr(r["message"], "Expected a Number"), "WMI query failed: " r["message"])
    }

    static TestValidStatus() {
        check := GPUDriverCheck(this._MakeConfig())
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
        tempPath := A_Temp "\checkengine_test_gpu.ini"
        tempConfig := "[General]`nCheckIntervalMinutes=10`n`n[DiskSpace]`nWarningPercent=10`nCriticalPercent=5`n`n[ChipsetDriver]`nEnabled=1`nMaxDriverAgeMonths=9`n`n[GPUDriver]`nEnabled=0`nMaxDriverAgeMonths=6`n"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(tempConfig, tempPath)

        cfg := ConfigManager(tempPath)
        check := GPUDriverCheck(cfg)
        results := check.Run()
        Assert(results.Length == 0, "Disabled check should return empty, got " results.Length " results")

        FileDelete(tempPath)
    }

    static TestResultType() {
        check := GPUDriverCheck(this._MakeConfig())
        results := check.Run()
        for r in results {
            Assert(r["type"] == "gpu", "Expected type 'gpu', got '" r["type"] "'")
        }
    }

    static TestShowDriverInfo() {
        check := GPUDriverCheck(this._MakeConfig())
        allDrivers := check._GetAllGPUDrivers()
        if (allDrivers.Length == 0)
            return "No GPU drivers detected"

        info := allDrivers.Length " GPU driver(s) found:`n"
        for drv in allDrivers {
            age := check._GetDriverAgeMonths(drv["date"])
            dateStr := check._FormatWmiDate(drv["date"])
            info .= "  " drv["name"] " v" drv["version"] " (" dateStr ", " Round(age) "mo) [" drv["provider"] "]`n"
        }
        return info
    }
}

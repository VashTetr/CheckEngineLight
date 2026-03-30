class TestChipsetDriverCheck {
    static Register(runner) {
        runner.Register("Chipset: returns results array", ObjBindMethod(this, "TestReturnsArray"))
        runner.Register("Chipset: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("Chipset: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("Chipset: disabled returns empty", ObjBindMethod(this, "TestDisabled"))
        runner.Register("Chipset: age calculation is reasonable", ObjBindMethod(this, "TestAgeCalculation"))
        runner.Register("Chipset: result type is chipset", ObjBindMethod(this, "TestResultType"))
        runner.Register("Chipset: [INFO] detected driver details", ObjBindMethod(this, "TestShowDriverInfo"))
    }

    static _MakeConfig() {
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsArray() {
        check := ChipsetDriverCheck(this._MakeConfig())
        results := check.Run()
        Assert(Type(results) == "Array", "Expected Array, got " Type(results))
    }

    static TestResultFields() {
        check := ChipsetDriverCheck(this._MakeConfig())
        results := check.Run()
        ; Should always return at least one result (even error fallback has these fields)
        Assert(results.Length > 0, "Expected at least one result")
        r := results[1]
        Assert(r.Has("type"), "Missing 'type' field")
        Assert(r.Has("label"), "Missing 'label' field")
        Assert(r.Has("status"), "Missing 'status' field")
        Assert(r.Has("message"), "Missing 'message' field")
        ; If it fell back to error, the message should NOT contain "Expected a Number"
        Assert(!InStr(r["message"], "Expected a Number"), "WMI query failed: " r["message"])
    }

    static TestValidStatus() {
        check := ChipsetDriverCheck(this._MakeConfig())
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
        ; Create a temp config with chipset disabled
        tempPath := A_Temp "\checkengine_test_chipset.ini"
        tempConfig := "[General]`nCheckIntervalMinutes=10`n`n[DiskSpace]`nWarningPercent=10`nCriticalPercent=5`n`n[ChipsetDriver]`nEnabled=0`nCheckIntervalMinutes=120`nMaxDriverAgeMonths=6`n"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(tempConfig, tempPath)

        cfg := ConfigManager(tempPath)
        check := ChipsetDriverCheck(cfg)
        results := check.Run()
        Assert(results.Length == 0, "Disabled check should return empty, got " results.Length " results")

        FileDelete(tempPath)
    }

    static TestAgeCalculation() {
        check := ChipsetDriverCheck(this._MakeConfig())
        ; Test with a known WMI date string (Jan 1, 2020)
        age := check._GetDriverAgeMonths("20200101000000.000000-000")
        Assert(age > 12, "Driver from 2020 should be >12 months old, got " age)
        Assert(age < 200, "Age should be reasonable, got " age)
    }

    static TestResultType() {
        check := ChipsetDriverCheck(this._MakeConfig())
        results := check.Run()
        for r in results {
            Assert(r["type"] == "chipset", "Expected type 'chipset', got '" r["type"] "'")
        }
    }

    static TestShowDriverInfo() {
        check := ChipsetDriverCheck(this._MakeConfig())
        allDrivers := check._GetAllChipsetDrivers()
        if (allDrivers.Length == 0)
            return "No chipset drivers detected"

        info := allDrivers.Length " drivers found:`n"
        for drv in allDrivers {
            age := check._GetDriverAgeMonths(drv["date"])
            dateStr := check._FormatWmiDate(drv["date"])
            info .= "  " drv["name"] " v" drv["version"] " (" dateStr ", " Round(age) "mo)`n"
        }
        return info
    }
}

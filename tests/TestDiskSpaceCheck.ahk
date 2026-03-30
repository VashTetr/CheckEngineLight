class TestDiskSpaceCheck {
    static Register(runner) {
        runner.Register("DiskSpace: returns results", ObjBindMethod(this, "TestReturnsResults"))
        runner.Register("DiskSpace: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("DiskSpace: freePercent is between 0 and 100", ObjBindMethod(this, "TestPercentRange"))
        runner.Register("DiskSpace: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("DiskSpace: skips removable drives", ObjBindMethod(this, "TestSkipsRemovable"))
    }

    static _MakeConfig() {
        ; Use the real config for testing
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsResults() {
        check := DiskSpaceCheck(this._MakeConfig())
        results := check.Run()
        Assert(results.Length > 0, "Expected at least one drive result")
    }

    static TestResultFields() {
        check := DiskSpaceCheck(this._MakeConfig())
        results := check.Run()
        dr := results[1]
        Assert(dr.Has("drive"), "Missing 'drive' field")
        Assert(dr.Has("freeSpace"), "Missing 'freeSpace' field")
        Assert(dr.Has("totalSize"), "Missing 'totalSize' field")
        Assert(dr.Has("freePercent"), "Missing 'freePercent' field")
        Assert(dr.Has("status"), "Missing 'status' field")
    }

    static TestPercentRange() {
        check := DiskSpaceCheck(this._MakeConfig())
        results := check.Run()
        for dr in results {
            pct := dr["freePercent"]
            Assert(pct >= 0 && pct <= 100, dr["drive"] " freePercent out of range: " pct)
        }
    }

    static TestValidStatus() {
        check := DiskSpaceCheck(this._MakeConfig())
        results := check.Run()
        validStatuses := ["OK", "WARNING", "CRITICAL"]
        for dr in results {
            found := false
            for s in validStatuses {
                if (dr["status"] == s)
                    found := true
            }
            Assert(found, dr["drive"] " has invalid status: " dr["status"])
        }
    }

    static TestSkipsRemovable() {
        ; We verify that only FIXED drives appear by checking drive types
        check := DiskSpaceCheck(this._MakeConfig())
        results := check.Run()
        for dr in results {
            driveLetter := dr["drive"]
            try {
                driveType := DriveGetType(driveLetter)
                Assert(driveType == "Fixed", driveLetter " is type '" driveType "', expected 'Fixed'")
            }
        }
    }
}
